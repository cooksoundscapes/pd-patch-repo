local text_anim = require("components.text_anim")
local ip_list = require("lib.ip_list")

local page = {
  status = "",
  cards = {},
  in_prompt = false,
  is_loading = false,
  cmd_runner = nil,
  is_active = false,

  loading = text_anim:new({
    "loading",
    "loading.",
    "loading..",
    "loading...",}, 10),

  init = function(self, cmd_runner)
    self.cmd_runner = cmd_runner
    self.cmd_runner:call("systemctl status dhcpcd")
    self.status = self.cmd_runner:read("*l") or "inactive"
    self.cmd_runner:close()
    if self.status == "active" then
      self.is_active = true
    else
      self.is_active = false
    end
    self.cards = ip_list(cmd_runner)
    self.in_prompt = false
    self.is_loading = false
  end,

  draw = function(self)
    SetColor(Color.white)
    if self.is_loading then
      local x, y = Center(FontSize*8, FontSize)
      move_to(x, y - 10)
      text(self.loading:get())
      return
    end
    if self.in_prompt then
      local x, y = Center(FontSize*4, FontSize)
      move_to(x, y - 20)
      if self.is_active == true then
        text("Deactivate?")
      else
        text("Activate?")
      end
      move_to(5, screen_h-(FontSize+4))
      text("no")
      move_to(screen_w - FontSize*2, screen_h-(FontSize+4))
      text("yes")
      return
    end
    text("networking: " .. self.status)
    local i = 1
    for _,card in ipairs(self.cards) do
      local spacing = i*(FontSize)
      local dev = string.sub(card.device, 1, 7)
      move_to(0, spacing)
      text(dev, FontSize)
      move_to(W(0.4), spacing)
      text(card.ip)
      i = i + 1
    end
  end,

  action = function(self)
    if self.in_prompt then
      -- from here on we need to test locally
      if self.is_active == false then
        self.cmd_runner:call("systemctl start dhcpcd")
        self.status = self.cmd_runner:read("*l") or "inactive"
        self.cmd_runner:close()
      else
        self.cmd_runner:call("systemctl stop dhcpcd")
        self.status = self.cmd_runner:read("*l") or "inactive"
        self.cmd_runner:close()
      end
      self.in_prompt = false
    else
      self.in_prompt = true
    end
  end,
}

return page