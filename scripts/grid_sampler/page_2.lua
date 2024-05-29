return {
  action = function(self, _, _, note, velocity)
    if velocity <= 0 then return end

    local col = note % self.n_col
    local row = math.floor(note / self.n_col)
    if col > 5 or row > 5 then return end

    -- 1st index by column (inputs) and in each column a pair (output, value)
    local v = self.io_matrix[col][row]
    local new_v = v ~ 1
    self.io_matrix[col][row] = new_v
    self:outlet(2, "list", {note, new_v*4+1})
    self:outlet(1, "io_matrix", {col, math.abs(5-row), new_v})
  end,
  init = function(self)
    for c=0,5 do
      for r=0,5 do
        self:outlet(2, "list", {r*self.n_col+c, self.io_matrix[c][r]*4+1})
      end
    end
  end
}