local box = require("components.numbox")
local pd = require("lib.pd-commands")

return {
    x = 20,
    y = 20,
    w = 50,
    h = 50,
    lvl = 0,
    max = 1,
    min = 0,
    transform = nil,
    label = "",
    show_label = false,
    font_size = 12,
    pd_address = "sl",
    border_col = "#fafafa",
    bg_col = "#2e2e2e",
    font_col = "#ffffff",

    draw = function(self)
        if self.show_label then
            Color(self.font_col)
            move_to(self.x, self.y - 22)
            text(self.label, self.font_size)
        end
        box(self.x, self.y, self.w, self.h, self.lvl, self.border_col, self.bg_col, self.font_col)
    end,

    drag = function(self, _, dy)
        local inc = 0
        if dy < 0 then
            inc = inc + 1
        elseif dy < 0 then
            inc = inc - 1
        end
        self.lvl = math.min(self.max, math.max(self.min, self.lvl + inc))
        pd:send(string.format("%s %f", self.pd_address, self.lvl))
    end,

    new = function(self, x, y, w, h, min, max, pd_address, label, font_size, border_col, font_col, bg_col)
        self.__index = self
        local instance = setmetatable({}, self)
        instance.x = x
        instance.y = y
        instance.w = w
        instance.h = h
        instance.min = min
        instance.max = max
        instance.pd_address = pd_address
        instance.label = label
        instance.font_size = font_size
        instance.border_col = border_col
        instance.bg_col = bg_col
        instance.font_col = font_col
        if label ~= nil then
            instance.show_label = true
        end
        return instance
    end
}