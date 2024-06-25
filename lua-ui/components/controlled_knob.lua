local knob = require("components.knob")
local pd = require("lib.pd-commands")

return {
    x = 20,
    y = 20,
    w = 50,
    h = 50,
    cx = 45,
    cy = 45,
    lvl = 0,
    max = 1,
    min = 0,
    dx = 0,
    dy = 0,
    label = "",
    show_label = false,
    pd_address = "sl",
    border_col = "#fafafa",
    bg_col = "#2e2e2e",
    pointer_col = "#ee2233",
    font_col = "#ffffff",

    draw = function(self)
        if self.show_label then
            Color(self.font_col)
            move_to(self.x, self.y - 22)
            text(self.label, 12)
        end
        knob(self.cx, self.cy, self.w, self.min, self.max, self.lvl, self.border_col, self.bg_col, self.pointer_col)
    end,

    drag = function(self, dx, dy)
        -- this is to mimic real knob turning - if mouse moves on X axis past half width,
        -- the Y axis movement should invert
        local grabbed_from = 1
        local xpos = mouse_x - self.x
        if xpos > self.w / 2 then
            grabbed_from = -1
        end
        local inc = (self.dy - dy) * ((self.max - self.min) / self.w) * grabbed_from
        inc = inc + (dx - self.dx) * ((self.max - self.min) / self.w) / 3
        self.dx = dx
        self.dy = dy
        self.lvl = math.min(self.max, math.max(self.min, self.lvl + inc))
        pd:send(string.format("%s %f", self.pd_address, self.lvl))
    end,
    release = function(self)
        self.dx = 0
        self.dy = 0
    end,

    new = function(self, x, y, size, min, max, pd_address, label, border_col, font_col, pointer_col, bg_col)
        self.__index = self
        local instance = setmetatable({}, self)
        instance.x = x
        instance.y = y
        instance.w = size
        instance.h = size
        instance.cx = x + (size / 2)
        instance.cy = y + (size / 2)
        instance.min = min
        instance.max = max
        instance.pd_address = pd_address
        instance.label = label
        instance.border_col = border_col
        instance.bg_col = bg_col
        instance.pointer_col = pointer_col
        instance.font_col = font_col
        if label ~= nil then
            instance.show_label = true
        end
        return instance
    end
}