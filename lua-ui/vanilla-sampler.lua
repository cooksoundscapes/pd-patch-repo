if FirstOpened == false then
  FirstOpened = true
  local pdcmd = require("lib.pd-commands")
  pdcmd:open_file("minimal-sampler", "instruments")
end
local palette = {
    charcoal = "#2e2e2e",
    slate_grey = "#3c3c3c",
    warm_grey = "#4a4a4a",
    soft_grey = "#6d6d6d",
    orange = "#ff8c42",
    dark_orange = "#ff6500",
    black = "#000000",
    white = "#ffffff"
}

local modes = {"↪", "⇥", "↩", "⇤"} -- tri wave: ↹
local beats = {"▫", "▪"}

local global_config = {
    title = "Untitled",
    bpm = 95,
    bar_size = 4,
    click_lvl = 0
  }

local ch_params = {
    filename = "",
    input_vol = 1,
    direct_out = 1,
    own_bpm = 0,
    length = 0,
    trim_start = 0,
    trim_end = 0,
    loop = 1,
    reverse = 0,
    speed = 1,
    state = 0,
    sync = 0,
    auto_stop_rec = 0,
    recorded_bars = 0,
    input_channels = {1},
    rec_trig_threshold = 0
}

local function header()
    Color(palette.orange)


end