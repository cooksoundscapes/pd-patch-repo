-- stands for Binary Damage State Machine
local BDSM = pd.Class:new():register("BDSM")

--[[
    INLET 1 receives MIDI note number
    INLET 2 is for velocity (note on/off)
    INLET 3 receives cue bang for resolving waiting states
    INLET 4 cooks playing position and updates the grid lights, per channel
    OUTLET 1 sends messages to sample player clones
    OUTLET 2 sends midi notes for the grid controller
]]

local state = {
    off = 0,
    stopped = 1,
    stop_cue = 2,
    rec = 3,
    rec_cue = 4,
    playing = 5,
    play_cue = 6,
    stop_rec_cue = 7
}

local side = {
    stop = 82,
    solo = 83,
    rec_arm = 84,
    mute = 85,
    select = 86,
    user1 = 87,
    user2 = 88,
    stop_all = 89,
    shift = 98
}

function BDSM:initialize()
    self.inlets = 4
    self.outlets = 2
    self.last_vel = 0
    --[[
        note_in_map sets the new chan_state on a note_in
        cue_map sets the a new state on every channel if due
    ]]
    self.note_in_map = {
        [state.off] = state.rec_cue,
        [state.stopped] = state.play_cue,
        [state.rec] = state.stop_rec_cue,
        [state.rec_cue] = state.off,
        [state.playing] = state.playing
    }
    self.cue_map = {
        [state.stop_cue] = state.stopped,
        [state.rec_cue] = state.rec,
        [state.play_cue] = state.playing,
        [state.stop_rec_cue] = state.playing
    }
    self.action_map = {
        [state.off] = function(chan)
            self:set_row(chan, 0)
            self:outlet(1, "list", {chan, "clear"})
        end,
        [state.stopped] = function(chan)
            self:set_row(chan, 0)
            self:outlet(2, "list", {chan * self.n_row, 1})
            self:outlet(1, "list", {chan, "play", 0})
        end,
        [state.rec] = function(chan)
            local auto_stop = self.auto_stop_rec[chan]
            if auto_stop > 0 then
                self:set_row(chan, 0)
                self:set_row(chan, 3, auto_stop)
            else
                self:set_row(chan, 3)
            end
            self:outlet(1, "list", {chan, "rec", 1})
            self:outlet(1, "list", {chan, "play", 0})
        end,
        [state.playing] = function(chan, row, prev_state, pressed_row)
            self:set_row(chan, 0)
            if prev_state == state.stop_rec_cue then
                self:outlet(1, "list", {chan, "rec", 0})
            end
            local prev_slice = nil
            local curr_slice = row / self.n_col

            if pressed_row ~= nil then
                local reversed = false
                prev_slice = pressed_row / self.n_col

                -- the 2nd press is an early slice, so we must play in reverse
                if row < pressed_row then
                    self:outlet(1, "list", {chan, "reverse", 1})
                    reversed = true
                else
                    self:outlet(1, "list", {chan, "reverse", 0})
                end

                if reversed then
                    prev_slice = prev_slice + (1 / self.n_col)
                else
                    curr_slice = curr_slice + (1 / self.n_col)
                end
                self:outlet(1, "list", {chan, "range", prev_slice, curr_slice - prev_slice})
                self:outlet(1, "list", {chan, "play", 1, 0})
            else
                self:outlet(1, "list", {chan, "range", 0, 1})
                self:outlet(1, "list", {chan, "play", 1, curr_slice})
            end
        end,
        [state.stop_cue] = function(chan)
            self:set_row(chan, 2)
        end,
        [state.rec_cue] = function(chan)
            self:set_row(chan, 4)
        end,
        [state.play_cue] = function(chan)
            self:set_row(chan, 6)
        end,
        [state.stop_rec_cue] = function(chan)
            self:set_row(chan, 6)
        end
    }
    self.chan_state = {}
    self.press_state = {}
    self.aux_press_state = {}
    self.bar_count = {}
    self.auto_stop_rec = {}
    self.n_row = 8
    self.n_col = 8
    self.grid_size = (self.n_row * self.n_col) - 1
    return true
