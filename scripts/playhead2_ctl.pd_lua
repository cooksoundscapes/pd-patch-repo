local playhead2_ctl = pd.Class:new():register("playhead2_ctl")

function playhead2_ctl:initialize()
    self.inlets = 2
    self.outlets = 4
    self.speed = 1
    self.size = 0
    self.reverse = 0
    self.smp_rate = 48
    self.duration = 0
    self.playing = 0
    self.trim_start = 0
    self.trim_end = 1
    self.loop = 1
    self.rec_state = 0
    self.retrig_timer = pd.Clock:new():register(self, "retrigger")
    return true
end

function playhead2_ctl:finalize()
    self.retrig_timer:destruct()
end

-- retrig_timer registered call
function playhead2_ctl:retrigger()
    if self.loop > 0 and self:is_playing() then
        self:outlet(1, "float", {self.reverse})
        self:outlet(1, "list", {1-self.reverse, self.duration})
        self.retrig_timer:delay(self.duration)
    else
        self.playing = 0
    end
end

-- internal methods

function playhead2_ctl:set_duration(temp_length)
    self.duration = (self.size / self.smp_rate) * self.speed * (temp_length or self.trim_end)
    if self:is_playing() then
        self:outlet(4, "bang", {}) --attempt to snapshot current vline~ value 
    end
end

function playhead2_ctl:output_size(s, l)
    self:outlet(3, "float", {self.size * (s or self.trim_start) + 1})
    self:outlet(2, "float", {self.size * (l or self.trim_end) - 2})
end

function playhead2_ctl:play(level, phase)
    self.playing = level
    self.paused_at = nil
    self:outlet(1, "stop", {})
    self.retrig_timer:unset()
    if level > 0 and self.rec_state == 0 then
        self:outlet(1, "float", {phase})
        local remaining = self:get_remaining(phase)
        self:outlet(1, "list", {1 - self.reverse, remaining})
        self.retrig_timer:delay(remaining)
    else
        self:outlet(1, "float", {0})
    end
end

-- if delay > 0 it will be passed as the 3rd argument for the vline~ message,
-- and the ramp will not immediately stop.
-- that means that the next ramp will occur with a <delay> ms of delay
function playhead2_ctl:resume_from(from, delay)
    delay = delay or 0
    local remaining = self:get_remaining(from)
    if delay > 0 then
        self:outlet(1, "list", {1 - self.reverse, remaining, delay})
    else
        self:outlet(1, "stop", {})
        self:outlet(1, "list", {1 - self.reverse, remaining})
    end
    self.retrig_timer:unset()
    self.retrig_timer:delay(remaining + delay)
end

function playhead2_ctl:get_remaining(offset)
    return self.duration * math.abs((1-self.reverse) - offset)
end

function playhead2_ctl:is_playing()
    return self.playing > 0 and self.paused_at == nil
end

-- exposed inlets

function playhead2_ctl:in_2_float(snapshot)
    if self.seeking ~= nil then
        -- self.seeking is the desired location;
        -- we must calculate time based on snapshot and seek position
        local time =  math.sqrt(math.abs(snapshot - self.seeking)) * self.max_seek_time
        self.retrig_timer:unset()
        self:outlet(1, "stop", {})
        self:outlet(1, "list", {self.seeking, time})
        if self:is_playing() then
            self:resume_from(self.seeking, time)
        end
        self.seeking = nil
    elseif self.cueing ~= nil then
        self.retrig_timer:unset()
        self:outlet(1, "stop", {})
        local dest = math.max(0, math.min(1, snapshot + self.cueing))
        self:outlet(1, "list", {dest, self.cue_time})
        if self:is_playing() then
            self:resume_from(dest, self.cue_time)
        end
        self.cueing = nil
    elseif self.pausing == true then
        self.pausing = nil
        self.retrig_timer:unset()
        self.paused_at = snapshot
        self:outlet(1, "stop", {})
    elseif self:is_playing() then
        self:resume_from(snapshot)
    end
end

function playhead2_ctl:in_1_size(atoms)
    local s = atoms[1]
    self.size = s
    self:set_duration()
    self:output_size()
end

function playhead2_ctl:in_1_speed(atoms)
    local s = atoms[1]
    if s <= 0 then self.speed = 0
    else self.speed = 1 / s
    end
    self:set_duration()
end

function playhead2_ctl:in_1_reverse(atoms)
    local r = atoms[1]
    self.reverse = r
    self:set_duration()
end

function playhead2_ctl:in_1_loop(atoms)
    local l = atoms[1]
    self.loop = l
end

function playhead2_ctl:in_1_trim_start(atoms)
    local t = atoms[1]
    self.trim_start = math.max(math.min(t, 1), 0)
    local diff = 1 - (self.trim_end + t)
    local temp_length = self.trim_end
    if diff < 0 then
        temp_length = math.max(math.min(self.trim_end + diff, 1), 0)
    end
    self:set_duration(temp_length)
    self:output_size(nil, temp_length)
end

function playhead2_ctl:in_1_trim_end(atoms)
    local t = atoms[1]
    self.trim_end = math.max(math.min(t, 1 - self.trim_start), 0)
    self:set_duration()
    self:outlet(2, "float", {self.trim_end * self.size})
end

function playhead2_ctl:in_1_seek(atoms)
    if self.rec_state ~= 0 then return end
    local phase = atoms[1]
    local time = atoms[2] or 100
    self.seeking = phase
    self.max_seek_time = time
    self:outlet(4, "bang", {})
end

function playhead2_ctl:in_1_cue(atoms)
    if self.rec_state ~= 0 then return end
    local offset = atoms[1]
    local time = atoms[2]
    self.cueing = offset
    self.cue_time = time
    self:outlet(4, "bang", {})
end

function playhead2_ctl:in_1_pause(atoms)
    if self.playing == 0 or self.rec_state ~= 0 then return end

    local p = atoms[1]
    if p > 0 then
        self.pausing = true
        self:outlet(4, "bang", {})
    elseif self.paused_at ~= nil then
        self:resume_from(self.paused_at)
        self.paused_at = nil
    end
end

function playhead2_ctl:in_1_rec_state(atoms)
    local s = atoms[1]
    if type(s) ~= "number" then return end
    self.rec_state = s
    self:play(0, 0)
end

function playhead2_ctl:in_1_float(level)
    self:play(level, self.reverse)
end

function playhead2_ctl:in_1_list(atoms)
    local lvl = atoms[1]
    local phase = atoms[2] or self.reverse
    if lvl == nil or phase == nil then return end
    self:play(lvl, phase)
end

-- catch all to avoid errors
function playhead2_ctl:in_1(_,_) end
