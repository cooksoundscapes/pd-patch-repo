local grid_control = pd.Class:new():register("grid_control")

local APC = {
    up=64,
    down=65,
    left=66,
    right=67,
    volume=68,
    pan=69,
    send=70,
    device=71,
    clip_stop=82,
    solo=83,
    rec_arm=84,
    mute=85,
    select=86,
    user_1=87,
    user_2=88,
    stop_all=89,
    shift=98,
    green=1,
    blink_green=2,
    red=3,
    blink_red=4,
    yellow=5,
    blink_yellow=6,
    fader_1=48
}

local states = {
    empty=0,
    stopped=APC.green,
    armed=APC.red,
    playing=APC.yellow,
    pattern_rec=APC.blink_red,
    audio_rec=APC.red,
    play_cue=APC.blink_green,
    stop_cue=APC.blink_yellow,
    rec_cue=APC.blink_red
}

function grid_control:initialize(sel, atoms)
    self.inlets = 1
    self.outlets = 2
    self.selected_track = 1
    -- 1st argument sets number or columns / tracks. Defaults to 8;
    if type(atoms[1]) == "number" and atoms[1] > 0 then
        self.columns = atoms[1]
    else
        self.columns = 8
    end
    -- 2nd argument defines the track selection Row. Defaults to 7;
    if type(atoms[2]) == "number" and atoms[2] >= 0 then
        self.track_row = atoms[2]
    else
        self.track_row = 7
    end
    self.mode = "samples"
    self.state = {
        samples={},
        patterns={}
    }
    return true
end

function grid_control:in_1(sel, atoms)
    local switch = {
        ["bang"] = function() pd.post("bang!") end,
        ["cu"] = function() pd.post("CU!") end
    }
    switch[sel]()
end
--[[
function grid_control:postinitialize()
    pd.post("Starting Grid Control in 'Samples' mode.")
    -- track selection row light to green;
    local offset = self.columns * self.track_row
    for i = 0, self.columns-1, 1 do
        self:outlet(2, "list", { i+offset, APC.green })
    end
end
--]]
function grid_control:finalize()
   pd.post("Turning the lights off.")
end

function grid_control:in_1_list(btn)
    if #btn ~= 2 then
        pd.post("[Grid Control] Not a midi note!")
        return
    end
    if btn[2] > 0 then -- note on
        local row = btn[1] / self.columns
        local column = btn[1] % self.columns
        -- track selection
        if row == self.track_row then
            self:outlet(2, "list", { self.selected_track+self.columns*self.track_row, APC.green })
            self:outlet(2, "list", { btn[1], APC.yellow })
            this.selected_track = row
        -- ...or process state for that slot
        else
            if self.mode == "samples" then
                local state = self.state.samples[btn[1]]
                -- if empty, cue for recording (depends on metronome)
                if state == "nil" or state == state.rec_cue then
                    self.state.samples[btn[1]] = state.rec_cue
                    self:outlet(1, "rec_cue", {})
                    self:outlet(2, "list", {btn[1], state.rec_cue})
                -- if rec cue, cancel 
                elseif state == state.rec_cue then
                    self.state.samples[btn[1]] = state.empty
                    self:outlet(1, "stop", {})
                    self:outlet(2, "list", {btn[1], state.empty})
                -- if recording, cue for playing
                elseif state == state.audio_rec then
                    self.state.samples[btn[1]] = state.play_cue
                    self:outlet(1, "play", {})
                    self:outlet(2, "list", {btn[1], state.play_cue})
                -- if playing, cue for stop
                elseif state == state.playing then
                    self.state.samples[btn[1]] = state.stop_cue
                    self:outlet(1, "stop", {})
                    self:outlet(2, "list", {btn[1], state.stop_cue})
                end

            end
        end
    end
end
