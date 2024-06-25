return function(x, y, n_col, data, chars, color, font_size)
  font_size = font_size or FontSize
  local word = ""
  for i,d in pairs(data) do
    if (i-1) % n_col == 0 and i > 1 then
      word = word .. '\n'
    end
    word = word .. chars[(d > 0 and 1 or d) + 1]
    
  end
  move_to(x, y)
  Color(color)
  text(word, font_size)
end