return function()
    local handler = io.popen("ip addr")
    if handler ~= nil then
        local ips = {}
        local status = "stopped"
        for line in handler:lines() do
            local ip, type = string.match(line, "inet (.-) .-scope global (.-) .+$")
            if ip ~= nil then
                table.insert(ips, ip)
                if type == "dynamic" then
                    status = "running"
                end
            end
        end
        handler:close()
        return ips, status
    end
end