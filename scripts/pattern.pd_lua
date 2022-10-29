local pattern = pd.Class:new():register("pattern")

local socket = require "socket"

--auxiliar functions
local function quantize_table(self)
    if self.estimatedbpm > 0 then 
        local slice = self.estimatedbpm / self.quant
        for i = 1, #self.data do
            local note = self.data[i]
            local newtime = 0
            if note[2] == "end" or note[3] > 0 then
                newtime = slice * math.floor(note[1] / slice + 0.5)
            else
                newtime = slice * math.ceil(note[1] / slice + 0.5)
            end
            self.quantized[i] = { newtime, note[2], note[3] }
        end
        table.sort(self.quantized, function(a, b) 
            return a[1] < b[1]
        end)
    end
end

local function finish_record(self)
    table.insert(self.data, { socket.gettime() * 1000 - self.starttime, "end" })
    local length = self.data[#self.data][1]
    self.estimatedbpm = length
    while self.estimatedbpm > 800 do
        self.estimatedbpm = self.estimatedbpm / 2
    end
    if self.quant > 0 then
        quantize_table(self)
    end
    self:outlet(2, "duration", {length})
    self:outlet(2, "bpm", {60000 / self.estimatedbpm})
end

local function play(self, playdata)
    local note = playdata[self.playindex]

    self.hangingnotes[note[2]] = note[3]

    self:outlet(1, "list", { note[2], note[3] })
    local lastdelay = note[1]

    self.playindex = (self.playindex % #playdata) + 1
    self.playclock:delay(playdata[self.playindex][1] - lastdelay / self.speed)
end    

local function stop(self)
    self.playing = false
    self:outlet(2, "list", {"playing", 0})
    self.playclock:unset()
    for i = 0, 127 do
        if self.hangingnotes[i] ~= nil and self.hangingnotes[i] > 0 then
            pd.post(string.format("[%d] %d -> 0", i, self.hangingnotes[i]))
            self:outlet(1, "list", { i, 0 })
            self.hangingnotes[i] = 0
        end
    end
end

-------------------------------------------------

function pattern:initialize(sel, atoms)
    self.inlets = 2
    self.outlets = 2
    self.uid = atoms[1] or 0
    self.data = {}
    self.starttime = 0
    self.recording = false
    self.playing = false
    self.playindex = 1
    self.hangingnotes = {}
    self.quantized = {}
    self.quant = 0
    self.estimatedbpm = 0
    self.currentslot = 1
    self.speed = 1
    self.playclock = pd.Clock:new():register(self, "play_recorded")
    return true
end

function pattern:in_1_list(notedata)
    if self.recording == true and #notedata == 2 then
        local nowtime = socket.gettime() * 1000
        table.insert(self.data, { nowtime - self.starttime, notedata[1], notedata[2] })
    end
end

function pattern:in_2_record()
    self.recording = not self.recording
    self:outlet(2, "list", { "recording", self.recording and 1 or 0 }) --> bool to number conversion
    if self.recording == true then
        stop(self)
        --prepare recording
        self.data = {}
        self.quantized = {}
        self.estimatedbpm = 0
        self.starttime = socket.gettime() * 1000
    else
        finish_record(self)
    end
end

function pattern:in_2_play()
    if #self.data < 1 then
        return
    end
    if self.recording == true then
        self.recording = false
        finish_record(self)
    end
    self.playing = true
    self:outlet(2, "list", { "playing", self.playing and 1 or 0 })
    
    self.playindex = 1
    self.playclock:delay(self.data[1][1])
end

function pattern:in_2_stop()
    stop(self)
end

function pattern:in_2_speed(value)
    if type(value[1]) ~= "number" then
        self:error("invalid speed value")
        return
    end
    self.speed = math.max(value[1], 0.01)
end

function pattern:in_2_quantize(quant)
    if #quant < 1 or type(quant[1]) ~= "number" then
        self:error("invalid quantization value")
        return
    end
    self.quant = quant[1]
    if self.quant > 0 then
        quantize_table(self)
    end
end

function pattern:in_2_slot(slot)
    if #slot < 1 or type(slot[1]) ~= "number" or slot[1] < 0 or slot[1] >= 8 then
        self:error("invalid slot value")
        return
    end
    if slot[1] ~= self.currentslot then
        local temp = io.open(string.format("/tmp/pattern%d_slot%d", self.uid, self.currentslot), "w+")
        for i = 1, #self.data do
            if self.data[i][2] == "end" then
                temp:write(string.format("%f %s\n", self.data[i][1], self.data[i][2]))
            else
                temp:write(string.format("%f %d %d\n", self.data[i][1], self.data[i][2], self.data[i][3]))
            end
        end 
        temp:close()

        self.currentslot = slot[1]
        local newpath = string.format("/tmp/pattern%d_slot%d", self.uid, self.currentslot)
        local next = io.open(newpath, "r")
        self.data = {}
        if next ~= nil then
            for line in io.lines(newpath) do
                local values = {}
                for value in line:gmatch("%S+") do
                    table.insert(values, value)
                end
                table.insert(self.data, values)
            end
            next:close()
        end

        if self.playing == true then
            stop(self)
            self.playindex = 1
            self.playclock:delay(self.data[1][1])
        end
    end
end

function pattern:play_recorded()
    if self.quant > 0 then
        play(self, self.quantized)
    else
        play(self, self.data)
    end
end

function pattern:finalize()
    self.playclock:destruct()
end
