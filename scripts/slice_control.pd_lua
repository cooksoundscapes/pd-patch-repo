local slice_control = pd.Class:new():register("slice_control")

function slice_control:initialize(sel, atoms)
    self.inlets = 2
    self.outlets = 2
    self.last = {}
    return true
end

function slice_control:in_1_list(button)
    if #button ~= 2 then
        self:error("not a midi note!")
        return
    end
    if button[1] < 0 or button[1] > 63 then
        self:error("not a grid button!")
        return
    end
    if button[2] > 0 then --> note on
        local row = math.floor(button[1] / 8)
        local column = button[1] % 8
        self:outlet(2, "list", {column, "play", 1, row / 8})
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

    if button ~= self.last[play_position[1]] then
        self:outlet(1, "list", {button, 1})
        if self.last[play_position[1]] ~= nil then
            self:outlet(1, "list", {self.last[play_position[1]], 0})
        end
        self.last[play_position[1]] = button
    end
end
