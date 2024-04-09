local timediff = pd.Class:new():register("timediff")

local socket = require "socket"

function timediff:initialize(sel, atoms)
    self.inlets = 1
    self.outlets = 1
    self.last = 0
    return true
end

function timediff:in_1_bang()
    local nowtime = socket.gettime()*1000
    self:outlet(1, "float", {nowtime - self.last})
    self.last = nowtime
end