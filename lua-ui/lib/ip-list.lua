return function()
    local handler = io.popen("ip addr")
    if handler ~= nil then
        local ips = {}
        local curr_dev = ""
        for line in handler:lines() do
            local device = string.match(line, "^%d+: (.-):.+")
            if device ~= nil then
                curr_dev = device
            else
                local ip = string.match(line, "inet (.-) .-scope global.+$")
                if ip ~= nil then
                    table.insert(ips, {curr_dev, ip})
                end
            end
        end
        handler:close()
        return ips
    end
end