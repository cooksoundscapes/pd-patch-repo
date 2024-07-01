return function(x, y, w, h, value, border_color, bg_color, font_color)
    rectangle(x, y, w, h)
    Color(bg_color)
    fill_preserve()
    Color(border_color)
    stroke()
    move_to(x+1, y)
    Color(font_color)
    local fmt = ".%2f"
    if value % 1 == 0 then
        fmt = "%d"
    end
    text(string.format(fmt, value), h / 2, nil, w-4, "center")
end