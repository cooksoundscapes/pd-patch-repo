local playhead_ctl = pd.Class:new():register("playhead_ctl")

function playhead_ctl:initialize()
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
    self.retrig_timer = pd.Clock:new():register(self, "retrigger")
    return true
end

function playhead_ctl:finalize()
    self.retrig_timer:destruct()
end

-- retrig_timer registered call
function playhead_ctl:retrigger()
    if self.loop > 0 and self.playing > 0 then
        self:outlet(1, "float", {self.reverse})
        self:outlet(1, "list", {1-self.reverse, self.duration})
        self.retrig_timer:delay(self.duration)
    else
        self.playing = 0
    end
end

-- internal methods

function playhead_ctl:set_duration(temp_length)
    self.duration = (self.size / self.smp_rate) * self.speed * (temp_length or self.trim_end)
    if self.playing > 0 then
        self:outlet(4, "bang", {}) --attempt to snapshot current vline~ value 
    end
end

function playhead_ctl:output_size(s, l)
    self:outlet(3, "float", {self.size * (s or self.trim_start) + 1})
    self:outlet(2, "float", {self.size * (l or self.trim_end) - 2})
end

function playhead_ctl:play(level, phase)
    self.playing = level
    self:outlet(1, "stop", {})
    self.retrig_timer:unset()
    if level > 0 then
        self:outlet(1, "float", {phase})
        local remaining = self:get_remaining(phase)
        self:outlet(1, "list", {1 - self.reverse, remaining})
        self.retrig_timer:delay(remaining)
    end
end

-- if delay > 0 it will be passed as the 3rd argument for the vline~ message,
-- and the ramp will not immediately stop.
-- that means that the next ramp will occur with a <delay> ms of delay
function playhead_ctl:resume_from(from, delay)
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

function playhead_ctl:get_remaining(offset)
    return self.duration * math.abs((1-self.reverse) - offset)
end

-- exposed inlets

function playhead_ctl:in_2_float(snapshot)
    if self.seeking ~= nil then
        -- self.seeking is the desired location;
        -- we must calculate time based on snapshot and seek position
        local time = math.sqrt(snapshot - self.seeking) * self.max_seek_time
        self.retrig_timer:unset()
        self:outlet(1, "stop", {})
        self:outlet(1, "list", {self.seeking, time})

        if self.playing > 0 then
            self:resume_from(snapshot, time)
        end
        self.seeking = nil
    elseif self.playing > 0 then
        self:resume_from(snapshot)
    end
end

function playhead_ctl:in_1_size(atoms)
    local s = atoms[1]
    self.size = s
    self:set_duration()
    self:output_size()
end

function playhead_ctl:in_1_speed(atoms)
    local s = atoms[1]
    if s <= 0 then self.speed = 0
    else self.speed = 1 / s
    end
    self:set_duration()
end

function playhead_ctl:in_1_reverse(atoms)
    local r = atoms[1]
    self.reverse = r
    self:set_duration()
end

function playhead_ctl:in_1_loop(atoms)
    local l = atoms[1]
    self.loop = l
end

function playhead_ctl:in_1_start(atoms)
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

function playhead_ctl:in_1_length(atoms)
    local t = atoms[1]
    self.trim_end = math.max(math.min(t, 1 - self.trim_start), 0)
    self:set_duration()
    self:outlet(2, "float", {self.trim_end * self.size})
end

function playhead_ctl:in_1_seek(atoms)
    local phase = atoms[1]
    local time = atoms[2]
    self.seeking = phase
    self.max_seek_time = time
    self:outlet(4, "bang", {})
end

function playhead_ctl:in_1_float(level)
    self:play(level, self.reverse)
end

function playhead_ctl:in_1_list(atoms)
    local lvl = atoms[1]
    local phase = atoms[2]
    if lvl == nil or phase == nil then return end
    self:play(lvl, phase)
end
