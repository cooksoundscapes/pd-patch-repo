local params = {
  ["level"] = 0,
  ["drive"] = 0,
  ["chorus"] = 0,
  ["lowpass"] = 0,
}

local sorted = {"level", "drive", "chorus", "lowpass"}

local audio = require("lib.audio")

function Draw()
  SetColor(Color.white)
  for i,name in ipairs(sorted) do
    move_to(4, i*FontSize)
    text(name .. ": " .. math.floor(params[name]) .. "%")
  end
  rectangle(118, 10, 10, 64)
  stroke()

  local mix_l = get_audio_buffer(app, 1)
  if mix_l ~= nil then
    local rms = audio.rms(mix_l)
    rectangle(120, 12+(60-rms*60), 6, rms*60)
    fill()
  end
end

function SetParam(name, value)
  if params[name] ~= nil then
    params[name] = value
  end
end

function Cleanup()
  params = nil
end

