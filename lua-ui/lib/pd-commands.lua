return {
    port = 7779,
    send = function(self, msg)
        local cmd = string.format("echo '%s;' | pdsend %d", msg, self.port)
        os.execute(cmd .. " &> /dev/null")
    end,
    open_file = function(self, file, path)
        local home = os.getenv("HOME")
        path = home .. "/pd/core-lib/" .. path
        local msg = string.format("pd open %s.pd %s", file, path)
        self:send(msg)
    end,
    close_file = function(self, patch)
        local msg = string.format("pd-%s.pd menuclose", patch)
        self:send(msg)
    end
}