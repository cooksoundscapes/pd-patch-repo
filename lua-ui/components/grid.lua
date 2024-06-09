return function(x, y, size, n_col, data, border_color, bg_color, on_color)
  local sw = size / n_col
  local c = {bg_color, on_color}
  set_line_width(1)
  for i,v in pairs(data) do
    local ix = x + (((i-1) % n_col) * sw)
    local iy = y + (math.floor((i-1) / n_col) * sw)
    rectangle(ix, iy, sw, sw)
    Color(c[(v > 0 and 1 or v) + 1])
    fill_preserve()
    Color(border_color)
    stroke()
  end
end