return function()
    local handler = io.popen("jack_control status")
    local status
    if handler ~= nil then
        handler:read("*l")
        status = handler:read("*l")
        handler:close()
    else
        status = "stopped"
    end
    return status
end