local scrollbar = function(item_count, selected, x, y, w, h)
  SetColor(Color.white)
  rectangle(x + w-7, y, 1, h)
  fill()
  rectangle(x + w-9, y + h*(selected-1)/item_count, 5, h/item_count)
  fill()
end

return scrollbar