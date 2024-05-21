local Knob = {
    x = 4,
    y = FontSize + 8,
    size = FontSize*2,
    min = 0,
    max = 1,
    level = 0.5,
    label = "",
    postfix = "",
    int = false,
    set = function(self, p, v)
        self[p] = v
    end,
    draw = function(self)
        SetColor(Color.white)
        move_to(self.x, self.y)
        if self.int == true then
            text(self.label .. ": " .. string.format("%d", self.level) .. self.postfix)
        else
            text(self.label .. ": " .. string.format("%.2f", self.level) .. self.postfix)
        end
    end,

    new = function(self)
        local new_k = {}
        setmetatable(new_k, self)
        self.__index = self
        return new_k
    end
}

return Knob