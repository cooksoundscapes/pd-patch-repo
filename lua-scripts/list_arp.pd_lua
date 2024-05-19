local list_arp = pd.Class:new():register("list_arp")

function list_arp:initialize()
    self.inlets = 1
    self.outlets = 2
    self.list = {}
    self.pos = 0
    self.playing = false
    self.speed = 125 -- ms
    self.clock = pd.Clock:new():register(self, "start")
    return true
end

function list_arp:finalize()
    self.clock:destruct()
end

function list_arp:in_1_list(list)
    self.list = {}
    for _,i in pairs(list) do
        if type(i) ~= "number" then
            self:error("wrong arg type")
            self.list = {}
            return
        end
        table.insert(self.list, i)
    end
end

function list_arp:start()
    self:outlet(1, "float", {self.list[self.pos + 1]})
    self.pos = (self.pos + 1) % #self.list
    self.clock:delay(self.speed)
end


function list_arp:in_1_play()
    self.playing = true
    self.pos = 0
    self:start()
    self:outlet(2, "float", {1})
end

function list_arp:in_1_stop()
    self.playing = false
    self.clock:unset()
    self:outlet(2, "float", {0})
end

function list_arp:in_1_rate(spd)
    if type(spd[1]) ~= "number" then return end
    self.speed = spd[1]
end