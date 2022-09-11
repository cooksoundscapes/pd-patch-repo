local slice_control = pd.Class:new():register("slice_control")

local REC_ARM = 84

local states = {
    playing = 1,
    play_cue = 2,
    recording = 3,
    rec_cue = 4
}

function slice_control:initialize(sel, atoms)
    self.inlets = 2
    self.outlets = 2
    self.rec_btn_pressed = 0
    self.last = {}
    self.rec_state = {}
    return true
end

function slice_control:in_1_list(button)
    if #button ~= 2 then
        self:error("not a midi note!")
    elseif button[1] == REC_ARM then
        self.rec_btn_pressed = button[2]
        self:outlet(1, "list", {REC_ARM, button[2]})
    elseif button[1] < 0 or button[1] > 63 then
        self:error("not a grid button!")
    elseif button[2] > 0 then --> note on
        local row = math.floor(button[1] / 8)
        local column = button[1] % 8
        if self.rec_btn_pressed == 0 then
            self:outlet(2, "list", {column, "play", 1, row / 8})
        else
            if self.rec_state[column] == nil or self.rec_state[column] == states.playing then
                self.rec_state[column] = states.rec_cue
            elseif self.rec_state[column] == states.rec_cue then
                self.rec_state[column] = states.playing
            elseif self.rec_state[column] == states.recording then
                self.rec_state[column] = states.play_cue
            end
        end
    end
end

function slice_control:in_2_list(play_position)
    if #play_position ~= 2 then
        self:error("not a playing position!")
        return
    end
    if play_position[1] < 0 or play_position[1] > 7 then
        self:error("track outside grid range")
        return
    end

    local button = math.floor(play_position[2]*8)*8 + play_position[1]
    local col_state = self.rec_state[play_position[1]]
    if col_state == nil then col_state = 1 end

    if button ~= self.last[play_position[1]] then
        self:outlet(1, "list", {button, col_state})
        if self.last[play_position[1]] ~= nil then
            self:outlet(1, "list", {self.last[play_position[1]], 0})
        end
        self.last[play_position[1]] = button
    end
end

function slice_control:in_2_bang() --> resolve cues
    for c = 0, 7 do
        if self.rec_state[c] == states.rec_cue then
            self.rec_state[c] = states.recording
            self.outlet(2, "list", {c, "pattern-rec", 1})
        elseif self.rec_state[c] == states.play_cue then
            self.rec_state[c] = states.playing
            self.outlet(2, "list", {c, "pattern-rec", 0})
        end
    end
end
