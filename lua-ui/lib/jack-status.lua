return function()
    local handler = io.popen("jack_control status")
    local status = "JACK status: "
    if handler ~= nil then
        handler:read("*l")
        status = status .. handler:read("*l") .. '\n'
        handler:close()
    else
        status = status .. "stopped\n"
    end
    handler = io.popen("jack_control dp")
    if handler ~= nil then
        for line in handler:lines() do
            local dev = string.match(line, "^.-device:.-:hw:%d+:(.-)%)$")
            if dev ~= nil then
                status = status .. dev .. '\n'
            else
                local rate = string.match(line, "^.-rate:.-set:%d+:(%d+).+")
                if rate ~= nil then
                    status = status .. rate .. "Hz\n";
                else
                    local period = string.match(line, "^.-period:.-set:%d+:(%d+).+")
                    if period ~= nil then
                        status = status .. "period: " .. period .. '\n'
                    else
                        local nperiod = string.match(line, "^.-nperiods:.-set:%d+:(%d+).+")
                        if nperiod ~= nil then
                            status = status .. "nperiod: " .. nperiod
                        end
                    end
                end
            end
        end
    handler:close()
    end
    return status
end