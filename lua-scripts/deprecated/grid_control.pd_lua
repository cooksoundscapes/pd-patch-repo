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


-------- aux functions ----------
local function slotToCoord(slot)
    local col = slot % 8
    local row = math.floor(slot / 8)
    return { col=col, row=row }
end
---------------------------------

function grid_control:initialize(sel, atoms)
    self.inlets = 2
    self.outlets = 2
    self.state = {}
    self.rec_arm = false
    self.mode = modes.free
    self.size = 7 * 8
    self.delete_delay = 1000
    self.state_actions = {
        [states.empty] = function() if self.rec_arm == true then return states.rec_cue end end,
        [states.stopped] = function() return states.play_cue end,
        [states.recording] = function() return states.play_cue end,
        [states.playing] = function() return states.stop_cue end,
        [states.rec_cue] = function() return states.empty end,
        [states.play_cue] = function() return states.stopped end,
        [states.stop_cue] = function() return states.playing end
    }
    self.deleteTimeout = pd.Clock:new():register(self, "deleteSlot")
    self.willDelete = -1 --> slot to be deleted
    return true
end

function grid_control:in_1_list(button)
    if #button ~= 2 then
        self:error("not a midi note!")
        return
    end
    if button[2] > 0 then --> note on
        if button[1] == APC.rec_arm then 

            self.rec_arm = not self.rec_arm
            self:outlet(1, "list", { APC.rec_arm, self.rec_arm and 1 or 0 })

        elseif button[1] >= 0 and button[1] < self.size then --> process state!
            local current_state = self.state[button[1]]
            self.willDelete = button[1]
            self.deleteTimeout:delay(self.delete_delay)

            if current_state == nil then --> button was never used
                if self.rec_arm == true then
                    self.state[button[1]] = states.rec_cue
                    self:outlet(1, "list", {button[1], states.rec_cue})
                end
            else
                local next_state = self.state_actions[current_state]()
                if self.mode == modes.columnsAsTracks then
                    local column = button[1] % 8
                    -- if other slot in that column is in play cue, stop it
                    if next_state == states.play_cue then
                        for i = 0, 7 do
                            if self.state[i*8+column] == states.play_cue then
                                self.state[i*8+column] = states.stopped
                                self:outlet(1, "list", {i*8+column, states.stopped})  
                            end
                        end
                    -- if other slot in that column is in rec_cue, set empty
                    elseif next_state == states.rec_cue then
                        for i = 0, 7 do
                            if self.state[i*8+column] == states.rec_cue then
                                self.state[i*8+column] = states.empty
                                self:outlet(1, "list", {i*8+column, states.empty})  
                            end
                        end
                    end
                end
                self.state[button[1]] = next_state
                self:outlet(1, "list", {button[1], next_state})
            end
        end
    else
        self.deleteTimeout:unset()
    end
end

function grid_control:in_2_bang() --> resolve cues
    for i = 0, self.size - 1 do
        local coord = slotToCoord(i)
        if self.state[i] == states.rec_cue then
            if self.mode == modes.columnsAsTracks then
                -- if a slot in that column is playing or recording, stop it
                for r=0, 7 do
                    local slot = r*8+coord.col
                    if self.state[slot] == states.playing 
                    or self.state[slot] == states.recording then
                        self.state[slot] = states.stopped
                        self:outlet(2, "list", {coord.col, "stop", r})
                        self:outlet(1, "list", {slot, states.stopped})
                    end
                end
            end
            self.state[i] = states.recording
            self:outlet(2, "list", {coord.col, "record", coord.row})
            self:outlet(1, "list", {i, states.recording})

        elseif self.state[i] == states.play_cue then
            if self.mode == modes.columnsAsTracks then
                -- if a slot in that column is playing, stop it now
                for r=0, 7 do
                    local slot = r*8+coord.col
                    if self.state[slot] == states.playing 
                    or self.state[slot] == states.recording then
                        self.state[slot] = states.stopped
                        self:outlet(2, "list", {coord.col, "stop", r})
                        self:outlet(1, "list", {slot, states.stopped})
                    end
                end
            end
            self.state[i] = states.playing 
            self:outlet(2, "list", {coord.col, "play", coord.row})
            self:outlet(1, "list", {i, states.playing})

        elseif self.state[i] == states.stop_cue then
            self.state[i] = states.stopped
            self:outlet(2, "list", {coord.col, "stop", coord.row})
            self:outlet(1, "list", {i, states.stopped})
        end
    end
end

function grid_control:in_2_flush()    
    for i = 0, self.size - 1 do
        if self.state[i] ~= nil then
            self:outlet(1, "list", {i, self.state[i]})
        end
    end
    self:outlet(1, "list", {APC.rec_arm, self.rec_arm and 1 or 0})
end

function grid_control:in_2_reset()
    for i = 0, self.size - 1 do
        local coord = slotToCoord(i)
        self:outlet(2, "list", {coord.col, "delete", coord.row })
        self:outlet(1, "list", {i, 0})
    end
    self.rec_arm = false
    self:outlet(1, "list", {APC.rec_arm, 0})
end

function grid_control:in_2_set(atoms)
    local newState = states[atoms[2]]
    if newState ~= nil and atoms[1] >= 0 and atoms[1] < self.size then
        self.state[atoms[1]] = newState
        self:outlet(1, "list", {atoms[1], newState})
    else 
        self:error(string.format("State %s doesn't exists.", atoms[2]))
    end
end

function grid_control:in_2_mode(atoms)            
    local newMode = modes[atoms[1]]
    if newMode ~= nil then
        self.mode = newMode
        pd.post(string.format("Mode set to %s.", atoms[1]))
    else 
        self:error(string.format("Mode %s doesn't exists.", atoms[1]))
    end
end

function grid_control:deleteSlot()
    local coord = slotToCoord(self.willDelete)
    self:outlet(2, "list", {coord.col, "delete", coord.row})
    self:outlet(1, "list", {self.willDelete, 0})
    self.state[self.willDelete] = states.empty
end

function grid_control:finalize()
    self.deleteTimeout:destruct()
end
