local function wrong_count(self, args, expected)
  if #args ~= expected then
    self:error("wrong number of arguments")
    return true
  end
  return false
end

local function not_midi_note(self, args)
  if #args ~= 2 or
    args[1] < 0 or -- outside range
    args[1] > 127 or -- outside range
    type(args[2]) ~= "number" then
      self:error("not a midi note")
      return true
  end -- not a midi node
  return false
end

local function outside_range(self, n, min, max)
  if n < min or n > max then
    self:error("outside range")
    return true
  end
  return false
end

return {
  wrong_count = wrong_count,
  not_midi_note = not_midi_note,
  outside_range = outside_range,
}