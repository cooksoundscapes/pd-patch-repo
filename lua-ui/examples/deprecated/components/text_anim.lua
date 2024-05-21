local shades = {"\u{2591}", "\u{2592}", "\u{2593}"} -- ░▒▓
local corners = {
  "\u{2596}", "\u{2597}", "\u{2598}", "\u{2599}", "\u{259A}", "\u{259B}",
  "\u{259C}", "\u{259D}", "\u{259E}", "\u{259F}"
} -- ▖ ▗▘ ▙ ▚ ▛ ▜ ▝ ▞ ▟ 

local digits = {
  "\u{1fBF0}", "\u{1fBF1}", "\u{1fBF2}", "\u{1fBF3}", "\u{1fBF4}",
  "\u{1fBF5}", "\u{1fBF6}", "\u{1fBF7}", "\u{1fBF8}", "\u{1fBF9}"
} -- 𛯰𛯱𛯲𛯳𛯴𛯵𛯶𛯷𛯸𛯹

local chess = {
  "\u{2654}", "\u{2655}", "\u{2656}", "\u{2657}", "\u{2658}", "\u{2659}",
  "\u{265A}", "\u{265B}", "\u{265C}", "\u{265D}", "\u{265E}", "\u{265F}"
} -- ♔♕♖♗♘♙♚♛♜♝♞♟

local cards = {
  "\u{1F0A1}", "\u{1F0A2}", "\u{1F0A3}", "\u{1F0A4}", "\u{1F0A5}", "\u{1F0A6}",
  "\u{1F0A7}", "\u{1F0A8}", "\u{1F0A9}", "\u{1F0AA}", "\u{1F0AB}", "\u{1F0AC}",
  "\u{1F0AD}", "\u{1F0AE}", "\u{1F0B1}", "\u{1F0B2}", "\u{1F0B3}", "\u{1F0B4}",
  "\u{1F0B5}", "\u{1F0B6}", "\u{1F0B7}", "\u{1F0B8}", "\u{1F0B9}", "\u{1F0BA}",
  "\u{1F0BB}", "\u{1F0BC}", "\u{1F0BD}", "\u{1F0BE}", "\u{1F0C1}", "\u{1F0C2}",
  "\u{1F0C3}", "\u{1F0C4}", "\u{1F0C5}", "\u{1F0C6}", "\u{1F0C7}", "\u{1F0C8}",
  "\u{1F0C9}", "\u{1F0CA}", "\u{1F0CB}", "\u{1F0CC}", "\u{1F0CD}", "\u{1F0CE}",
  "\u{1F0D1}", "\u{1F0D2}", "\u{1F0D3}", "\u{1F0D4}", "\u{1F0D5}", "\u{1F0D6}",
  "\u{1F0D7}", "\u{1F0D8}", "\u{1F0D9}", "\u{1F0DA}", "\u{1F0DB}", "\u{1F0DC}",
  "\u{1F0DD}", "\u{1F0DE}"
} -- 🂡🂢🂣🂤🂥🂦🂧🂨🂩🂪🂫🂬🂭🂮🂱🂲🂳🂴🂵🂶🂷🂸🂹🂺🂻🂼🂽🂾🃁🃂🃃🃄🃅🃆🃇🃈🃉🃊🃋🃌🃍🃎🃏

local text_anim = {
  sequence = {"░░░░", "▒░░░", "▒▓░░", "░▒▓▒", "░░▒▓", "░░░▒"},
  delay = 2,
  frame = 1,
  current_frame = 1,

  get = function(self)
    if self.frame % self.delay == 0 then
      self.current_frame = self.current_frame + 1
      if self.current_frame > #self.sequence then
        self.current_frame = 1
      end
    end
    self.frame = self.frame + 1
    return self.sequence[self.current_frame]
  end,

  new = function(self, seq, delay)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    obj.sequence = seq or obj.sequence
    obj.delay = delay or obj.delay
    return obj
  end
}

return text_anim, shades, corners