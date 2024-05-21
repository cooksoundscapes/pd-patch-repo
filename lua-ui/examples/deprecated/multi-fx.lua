local Knob = require("components.knob")

local knobs = {}
local cpu_load = 0
local fx_name = "drive"
local p_focus = 1
local page = 1
local param_amount = 1
local max_hor_quads = 2
local padding_top = FontSize + 4
local padding_left = 4
local bypass = true

local color_code = {
    drive = "#C62828",
    tremolo = "#3F7CAF",
    chorus = "#FFD700",
    delay = "#7F7F7F",
    verb = "#40E0D0",
    shifter = "#F7DC6F",
    flanger = "#F49AC1",
    crusher = "#800000"
}

function Draw()
    HexColor("#262626")
    paint()

    move_to(0, 0)
    HexColor(color_code[fx_name])
    rectangle(0, 0, screen_w, padding_top)
    fill()

    SetColor(Color.black)
    move_to(padding_left, 0)
    text(fx_name .. ": page " .. string.format("%d", page))

    if bypass == true then
        move_to((screen_w / 2) + FontSize/2, 0)
        text("[OFF]")
    end

    move_to(screen_w - FontSize*4, 0)
    text("cpu: " .. string.format("%d", cpu_load) .. "%")

    for _,knob in pairs(knobs) do
        knob:draw()
    end
end

function Cleanup()
    for i=1,#knobs do knobs[i] = nil end
    knobs = nil
end

local function get_XY(i)
    local quad_x = (i - 1) % max_hor_quads
    local quad_y = math.floor((i - 1) / max_hor_quads)
    local x = quad_x * (screen_w / max_hor_quads) + padding_left
    local y = quad_y * (screen_h / max_hor_quads) + padding_top
    return x, y
end

local actions = {
    cpu_load = function(v) cpu_load = v end,
    focus = function(v)
        p_focus = v
        if knobs[v] == nil then
            knobs[v] = Knob:new()
            local x, y = get_XY(v)
            knobs[v].x = x
            knobs[v].y = y
        end
    end,
    set_page = function(v)
        for i=1,#knobs do
            knobs[i] = nil
        end
        page = v
    end,
    set_fx = function(v) fx_name = v end,
    is_active = function(v)
        if v == 1 then bypass = false else bypass = true end
    end,
    param_amount = function(v) param_amount = v end,
    level = function(v) knobs[p_focus].level = v end,
    min = function(v) knobs[p_focus].min = v end,
    max = function(v) knobs[p_focus].max = v end,
    label = function(v) knobs[p_focus].label = v end,
    postfix = function(v) knobs[p_focus].postfix = v end,
    int = function(v) if v == 1 then knobs[p_focus].int = true end end,
}

function SetParam(k, v)
    if actions[k] == nil then
        print("[SetParam] Error: invalid action " .. k)
        return
    end
    actions[k](v)
end