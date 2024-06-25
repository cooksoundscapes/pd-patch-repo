local jack_setups = require("config.jack-setups")
local pd_cmd = require("lib.pd-commands")
local jack_status = require("lib.jack-status")
local restart_jack = require("lib.restart-jack")
local connect_pd = require("lib.connect-pd")
local get_settings = require("lib.system-settings")

FontSize = 16
FontAntiAlias = true
DefaultFont = "Astonpoliz"
FirstOpened = false

function Color(col)
  local r, g, b = hex(col)
  set_source_rgb(r, g, b)
end

--[[
Audio setup will be done here, at least for now.
This should ensure that all will be done at userspace,
right after the initialization of indiscipline.

That causes some ugly behavior due to blocking os.execute operation BEFORE graphic loop,
but works, at least. In the future, this can be, somehow, a non-blocking operation,
probably delegating this into a registered C function in a separated thread
]]

local js = jack_status()

if js ~= "started" then
  local default_jack_config
  for _,conf in pairs(jack_setups) do
    if conf.default == true then
      default_jack_config = conf
    end
  end
  local err = restart_jack(default_jack_config)
  if err == nil then
    pd_cmd:send("pd dsp 0")
  end
end
pd_cmd:send("pd dsp 1")
os.execute("sleep 0.1")

local sys_settings = get_settings()
local audio_chan = tonumber(sys_settings["audio-channels"]) or 16
DefaultView = sys_settings["default-view"] or "home"
connect_pd(audio_chan)

function Navigate(page)
  load_module(app, page)
end

-- placeholders to avoid accessing nil functions

-- Draw will be called every frame by host
function Draw() end

-- SetParam is called whenever the OSC endpoint /param is hit in the host
-- it can have any number of arguments; the values will be captured in order
function SetParam() end

-- Cleanup is called before loading a new file, usually at /navigate
function Cleanup() end

-- PanelInput is only called when the current page is "home.lua";
-- it can be called by the GPIO module OR by /panel OSC endpoint
function PanelInput(device, pin, value) end

-- SetTable is called by /buffer endpoint
function SetTable(name, buffer) end

-- FileDrop is called when host is running in SDL window and a file is dropped onto it
function FileDrop(file) end
