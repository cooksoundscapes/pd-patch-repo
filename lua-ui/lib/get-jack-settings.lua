return function()
    local handler = io.popen("jack_control dp")
    local settings = ""
    if handler ~= nil then
        for line in handler:lines() do
            local dev = string.match(line, "^.-device:.-:hw:%d+:(.-)%)$")
            if dev ~= nil then
                settings = settings .. dev .. '\n'
            else
                local rate = string.match(line, "^.-rate:.-set:%d+:(%d+).+")
                if rate ~= nil then
                    settings = settings .. rate .. "Hz\n";
                else
                    local period = string.match(line, "^.-period:.-set:%d+:(%d+).+")
                    if period ~= nil then
                        settings = settings .. "period: " .. period .. '\n'
                    else
                        local nperiod = string.match(line, "^.-nperiods:.-set:%d+:(%d+).+")
                        if nperiod ~= nil then
                            settings = settings .. "nperiod: " .. nperiod
                        end
                    end
                end
            end
        end
    handler:close()
    end
    return settings
end