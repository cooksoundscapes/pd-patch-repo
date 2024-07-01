local game_of_life2 = pd.Class:new():register("game_of_life2")

function game_of_life2:initialize(_,atoms)
  local w = atoms[1]
  local h = atoms[2]
  if w == nil or h == nil then
    pd.error("provide width and height!")
    return false
  end

  self.board = {}

  self.columns = w
  self.rows = h

  self:in_1_reset()

  self.inlets = 1
  self.outlets = 1
  return true
end

function game_of_life2:in_1_reset()
  for col=1,self.columns do
    self.board[col] = {}
    for row=1, self.rows do
      self.board[col][row] = 0
    end
  end
end

function game_of_life2:in_1_list(atoms)
  local c = atoms[1] + 1
  local r = atoms[2] + 1
  local v = atoms[3]
  self.board[c][r] = v
end

function game_of_life2:find_neighbors(c, r)
  local alive = 0
  for nc=c-1,c+1 do
    for nr=r-1,r+1 do
      if
        nc > 0 and nr > 0 and
        nc <= self.columns and
        nr <= self.rows and
        (nc ~= c or nr ~= r) -- doesn't count center cell
      then
        if self.board[nc][nr] == 1 then
          alive = alive + 1
        end
      end
    end
  end
  return alive
end

-- iteration
function game_of_life2:in_1_bang()
  for c=1,self.columns do
    for r=1,self.rows do
      local alive = self:find_neighbors(c, r)
      -- apply the rules
      if alive < 2 or alive > 3 then
        self.board[c][r] = 0
      elseif alive == 3 then
        self.board[c][r] = 1
      end
      self:outlet(1, "list", {c-1, r-1, self.board[c][r]})
    end
  end
end
