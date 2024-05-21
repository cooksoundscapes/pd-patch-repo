local cmd_runner = {
  handler = nil,

  call = function(self, cmd)
    if self:is_running() then
      return
    end
   self.handler = io.popen(cmd)
  end,

  read = function(self, arg)
    if self.handler == nil then
      return nil
    end
    return self.handler:read(arg)
  end,

  close = function(self)
    if self.handler ~= nil then
      self.handler:close()
      self.handler = nil
    end
  end,

  lines = function(self)
    if self.handler == nil then
      return nil
    end
    return self.handler:lines()
  end,

  is_running = function(self)
    return self.handler ~= nil
  end,

  is_done = function(self)
    if self.handler == nil then
      return true
    end
    local o = self:read("*l")
    if o == nil then
      self:close()
      return true
    else
      return o
    end
  end,
}

return cmd_runner