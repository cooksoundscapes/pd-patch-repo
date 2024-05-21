local menu = {
  entries = {},
  max_items_in_view = 10,
  font_spacing = FontSize,

  selected = 1,
  offset = 0,
  submenu = nil,
  parents = {},
  arrow = "> ", -- "\u{29D0} "

  call = function(self)
    local entry = {}
    if self.submenu == nil then
      entry = self.entries[self.selected]
    else
      entry = self.submenu[self.selected]
    end

    if entry.submenu ~= nil then
      self.set_submenu(self, entry.submenu, self.submenu or self.entries)
    else
      entry:action(entry.name)
    end
  end,

  select = function(self, dir)
    local size = 0
    if self.submenu == nil then
      size = #self.entries
    else
      size = #self.submenu
    end

    self.selected = math.max(1, math.min
      (size, self.selected + dir))

    self.offset = math.max(0,
      math.min(size - self.max_items_in_view, self.selected - self.max_items_in_view)
    )
  end,

  set_submenu = function(self, submenu, parent_menu)
    self.selected = 1
    self.offset = 0
    table.insert(self.parents, parent_menu)
    self.submenu = submenu
  end,

  back = function(self)
    if #self.parents == 0 then return end
    self.selected = 1
    self.offset = 0
    if #self.parents == 1 then
      table.remove(self.parents, #self.parents)
      self.submenu = nil
      return
    end
    self.submenu = self.parents[#self.parents]
    table.remove(self.parents, #self.parents)
  end,

  draw = function(self, offset_x, offset_y)
    if offset_x == nil then offset_x = 0 end
    if offset_y == nil then offset_y = 0 end

    SetColor(Color.white)
    local current_menu = {}
    if self.submenu ~= nil then
      current_menu = self.submenu
    else
      current_menu = self.entries
    end
    for i=self.offset+1,
      math.min(#current_menu, self.max_items_in_view+self.offset)
    do
      move_to(2+offset_x, (i - 1 - self.offset) * self.font_spacing+offset_y)
      if self.selected == i then
        text(self.arrow .. current_menu[i].name)
      else
        text(current_menu[i].name)
      end
    end
  end,

  get_entries_count = function(self)
    if self.submenu == nil then
      return #self.entries
    else
      return #self.submenu
    end
  end,
  
  get_selected = function(self)
	return self.entries[self.selected]
  end,
  
  new = function(self, obj)
    obj = obj or {}
    setmetatable(obj, self)
    self.__index = self
    return obj
  end
}

return menu
