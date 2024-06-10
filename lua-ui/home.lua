local ip_list = require("lib.ip-list")
local midi_connections = require("lib.midi-connections")
local jack_status = require("lib.jack-status")
local jack_setups = require("config.jack-setups")
local restart_jack = require("lib.restart-jack")

local conf = {
    cpu = 0,
    jack_status = "",
    midi_connections = ""
}

ip_list()

local function update()
    conf.jack_status = jack_status()
    conf.midi_connections = midi_connections()
end
local frame = 0

local w = screen_w / 3
local h = screen_h / 6
local header_h = 16
local selected_jack_setup = 1

local header = function()
    Color("#ffffff")
    rectangle(0, 0, screen_w, header_h)
    fill()
    Color("#000000")
    move_to(screen_w/2 - 4, -2)
    text("CPU " .. conf.cpu .. "%", 10, nil, screen_w/2, "right")
end

local canvas = {
    home = function()
        Color("#ffffff")
        move_to(4, header_h)
        text(conf.jack_status, 11)

        move_to(screen_w/2, header_h)
        line_to(screen_w/2, screen_h - h*2)
        stroke()

        move_to(screen_w/2 + 4, header_h)
        text("MIDI Devices:\n" .. conf.midi_connections, 10)

        for i=0,5 do
            rectangle((i%3)*w, screen_h - h * (math.floor(i / 3) + 1), w, h)
            stroke()
        end
        stroke()
        move_to(0, screen_h - h*2 + h/4)
        text("Back", 10, nil, w, "center")
        move_to(w, screen_h - h*2 + h/4)
        text("Audio settings", 10, nil, w, "center")
        move_to(0, screen_h - h + h/4)
        text("MIDI settings", 10, nil, w, "center")
        move_to(w, screen_h - h)
        text("Connection\nsettings", 10, nil, w, "center")
        move_to(w*2, screen_h - h*2 + h/4)
        text("Shutdown", 10, nil, w, "center")
    end,
    jack_settings = function()
        Color("#ffffff")
        move_to(4, header_h)
        local m = "Choose a setup:\n"
        for i,setup in pairs(jack_setups) do
            if i == selected_jack_setup then
                m = m .. ">"
            end
            m = m .. setup.name .. '\n'
        end
        text(m, 12)
    end,
    jack_settings_confirm = function()
        Color("#ffffff")
        move_to(0, screen_h / 3)
        text("Apply changes for " .. jack_setups[selected_jack_setup].name .. "?", 11, nil, screen_w, "center")
    end
}
local current = "home"

function Draw()
    if frame == 0 then
        update()
    end
    frame = (frame + 1) % 120
    header()
    canvas[current]()
end

function Cleanup() end

function SetParam(key, value)
    conf[key] = value
end

local nav_buttons = {
    home = {
        function() print("goback") end, -- "home" button
        function() current = "jack_settings" end,
        nil, -- shutdown
        nil, -- MIDI settings
        function() current = "internet_settings" end,
        nil -- nothing for now
    },
    jack_settings = {
        function() current = "home" end,
        function() current = "jack_settings_confirm" end,
        function() selected_jack_setup = math.max(1, selected_jack_setup - 1) end,
        nil,
        nil,
        function() selected_jack_setup = math.min(#jack_setups, selected_jack_setup + 1) end,
    },
    jack_settings_confirm = {
        function() current = "home" end,
        function()
            restart_jack(jack_setups[selected_jack_setup])
            current = "home"
        end,
        nil,
        nil,
        nil,
        nil,
    }
}

function PanelInput(device, pin, value)
    local press_on = -1
    if device == "nav_buttons" and value == press_on then
        local fn = nav_buttons[current][pin]
        if fn ~= nil then
            fn()
        end
    end
end