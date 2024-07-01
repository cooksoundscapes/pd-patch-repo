return {
  alpha = 0.1, -- for EMA (exponential moving average)
  last_rms_per_channel = {},

  draw = function(self, x, y, w, h, chan, outline_col, bar_col)
    local buf = get_audio_buffer(app, chan)
    if buf == nil then return end

    local rms = 0
    for _,s in ipairs(buf) do
      rms = rms + (s ^ 2)
    end
    rms = math.sqrt(rms/#buf) / 0.74 -- normalization by roughly the rms for a 1~-1 sine

    local smooth_rms = self.last_rms_per_channel[chan] or 0
    smooth_rms = self.alpha * rms + (1 - self.alpha) * smooth_rms
    self.last_rms_per_channel[chan] = smooth_rms

    local bar_h = math.min(h-4, h*smooth_rms)
    local bar_y = (y-2)+(h-bar_h)

    set_line_width(1)
    Color(outline_col)
    rectangle(x, y, w, h)
    stroke()

    if h*smooth_rms > h-4 then
      Color("#ff0000")
    else
      Color(bar_col)
    end
    rectangle(x+2, bar_y, w-4, bar_h)
    fill()
  end
}