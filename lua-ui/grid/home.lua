local round_rect = require("components.round_rect")
local vu_meter = require("components.vu_meter")
local sound_graph = require("components.sound_graph")
local knob = require("components.knob")
local h_slider = require("components.h_slider")

local palette = {
  charcoal = "#2e2e2e",
  slate_grey = "#3c3c3c",
  warm_grey = "#4a4a4a",
  soft_grey = "#6d6d6d",
  orange = "#ff8c42",
  dark_orange = "#ff6500",
  black = "#000000",
  off_white = "#fafafa"
}

local modes = {"↪", "⇥", "↩", "⇤"} -- tri wave: ↹
local states = {
  {"⏹", "#ff0000"},
  {"⏺", "#000000"},
  {"▶", "#00ff00"}
}

local beats = {"▫", "▪"} -- {"◴", "◷", "◶", "◵"} --  {"◭", "◮"}

local global_config = {
  title = "Untitled",
  bpm = 95,
  bar_size = 4,
  beat = 1
}

local channel_state = {}
local selected = 1
for i=1,6 do
  channel_state[i] = {
    input_vol = 0, -- db
    output_vol = 0, -- db
    trim_start = 0,
    trim_end = 0,
    mode = 1,
    own_bpm = 0,
    filename = "untitled",
    sync = false,
    state = 1
  }
end

function Cleanup()
  for i=1,6 do
    channel_state[i] = nil
    destroy_surface("graph_" .. i)
  end

  modes = nil
  states = nil
  palette = nil
  beats = nil
  global_config = nil
end

--[[
  main draw method
]]
function Draw()
  local header_h = FontSize * 2
  local margin = 6
  local bpm_box_w = FontSize * 5
  -- background
  Color(palette.charcoal)
  paint()

  -- header
  Color(palette.orange)
  rectangle(0, 0, screen_w, header_h)
  fill()
  Color(palette.black)
  move_to(margin, 0)
  text(global_config.title)

  -- bpm
  move_to(screen_w - bpm_box_w - margin, 0)
  text(string.format("%000.2f",global_config.bpm), nil, nil, bpm_box_w, "right")

  -- beat dots
  for i=1,global_config.bar_size do
    move_to(screen_w*.5 + i*FontSize, 0)
    if i ~= global_config.beat then
      text(beats[1])
    else
      text(beats[2])
    end
  end

  -- channel indicator
  Color(palette.warm_grey)
  round_rect(margin, header_h + margin, FontSize*2, FontSize*2.5, 4)
  fill()
  Color(palette.off_white)
  move_to(9, header_h + margin)
  text("SMP", 10)
  move_to(FontSize, header_h + margin/2 + FontSize)
  text(string.format("%d", selected))

  --input/output meters
  move_to(screen_w - 35, header_h)
  text("I|O", 10)
  local i_chan = selected * 2 - 1
  local o_chan = selected * 2
  vu_meter:draw(
    screen_w - 44,
    header_h + 22,
    16,
    screen_h * 0.75,
    i_chan,
    palette.soft_grey,
    palette.off_white
  )
  vu_meter:draw(
    screen_w - 24,
    header_h + 22,
    16,
    screen_h * 0.75,
    o_chan,
    palette.soft_grey,
    palette.off_white
  )

  -- waveform
  move_to(44, header_h)
  Color(palette.orange)
  text(channel_state[selected].filename, 14)
  draw_surface("graph_" .. selected, 44, header_h + margin*2 + FontSize)

  --level
  knob(
    FontSize + 6,
    header_h + margin + FontSize*4,
    FontSize*2,
    0,
    100,
    channel_state[selected].input_vol,
    palette.off_white,
    palette.dark_orange,
    palette.off_white
  )

  h_slider(
    margin,
    screen_h - 40,
    60,
    15,
    0,
    100,
    channel_state[selected].input_vol,
    palette.warm_grey,
    palette.slate_grey,
    palette.off_white
  )
end

function SetParam(k, v)
  if k == "ch" then
    if v >= 1 and v <= 6 then
      selected = v
    end

  elseif global_config[k] ~= nil then
    global_config[k] = v

  else
    local channel = channel_state[selected]
    if channel ~= nil and channel[k] ~= nil then
      channel[k] = v
    end
  end
end

-- expects "name" to be "graph_<selected>"
function SetTable(data, name)
  if name == "game" then
    game = data
    return
  end
  destroy_surface(name)
  local w = screen_w * 0.7
  local h = screen_h * 0.35
  create_surface(name, w, h)
  sound_graph(data, w, h, 0, 1, palette.warm_grey, palette.slate_grey,  palette.orange)
end