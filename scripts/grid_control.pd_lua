local grid_control = pd.Class:new():register("grid_control")

local APC = { up=64, down=65, left=66, right=67, volume=68, pan=69, send=70, device=71, clip_stop=82,
    solo=83, rec_arm=84, mute=85, select=86, user_1=87, user_2=88, stop_all=89, shift=98, green=1, 
    blink_green=2, red=3, blink_red=4, yellow=5, blink_yellow=6, fader_1=48 }

local states = {
    empty=0,
    stopped=APC.green,
    playing=APC.yellow,
    recording=APC.red,
    play_cue=APC.blink_yellow,
    stop_cue=APC.blink_green,
    rec_cue=APC.blink_red
}

local modes = {
    free = 0,
    columnsAsTracks = 1
}

function grid_control:initialize(sel, atoms)
    self.inlets = 2
    self.outlets = 1
    self.state = {}
    self.rec_armed = 0
    self.mode = modes.free
    self.state_actions = {
        [states.empty] = function() if self.rec_armed == 1 then return states.rec_cue end end,
        [states.stopped] = function() return states.play_cue end,
        [states.recording] = function() return states.play_cue end,
        [states.playing] = function() return states.stop_cue end,
        [states.rec_cue] = function() return states.empty end,
        [states.play_cue] = function() return states.stopped end,
        [states.stop_cue] = function() return states.playing end
    }
    return true
end

function grid_control:in_1_list(button)
    if #button ~= 2 then
        pd.post("[grid-control]: Not a midi note!")
        return
    end
    if button[2] > 0 then --> note on
        if button[1] == APC.rec_arm then 
            if self.rec_armed == 0 then
                self.rec_armed = 1
            else
                self.rec_armed = 0
            end 
            self:outlet(1, "list", { APC.rec_arm, self.rec_armed })

        elseif button[1] >= 0 and button[1] <= 63 then --> process state!
            local current_state = self.state[button[1]]

            if current_state == nil then --> button was never used
                if self.rec_armed == 1 then
                    self.state[button[1]] = states.rec_cue
                    self:outlet(1, "list", {button[1], states.rec_cue})
                end
            else
                local next_state = self.state_actions[current_state]()
                if self.mode == modes.columnsAsTracks and next_state == states.play_cue then
                    -- if other slot in that column is in play cue, stop it
                    local column = button[1] % 8
                    for i = 0, 7 do
                        if self.state[i*8+column] == states.play_cue then
                            self.state[i*8+column] = states.stopped
                            self:outlet(1, "list", {i*8+column, states.stopped})  
                        end
                    end
                end
                self.state[button[1]] = next_state
                self:outlet(1, "list", {button[1], next_state})
            end
        end
    end
end

function grid_control:in_2(sel, atoms)
    if sel == "bang" then --> resolve all cues
        for i = 0, 63 do --> traverse all grid
            if self.state[i] == states.rec_cue then
                self.state[i] = states.recording
                self:outlet(1, "list", {i, states.recording})
            elseif self.state[i] == states.play_cue then
                if self.mode == modes.columnsAsTracks then
                    -- if a slot in that column is playing, stop it now
                    local column = i % 8
                    for c=0, 7 do
                        if self.state[c*8+column] == states.playing then
                            self.state[c*8+column] = states.stopped
                            self:outlet(1, "list", {c*8+column, states.stopped})  
                        end
                    end
                end
                self.state[i] = states.playing 
                self:outlet(1, "list", {i, states.playing})
            elseif self.state[i] == states.stop_cue then
                self.state[i] = states.stopped
                self:outlet(1, "list", {i, states.stopped})
            end
        end
    elseif sel == "flush" then --> output all saved state
        for i = 0, 63 do
            self:outlet(1, "list", i, self.state[i])
        end
    elseif sel == "set" then
        local newState = states[atoms[2]]
        if newState ~= nil and atoms[1] >= 0 and atoms[1] <= 63 then
            self.state[atoms[1]] = newState
            self:outlet(1, "list", {atoms[1], newState})
        else 
            self:error(string.format("State $s doesn't exists.", atoms[2]))
        end
    elseif sel == "mode-set" then
        local newMode = modes[atoms[1]]
        if newMode ~= nil then
            self.mode = newMode
            pd.post(string.format("Mode set to %s.", atoms[1]))
        else 
            self:error(string.format("Mode %s doesn't exists.", atoms[1]))
        end
    end
end
