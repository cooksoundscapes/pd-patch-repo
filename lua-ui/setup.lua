local jack_setups = require("config.jack-setups")
local jack_status = require("lib.jack-status")
local restart_jack = require("lib.restart-jack")
local pd_cmd = require("lib.pd-commands")
local connect_pd = require("lib.connect-pd")

FontSize = 16
FontAntiAlias = true
DefaultFont = "Astonpoliz"

function Color(col)
  local r, g, b = hex(col)
  set_source_rgb(r, g, b)
end

--[[
Audio setup will be done here, at least for now.
This should ensure that all will be done at userspace,
right after the initialization of indiscipline.

That causes some ugly behavior due to blocking os.execute operation BEFORE graphic loop,
but works, at least. In the future, this can be, somehow, a non-blocking operation
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
    pd_cmd:send("pd dsp 1")
    os.execute("sleep 0.5")
  end
end
connect_pd()


-- placeholders to avoid accessing nil functions
function Draw() end
function SetParam(name, value) end
function Cleanup() end
function PanelInput(device, pin, value) end
function SetTable(table, name) end
