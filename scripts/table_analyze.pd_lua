local table_analyze = pd.Class:new():register("table_analyze")

function table_analyze:initialize(sel, atoms)
  self.inlets = 1
  if type(atoms[1]) == 'string' and type(atoms[2]) == 'string' then
    self.source_table = atoms[1]
    self.target_table = atoms[2]
    return true
  end
  self:error("1st and 2nd arguments must be table names!")
  return false
end

function table_analyze:in_1_bang()
  local source = pd.Table:new():sync(self.source_table)
  local target = pd.Table:new():sync(self.target_table)
  local bin_size = math.floor(source:length() / target:length())
  pd.post(string.format("bin size set to %d", bin_size))
  local rms = 0
  local target_index = 0
  for samp = 0, source:length()-1 do
    if samp % bin_size == 0 and samp ~= 0 then
      target:set(target_index, rms / bin_size)
      target_index = target_index + 1
      rms = 0
    end
    rms = rms + math.sqrt(math.abs(source:get(samp)))
  end
  target:redraw()
end