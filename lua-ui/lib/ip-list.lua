return function()
    local handler = io.popen("ip addr")
    local ips = {}
    local ethernet = "enu1u1"
    local dhcpcd_status = ""
    if handler ~= nil then
        local curr_dev = ""
        for line in handler:lines() do
            local device = string.match(line, "^%d+: (.-):.+")
            if device ~= nil then
                curr_dev = device
            elseif curr_dev == ethernet then
                local ip = string.match(line, "inet (.-) .-scope global.+$")
                if ip ~= nil then
                    table.insert(ips, ip)
                end
            end
        end
        handler:close()
    end
    handler = io.popen("systemctl status dhcpcd@" .. ethernet)
    if handler ~= nil then
        for line in handler:lines() do
            local state = string.match(line, "^.-Active: (.-) .+")
            if state ~= nil then
                dhcpcd_status = state
            end
        end
        handler:close()
    end
    local s = string.format([[
    DHCP status on %s: %s
    Available IPs:
    ]], ethernet, dhcpcd_status)
    for i,ip in pairs(ips) do
        s = s .. ip .. '\n'
        if i < #ips then s = s .. '\n' end
    end
    return s
end