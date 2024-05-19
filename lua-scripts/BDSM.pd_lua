-- stands for Binary Damage State Machine
local BDSM = pd.Class:new():register("BDSM")

--[[
    INLET 1 receives MIDI note pair & messages
    INLET 2 receives cue bang for resolving waiting states
    INLET 3 cooks playing position and updates the grid lights, per channel
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
    self.inlets = 3
    self.outlets = 2
    --[[
        note_in sets the new chan_state on a note_in
        cue map sets the a new state on every channel if due
    ]]
    self.mappings = {
        hard_sync = {
            note_in = {
                [state.off] = state.rec_cue,
                [state.stopped] = state.play_cue,
                [state.rec] = state.stop_rec_cue,
                [state.rec_cue] = state.off,
            },
            cue = {
                [state.stop_cue] = state.stopped,
                [state.rec_cue] = state.rec,
                [state.play_cue] = state.playing,
                [state.stop_rec_cue] = state.playing
            }
        },
        free = {
            note_in = {
                [state.off] = state.rec,
                [state.stopped] = state.playing,
                [state.playing] = state.playing,
                [state.rec] = state.playing,
            },
            cue = {}
        }
    }
    -- when the channel is set to [state], this is what happens
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
            local channel = self.channels[chan]
            if channel.auto_stop_bars > 0 then
                self:set_row(chan, 0)
                self:set_row(chan, 3, channel.auto_stop_bars)
            else
                self:set_row(chan, 3)
            end
            channel.is_recording = true
            self:outlet(1, "list", {chan, "rec", 1})
            self:outlet(1, "list", {chan, "play", 0})
        end,
        [state.playing] = function(chan, row, pressed_row)
            self:set_row(chan, 0)
            local channel = self.channels[chan]

            -- stop rec in case it's on
            if channel.is_recording == true then
                channel.is_recording = false
                self:outlet(1, "list", {chan, "rec", 0})
            end
            local prev_slice = nil
            local curr_slice = row / self.n_col

            -- if channel is playing backwards, slice actually starts in the end of the slice
            if channel.reverse > 0 then
                curr_slice = curr_slice + 1/self.n_col
            end

            -- apply range + reverse if track is synced and 2 buttons were pressed
            if pressed_row ~= nil and channel.sync > 0 then
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
                channel.start = prev_slice
                channel.length = curr_slice - prev_slice
                self:outlet(1, "list", {chan, "range", channel.start, channel.length})
                self:outlet(1, "list", {chan, "play", 1, 0})
            else
                channel.start = 0
                if channel.sync > 0 then
                    channel.length = 1
                    self:outlet(1, "list", {chan, "range", 0, 1})
                    self:outlet(1, "list", {chan, "play", 1, curr_slice})
                else
                    self:outlet(1, "list", {chan, "range", curr_slice, channel.length})
                    self:outlet(1, "list", {chan, "play", 1, 0})
                end
            end
        end,
        [state.stop_cue] = function(chan)
            self:set_row(chan, 2)
        end,
        [state.rec_cue] = function(chan)
            local channel = self.channels[chan]
            if channel.auto_stop_bars > 0 then
                self:set_row(chan, 4, channel.auto_stop_bars)
            else
                self:set_row(chan, 4)
            end
        end,
        [state.play_cue] = function(chan)
            self:set_row(chan, 6)
        end,
        [state.stop_rec_cue] = function(chan)
            self:set_row(chan, 6)
        end
    }
    self.n_row = 8
    self.n_col = 8

    self.channels = {}
    self:reset_channels()

    self.aux_press_state = {}
    self.grid_size = (self.n_row * self.n_col) - 1

    return true
end

function BDSM:reset_channels()
    for i=0,self.n_row-1 do
        self.channels[i] = {
            state = state.off,
            pressed = nil,
            sync = 1,
            is_recording = false,
            auto_stop_bars = 0,
            recorded_bar_count = 0,
            reverse = 0,
            start = 0,
            length = 1
        }
    end
end

function BDSM:in_1_list(list)
    local note = list[1]
    local velocity = list[2]
    if note == nil or velocity == nil then return end
    -- check if note is outside grid range
    if note < 0 or note > self.grid_size then
        self:process_aux_btn(note, velocity)
        return
    end

    -- find column and row values
    local col = note % self.n_col
    local row = math.floor(note / self.n_row)

    local channel = self.channels[row]

    -- retrieve current pressed button in the row
    local pressed = channel.pressed

    -- update / clear row's press_state acording to the velocity
    if velocity > 0 then
        channel.pressed = col
    else
        channel.pressed = nil
    end

    -- if this input is not a note-on, return now
    if velocity < 1 then return end

    local curr_state = channel.state
    local new_state = 0

    -- if stop button is being held, check if it can work
    if self.aux_press_state[side.stop] == true and
        curr_state == state.playing
    then
        if channel.sync == true then
            new_state = state.stop_cue
        else
            new_state = state.stopped
        end
    else
        if channel.sync > 0 then
            new_state = self.mappings.hard_sync.note_in[curr_state]
        else
            new_state = self.mappings.free.note_in[curr_state]
        end
    end

    -- if rec_arm is being held and state is off, it will auto stop rec at X bars,
    -- depending on which col was pressed to record
    if self.aux_press_state[side.rec_arm] == true and
        curr_state == state.off
    then
        channel.auto_stop_bars = col + 1
        channel.recorded_bar_count = 0
    else
        channel.auto_stop_bars = 0
    end

    -- if new_state is valid, update and call the action for the new state
    if new_state ~= nil then
        channel.state = new_state
        if self.action_map[new_state] ~= nil then
            self.action_map[new_state](row, col, pressed)
        end
    end
end

function BDSM:in_2_bang()
    -- iterate through channels to check for waiting states
    for i=0,self.n_row-1 do
        local channel = self.channels[i]
        local curr_state = channel.state
        -- check auto rec stop
        -- if bar count reaches the threshold, curr_state should change to
        -- rec_stop_cue and the normal path should act normally
        if curr_state == state.rec and channel.auto_stop_bars > 0 then
            if channel.recorded_bar_count >= channel.auto_stop_bars - 1 then
                curr_state = state.stop_rec_cue
            else
                local light_on = (i*8) + channel.recorded_bar_count
                channel.recorded_bar_count = channel.recorded_bar_count + 1
                self:outlet(2, "list", {light_on, 5})
            end
        end

        local new_state
        if channel.sync > 0 then
            new_state = self.mappings.hard_sync.cue[curr_state]
        else
            new_state = self.mappings.free.cue[curr_state]
        end

        if new_state ~= nil then
            channel.state = new_state
            if self.action_map[new_state] ~= nil then
                self.action_map[new_state](i, 0)
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

-- play position feedback routed to lights
function BDSM:in_3_list(pair)
    local row = pair[1]
    local col = pair[2]
    if row == nil or col == nil then return end
    local channel = self.channels[row]
    if channel == nil then return end

    local curr_state = channel.state
    if curr_state ~= nil and curr_state == state.playing then
        local last_slice = (col - 1) % 8
        local light_on = (row * self.n_row) + col
        local light_off = (row * self.n_row) + last_slice
        self:outlet(2, "list", {light_on, state.playing})
        self:outlet(2, "list", {light_off, state.off})
    end
end

function BDSM:in_1_reset()
    self:reset_channels()
end

function BDSM:in_1_sync(atoms)
    local chan = atoms[1]
    local onoff = atoms[2]
    local channel = self.channels[chan]
    if channel == nil then return end
    channel.sync = onoff
    self:outlet(1, "list", {chan, "sync", onoff})
end

function BDSM:in_1_clear(atoms)
    local chan = atoms[1]
    local channel = self.channels[chan]
    if channel == nil then return end
    channel.state = state.off
    channel.auto_stop_bars = 0
    channel.recorded_bar_count = 0

    self:outlet(1, "list", {chan, "play", 0})
    self:set_row(chan, state.off)
end

function BDSM:in_1_reverse(atoms)
    local chan = atoms[1]
    local channel = self.channels[chan]
    if channel == nil then return end

    local rev = atoms[2]
    channel.reverse = rev
    self:outlet(1, "list", {chan, "reverse", rev});
end

-- for now, this is just "passing trough" the info
function BDSM:in_1_length(atoms)
    local chan = atoms[1]
    local channel = self.channels[chan]
    if channel == nil then return end

    local length = atoms[2]
    channel.length = length
    self:outlet(1, "list", {chan, "range", channel.start, length})
end

function BDSM:process_aux_btn(note, velocity)
    if velocity > 0 then
        self.aux_press_state[note] = true
        self:outlet(2, "list", {note, 1})
    else
        self.aux_press_state[note] = nil
        self:outlet(2, "list", {note, 0})
    end
end
