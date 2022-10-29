local function clear_grid(self, grid_size)
  for i=0, grid_size-1 do
    self:outlet(1, "list", {i, 0})
  end
end

local function button_to_coord(button, line_size)
    return {
      line = math.floor(button / line_size),
      col = button % line_size
    }
end

local function coord_to_button(line, col, line_size)
  return line * line_size + col
end

return {
  clear_grid = clear_grid,
  button_to_coord = button_to_coord,
  coord_to_button = coord_to_button
}