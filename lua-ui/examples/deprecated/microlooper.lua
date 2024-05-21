--[[ each loop channel has the following settable params:
- level
- cutoff
- speed
- trim start**
- trim end
- loop on/off
- reverse on/off
TODO: add effects directly on the ramp that reads the sample, e.g:
- bitcrush
- wavetables for weird playback
----------------------
those params are set differently
(both when pressing grid)
- range
- loop-start
(when finishing rec)
- length
- smp rate
**: trim-start has one value for each slice! ]]

local all_params = {
  ["level"] = 0, -- db
  ["cutoff"] = 100, -- %
  ["trim_start"] = 0,
  ["trim_end"] = 0,
  ["speed"] = 1,
  ["loop_start"] = 0,
  ["range"] = 0,
  ["loop"] = 0,
  ["reverse"] = 0,
  ["channel"] = 1,
}

local screens = {
  {

  },
}

local waveform_w = 80
local waveform_h = 30
local samp_vis = require('components.sample_vis')

local waveforms = {}
for i=1,8 do
  waveforms[i] = samp_vis:new()
  waveforms[i].w = waveform_w
  waveforms[i].h = waveform_h
  waveforms[i].name = "waveform_"..i
end

function SetTable(buffer, name)

end

function Draw()
  SetColor(Color.white)
  text("teste")
end