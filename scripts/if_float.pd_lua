local if_float = pd.Class:new():register("if_float")

function if_float:initialize()
  self.inlets = 1
  self.outlets = 2
  return true
end

function if_float:in_1(sel, atoms)
  local n
  if (sel == "symbol" or sel == "list" or sel == "float") and atoms[1] ~= nil then
    n = tonumber(atoms[1])
  else
    n = tonumber(sel)
  end
  if n ~= nil then
    self:outlet(1, "float", {n})
  else
    self:outlet(2, "bang", {})
  end
end