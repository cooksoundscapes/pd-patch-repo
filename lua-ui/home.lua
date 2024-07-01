local ip_list = require("lib.ip-list")
local midi_connections = require("lib.midi-connections")
local jack_status = require("lib.jack-status")
local jack_settings = require("lib.get-jack-settings")
local jack_setups = require("config.jack-setups")
local restart_jack = require("lib.restart-jack")

local conf = {
    cpu = 0,
    jack_status = "",
    midi_connections = "",
    dhcp_status = ""
}

local function update()
    local jstat = jack_status()
    local jconf = jack_settings()
     conf.jack_status = "JACK Status: " .. (jstat or "stopped") .. '\n' .. (jconf or "")
    conf.midi_connections = midi_connections(5)
end

local max_frame = 120
local frame = max_frame - 1

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
        if frame == 0 then
            update()
        end
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
    end,
    internet_settings = function()
        Color("#ffffff")
        move_to(4, header_h)
        text(conf.dhcp_status, 12)
    end
}
local current = "home"

function Draw()
    header()
    canvas[current]()
    frame = (frame + 1) % max_frame
end

function Cleanup() end

function SetParam(key, value)
    conf[key] = value
end

local nav_buttons = {
    home = {
        function() Navigate(DefaultView) end,
        function() current = "jack_settings" end,
        function() os.execute("sudo poweroff") end,
        nil, -- MIDI settings
        function()
            current = "internet_settings"
            conf.dhcp_status = ip_list()
        end,
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
    },
    internet_settings = {
        function() current = "home" end,
        nil,
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