local grid_sampler = pd.Class:new():register("grid_sampler")

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

function grid_sampler:initialize(_, atoms)
    local home = os.getenv("HOME")
    package.path = home .. "/pd/core-lib/scripts/?.lua;" .. package.path
    self.inlets = 3
    self.outlets = 2

    self.transition_map = require("grid_sampler.transition-map")(state)
    self.action_map = require("grid_sampler.action-map")(self, state)
    self.pattern_action_map = require("grid_sampler.pattern-action-map")(self, state)
    self.player_param_map = require("grid_sampler.player-param-map")
    self.page_actions = {
        [0] = require("grid_sampler.page_0"),
        [1] = require("grid_sampler.page_1"),
        [2] = require("grid_sampler.page_2")
    }
    self.n_row = 8
    self.n_col = 8
    self.n_channels = atoms[1] or 7
    self.n_pat = 6
    self.n_pages = 4

    self.channels = {}
    self:reset_channels()

    self.recording_pat = nil
    self.patterns = {}
    self:reset_patterns()

    -- 6x6 io matrix
    self.io_matrix = {}
    for c=0,5 do
        self.io_matrix[c] = {}
        for r=0,5 do
            self.io_matrix[c][r] = 0
        end
    end

    self.aux_press_state = {}
    self.grid_size = (self.n_row * self.n_col) - 1

    self.current_page = 0

    return true
end

function grid_sampler:reset_channels()
    for i=0,self.n_channels-1 do
        self.channels[i] = {
            state = state.off,
            pressed = nil,
            sync = "hard_sync", -- "hard_sync" | "free"
            loop = 1,
            reverse = 0,
            is_recording = false, -- can't use state for verification
            auto_stop_bars = 0,
            recorded_bar_count = 0,
            start = 0
        }
    end
end

function grid_sampler:reset_patterns()
    for i=0,self.n_pat - 1 do
        self.patterns[i] = {
            state = state.off,
            sync = "free"
        }
    end
end

function grid_sampler:in_1_list(list)
    local note = list[1]
    local velocity = list[2]
    if note == nil or velocity == nil or note < 0 then return end

    if note > self.grid_size then
        self:process_aux_btn(note, velocity)

    elseif note >= 7*self.n_col then
        if velocity > 0 then self:set_page(note) end

    elseif self.page_actions[self.current_page] ~= nil then
        self.page_actions[self.current_page].action(self, state, side, note, velocity)
    end
end

function grid_sampler:in_2_bang()
    -- iterate through channels to check for waiting states
    for i=0,self.n_channels-1 do
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

        local new_state = self.transition_map[channel.sync].cue[curr_state]

        if new_state ~= nil then
            channel.state = new_state
            if self.action_map[new_state] ~= nil then
                self.action_map[new_state](i, 0)
            end
        end
    end
    for i=0,self.n_pat-1 do
        local pattern = self.patterns[i]
        local new_s = self.transition_map[pattern.sync].cue[pattern.state]
        if new_s ~= nil then
            pattern.state = new_s
            if self.pattern_action_map[new_s] ~= nil then
                self.pattern_action_map[new_s](i)
            end
        end
    end
end

-- play position feedback routed to lights - only works if page == 0
function grid_sampler:in_3_list(pair)
    if self.current_page ~= 0 then return end

    local row = pair[1]
    local col = pair[2]
    if row == nil or col == nil then return end
    local channel = self.channels[row]
    if channel == nil then return end

    local curr_state = channel.state
    if curr_state ~= nil and curr_state == state.playing then
        local last_slice = (col - 1) % self.n_col
        local light_on = (row * self.n_col) + col
        local light_off = (row * self.n_col) + last_slice
        self:outlet(2, "list", {light_on, state.playing})
        self:outlet(2, "list", {light_off, state.off})
    end
end

-- assorted functions

function grid_sampler:set_row(row, color, amount)
    local times = self.n_col - 1
    if amount ~= nil then
        times = amount - 1
    end
    local col_1 = row * self.n_col
    for i=0,times do
        self:outlet(2, "list", {col_1 + i, color})
    end
end

function grid_sampler:clear_lights()
    for i=0,self.n_channels-1 do
        self:set_row(i, 0)
    end
end

function grid_sampler:process_aux_btn(note, velocity)
    if velocity > 0 then
        self.aux_press_state[note] = true
        self:outlet(2, "list", {note, 1})
    else
        self.aux_press_state[note] = nil
        self:outlet(2, "list", {note, 0})
    end
end

function grid_sampler:set_page(button)
    local col = button % self.n_col
    if col > self.n_pages-1 then return end

    self:outlet(2, "list", {self.current_page + 7*self.n_col, state.stopped}) -- green
    self.current_page = col
    self:outlet(2, "list", {self.current_page + 7*self.n_col, state.playing}) -- yellow

    self:clear_lights()
    local page = self.page_actions[self.current_page]
    if page ~= nil and page.init ~= nil then
        page.init(self)
    end
end

function grid_sampler:in_1_reset()
    self:reset_channels()
end

function grid_sampler:find_next_state(curr_state, is_sync)
    local new_state
    if self.aux_press_state[side.stop] == true and
        curr_state == state.playing
    then
        if is_sync == "free" then
            new_state = state.stopped
        elseif is_sync == "hard_sync" then
            new_state = state.stopped
        end
    else
        new_state = self.transition_map[is_sync].note_in[curr_state]
    end
    return new_state
end

-- control messages that must be forwarded:

function grid_sampler:in_1_sync(atoms)
    local chan = atoms[1]
    local onoff = atoms[2]
    local channel = self.channels[chan]
    if channel == nil then return end
    -- 0 = free, 1 = hard_sync
    local types = {"free", "hard_sync"}
    channel.sync = types[onoff+1]

    self:outlet(1, "list", {chan, "sync", onoff})
end

function grid_sampler:in_1_clear(atoms)
    local chan = atoms[1]
    local channel = self.channels[chan]
    if channel == nil then return end
    channel.state = state.off
    channel.auto_stop_bars = 0
    channel.recorded_bar_count = 0

    self:outlet(1, "list", {chan, "clear"})
    self:set_row(chan, state.off)
end

function grid_sampler:in_1_reverse(atoms)
    local chan = atoms[1]
    local channel = self.channels[chan]
    if channel == nil then return end

    local rev = atoms[2]
    channel.reverse = rev
    self:outlet(1, "list", {chan, "reverse", rev});
end

function grid_sampler:in_1_load(atoms)
    local chan = atoms[1]
    local channel = self.channels[chan]
    if channel == nil then return end
    channel.state = state.stopped
    self.action_map[state.stopped](chan)
    self:outlet(1, "list", {chan, "load"})
end

function grid_sampler:in_1(sel, atoms)
    -- expects <command> <chan> <...args>
    -- rearrange to fit a [clone] message like:
    -- <chan> <command> <...args>
    local msg = {atoms[1], sel}
    for i=2,#atoms do
        table.insert(msg, atoms[i])
    end
    self:outlet(1, "list", msg)
end
