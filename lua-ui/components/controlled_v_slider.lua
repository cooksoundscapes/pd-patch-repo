local slider = require("components.v_slider")
local pd = require("lib.pd-commands")

return {
    x = 20,
    y = 20,
    w = 200,
    h = 20,
    lvl = 0,
    max = 1,
    min = 0,
    dy = 0,
    label = "",
    show_label = false,
    font_size = 12,
    pd_address = "sl",
    line_col = "#fafafa",
    bg_col = "#2e2e2e",
    bar_col = "#ee2233",
    font_col = "#ffffff",

    draw = function(self)
        if self.show_label then
            Color(self.font_col)
            move_to(self.x, self.y - 22)
            text(self.label, self.font_size)
        end
        slider(self.x, self.y, self.w, self.h, self.min, self.max, self.lvl, self.line_col, self.bg_col, self.bar_col)
    end,

    drag = function(self, _, dy)
        local inc = (self.dy - dy) * ((self.max - self.min) / self.h)
        self.dy = dy
        self.lvl = math.min(self.max, math.max(self.min, self.lvl + inc))
        local final = self.lvl
        if self.transform ~= nil then
            final = self.transform(final)
        end
        pd:send(string.format("%s %f", self.pd_address, final))
    end,

    release = function(self)
        self.dy = 0
    end,

    new = function(self, x, y, w, h, range_or_transform, pd_address, label, font_size, bar_col, font_col, line_col, bg_col)
        self.__index = self
        local instance = setmetatable({}, self)
        instance.x = x
        instance.y = y
        instance.w = w
        instance.h = h
        if type(range_or_transform) == "table" then
            instance.min = range_or_transform[1]
            instance.max = range_or_transform[2]
        elseif type(range_or_transform) == "function" then
            instance.min = 0
            instance.max = 1
            instance.transform = range_or_transform
        end
        instance.pd_address = pd_address
        instance.label = label
        instance.font_size = font_size
        instance.line_col = line_col
        instance.bg_col = bg_col
        instance.bar_col = bar_col
        instance.font_col = font_col
        if label ~= nil then
            instance.show_label = true
        end
        return instance
    end
}