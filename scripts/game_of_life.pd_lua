local game_of_life = pd.Class:new():register("game_of_life")

function game_of_life:initialize(_,atoms)
  if atoms[1] == nil or atoms[2] == nil then
    self:error("provide table name and number of columns!")
    return false
  end
  self.table_name = atoms[1]
  self.columns = atoms[2]
  self.inlets = 1
  return true
end

function game_of_life:find_neighbors(t, i)
  local c = i % self.columns
  local r = math.floor(i / self.columns)
  local alive = 0
  local max_r = math.floor(t:length() / self.columns)
  -- 3x3 area
  for nc=c-1,c+1 do
    for nr=r-1,r+1 do
      if nc >= 0 and nc < self.columns and nr >=0 and nr < max_r then
        local ni = nr * self.columns + nc -- resynthesize coord into index
        if i ~= ni and t:get(ni) > 0 then
          alive = alive + 1
        end
      end
    end
  end
  return alive
end

-- iteration
function game_of_life:in_1_bang()
  local t = pd.Table:new():sync(self.table_name)
  if t == nil then
    self:error("table " .. t .. " not found")
    return
  end

  local temp_state = {}
  for i=0,t:length()-1 do
    local alive = self:find_neighbors(t, i)
    -- apply the rules
    if alive < 2 or alive > 3 then
      temp_state[i] = 0
    elseif alive == 3 then
      temp_state[i] = 1
    else
      temp_state[i] = t:get(i)
    end
  end
  for i,s in pairs(temp_state) do
    t:set(i, s)
  end
  t:redraw()
end