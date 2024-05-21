local Timer = {
    active = false,
    iteration = 0
}

function Timer:new(action, interval) -->in frames! for now..
    if type(action) ~= "function" then
        print("ERROR! timer action must be func")
        return false
    end
    local newT = {}
    setmetatable(newT, self)
    newT.action = action
    newT.interval = interval
    self.__index = self
    return newT
end

function Timer:start()
    self.active = true
end

function Timer:stop()
    self.active = false
end

function Timer:tick()
    if self.active == true then
        self.iteration = self.iteration + 1
        if self.iteration == self.interval then
            self.action()
            self.iteration = 0
        end
    end
end

return Timer