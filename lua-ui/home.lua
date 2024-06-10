local ip_list = require("lib.ip-list")
local midi_connections = require("lib.midi-connections")
local jack_status = require("lib.jack-status")

local conf = {
    cpu = 0,
    jack_status = "",
    ips = {},
    pd_patch = "minimal-sampler",
    pd_status = "stopped",
    dhcpcd_status = "stopped",
    midi_connections = ""
}
--[[
BOTOES;
back;
jack config
midi connections
ethernet config

]]

local function update()
    conf.jack_status = jack_status()
    conf.ips, conf.status = ip_list()
    conf.midi_connections = midi_connections()
end

local frame = 0

function Draw()
    if frame == 0 then
        update()
    end
    frame = (frame + 1) % 120
    -------------------------
    Color("#ffffff")
    move_to(4, 0)
    text(conf.jack_status, 12)
    move_to(0, screen_h / 2)
    line_to(screen_w/2, screen_h / 2)
    stroke()
    move_to(4, screen_h/2)
    text(conf.midi_connections, 12)
    move_to(screen_w - 7*FontSize, 0)
    text("CPU: " .. conf.cpu .. "%", 12, nil, 7*FontSize, "right")
end

function Cleanup() end

function SetParam(key, value)
    conf[key] = value
end

function PanelInput(device, pin, value)
end