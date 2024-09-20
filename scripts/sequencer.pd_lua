local time = require("lib.time")
local sequencer = pd.Class:new():register("sequencer")

function sequencer:initialize(_,atoms)
    local min, max
    if #atoms >= 2 then
        min = atoms[1]
        max = atoms[2]
    elseif #atoms == 1  then
        min = 0
        max = atoms[1]
    else
        min = 0
        max = 127
    end
    self.range = {min, max}
    self.inlets = 2
    self.outlets = 2
    self.recording = false
    self.playing = false
    self.seq = {}
    self.epoch = 0
    self.curr = 0
    self.loop = true
    self.clock = pd.Clock:new():register(self, "start")
    return true
end

function sequencer:time()
    return time.gettime()
end

function sequencer:difftime()
    return time.gettime() - self.epoch
end

function sequencer:in_2_rec()
    self:in_2_clear()
    self.recording = true
    self.epoch = self:time()
    self:outlet(2, "rec", {1})
end

function sequencer:finalize()
    self.clock:destruct()
end

function sequencer:in_1_list(pair)
    if self.recording == false or
        pair[1] < self.range[1] or
        pair[1] > self.range[2]
    then return end
    local t = self:difftime()
    table.insert(self.seq, {t, pair[1], pair[2]})
    self.epoch = self:time()
end

function sequencer:in_2_stop()
    if self.recording == true then
        self.recording = false
        local t = self:difftime()
        table.insert(self.seq, {t, "end"})
        self:outlet(2, "rec", {0})

    elseif self.playing == true then
        self.playing = false
        self.clock:unset()
        self:outlet(2, "play", {0})
        self.curr = 0
    end
end

function sequencer:in_2_loop(atoms)
    local onoff = atoms[1]
    if type(onoff) ~= "number" then return end
    self.loop = onoff > 0
end

function sequencer:in_2_play()
    if self.recording == true then
        self:in_2_stop()
    end
    if #self.seq < 1 then return end

    self.playing = true
    self:outlet(2, "play", {1})
    self:start()
end

function sequencer:in_2_clear()
    self:in_2_stop()
    for i=1,#self.seq do
        self.seq[i] = nil
    end
end

function sequencer:start()
    local curr = self.seq[self.curr]
    local next = self.seq[self.curr + 1]
    if curr ~= nil then
        self:outlet(1, "list", {curr[2], curr[3]})
    end

    if next ~= nil then
        self.clock:delay(next[1])
        self.curr = self.curr + 1
    else
        if self.loop == true then
            self.curr = 1
            self.clock:delay(self.seq[1][1])
        else
            self:in_2_stop()
        end
    end
end
