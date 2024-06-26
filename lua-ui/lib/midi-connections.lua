local saved_connections = require("config.midi-connections")
local string_split = require("lib.string-split")

-- returns a built string with current devices/connection
-- AND attempts to auto connect based on saved_connections, if both sender & receiver are present
return function(max_lines)
    max_lines = max_lines or 99
    local handler = io.popen("aconnect -l")
    if handler ~= nil then
        local devices = {}
        local current_dev
        local current_port
        local count = 0
        for line in handler:lines() do
            local dev_id, dev_name = string.match(line, "client (%d+): '(.-)'.-$")
            if dev_id ~= nil then
                current_dev = tonumber(dev_id)
                if current_dev ~= nil then
                    count = count + 1
                    devices[current_dev] = {name=dev_name, ports={}}
                end
            else
                local port_id, port_name = string.match(line, "(%d+) '%s*(.-)%s*'.-$")
                if port_id ~= nil then
                    current_port = tonumber(port_id)
                    if current_port ~= nil then
                        devices[current_dev].ports[current_port] = {name=port_name, connected_to={}}
                    end
                else
                    local connecting_to = string.match(line, "Connecting To: (.+)")
                    if connecting_to ~= nil then
                        local connected_ports = string_split(connecting_to, ", ")
                        for _,p in pairs(connected_ports) do
                            local dev, port = string.match(p, "^(%d+):(%d+).*")
                            if dev ~= nil and port ~= nil then
                                table.insert(
                                    devices[current_dev].ports[current_port].connected_to,
                                    {tonumber(dev), tonumber(port)}
                                )
                            end
                        end
                    end
                end
            end
        end
        handler:close()
        --attempts to connect
        for _,saved in pairs(saved_connections) do
            local sender, receiver
            for _,dev in pairs(devices) do
                if dev.name == sender then
                    sender = dev
                elseif dev.name == receiver then
                    receiver = dev
                end
            end
            if sender ~= nil and receiver ~= nil then
                local s = "'" .. saved.sender
                if saved.outport ~= nil then
                    s = s .. ":" .. saved.outport
                end
                s = s .. "'"
                local r = "'" .. saved.receiver
                if saved.inport ~= nil then
                    r = r .. ":" .. saved.inport
                end
                r = r .. "'"
                os.execute("aconnect " .. s .. " " .. r)
            end
        end

        -- build string
        local s = ""
        local i = 0
        local lines = 0
        for _,dev in pairs(devices) do
            if lines < max_lines then
                s = s .. "▪ " .. dev.name
                lines = lines + 1
                i = i + 1
                for _,port in pairs(dev.ports) do
                    if port.connected_to ~= nil and #port.connected_to > 0 then
                        for _,conn in pairs(port.connected_to) do
                            local d,p = conn[1], conn[2]
                            if devices[d] ~= nil and lines < max_lines then
                                s = s .. '\n  ' .. port.name .. "->" .. devices[d].name .. ":" .. p
                                lines = lines + 1
                            end
                        end
                    end
                end
                if i < count then
                    s = s .. '\n'
                end
            else
                s = s .. "..."
                return s
            end
        end
        return s
    end
end