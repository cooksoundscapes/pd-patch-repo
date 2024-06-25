local grid = require("components.grid")
local unigrid = require("components.unicode_grid")

local palette = {
  charcoal = "#2e2e2e",
  slate_grey = "#3c3c3c",
  warm_grey = "#4a4a4a",
  soft_grey = "#6d6d6d",
  orange = "#ff8c42",
  dark_orange = "#ff6500",
  black = "#000000",
  off_white = "#fafafa"
}

local game = {}

local row_s = 100

function Draw()
  grid(
    0, 0, screen_w, screen_h, row_s, game,
    palette.black, palette.slate_grey, palette.dark_orange
    --palette.black, palette.black, palette.dark_orange
  )
  --unigrid(0, 0, 32, game, {"░", "▓"}, palette.dark_orange)
end

function SetTable(name, data)
  if name == "game" then
    game = data
  end
end

function SetParam(r)
  row_s = r
end

function Cleanup()
  for i=1,#game do
    game[i] = nil
  end
  game = nil
end