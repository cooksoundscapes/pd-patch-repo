local mouse = require("lib.mouse")
local slider = require("components.controlled_h_slider")
local knob = require("components.controlled_knob")

local sl1 = slider:new(20, 20, 200, 20, {0, 1}, "sl1", "sl1")
local sl2 = slider:new(20, 60, 200, 20, {0, 1}, "sl2", "sl2")

local k1 = knob:new(20, 100, 50, {1, 100}, "fx overdrive gain", "gain")

mouse:add_area(sl1)
mouse:add_area(sl2)
mouse:add_area(k1)

function Draw()
    mouse:check()
    sl1:draw()
    sl2:draw()
    k1:draw()

    if drop_in_file ~= nil then
        move_to(0, 0)
        Color("#ffffff")
        text(drop_in_file)
    end
end

function FileDrop(file)
    print(string.format("file %s dropped at %d:%d", file, mouse_x, mouse_y))
end