end

function BDSM:in_2_float(velocity)
    if type(velocity) ~= "number" then return end
    self.last_vel = velocity
end

function BDSM:in_1_float(note)
    -- check if note is outside grid range
    if note < 0 or note > self.grid_size then
        self:process_aux_btn(note)
        return
    end

    -- find column and row values
    local col = note % self.n_col
    local row = math.floor(note / self.n_row)
    local pressed = self.press_state[row]

    -- populate / clear press_state acording to the velocity
    if self.last_vel > 0 then
        self.press_state[row] = col
    else
        self.press_state[row] = nil
    end
    -- if this input is not a note-on, return now
    if self.last_vel < 1 then return end

    -- assure that the current state is not nil
    if self.chan_state[row] == nil then
        self.chan_state[row] = state.off
    end

    local curr_state = self.chan_state[row]
    local new_state = 0

    -- if stop button is being held, check if it can work
    if self.aux_press_state[side.stop] == true and
        curr_state == state.playing
    then
        new_state = state.stop_cue
    else
        new_state = self.note_in_map[curr_state]
    end

    -- if rec_arm is being held and state is off, it will auto stop rec at X bars,
    -- depending on which col was pressed to record
    if self.aux_press_state[side.rec_arm] == true and
        curr_state == state.off
    then
        self.auto_stop_rec[row] = col + 1
        self.bar_count[row] = 0
    else
        self.auto_stop_rec[row] = 0
    end

    -- if new_state is valid, update and call the action for the new state
    if new_state ~= nil then
        self.chan_state[row] = new_state
        if self.action_map[new_state] ~= nil then
            self.action_map[new_state](row, col, curr_state, pressed)
        end
    end
end

function BDSM:in_3_bang()
    -- iterate through channels to check for waiting states
    for i=0,self.n_row-1 do
        local curr_state = self.chan_state[i]

        -- check auto rec stop for each channel
        -- if bar count reaches the threshold, curr_state should change to
        -- rec_stop_cue and the normal path should act normally
        if curr_state == state.rec and self.auto_stop_rec[i] > 0 then
            if self.bar_count[i] >= self.auto_stop_rec[i] - 1 then
                curr_state = state.stop_rec_cue
            else
                local light_on = (i*8) + self.bar_count[i]
                self.bar_count[i] = self.bar_count[i] + 1
                self:outlet(2, "list", {light_on, 5})
            end
        end

        local new_state = self.cue_map[curr_state]
        if new_state ~= nil then
            self.chan_state[i] = new_state
            if self.action_map[new_state] ~= nil then
                self.action_map[new_state](i, 0, curr_state)
            end
        end
    end
end

function BDSM:set_row(row, color, amount)
    local times = self.n_col - 1
    if amount ~= nil then
        times = amount - 1
    end
    local col_1 = row * self.n_row
    for i=0,times do
        self:outlet(2, "list", {col_1 + i, color})
    end
end

function BDSM:in_4_list(pair)
    local row = pair[1]
    local col = pair[2]
    if row == nil or col == nil then return end

    local curr_state = self.chan_state[row]
    if curr_state ~= nil and curr_state == state.playing then
        local last_slice = (col - 1) % 8
        local light_on = (row * self.n_row) + col
        local light_off = (row * self.n_row) + last_slice
        self:outlet(2, "list", {light_on, state.playing})
        self:outlet(2, "list", {light_off, state.off})
    end
end

function BDSM:in_1(sel)
    if sel == "reset" then
        for i=0,self.n_row - 1 do
            self.chan_state[i] = state.off
        end
    end
end

function BDSM:process_aux_btn(note)
    if self.last_vel > 0 then
        self.aux_press_state[note] = true
        self:outlet(2, "list", {note, 1})
    else
        self.aux_press_state[note] = nil
        self:outlet(2, "list", {note, 0})
    end
end