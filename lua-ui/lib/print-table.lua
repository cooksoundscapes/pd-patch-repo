return function(table)
    local recv_print
    recv_print = function(t, lvl)
        local indent = string.rep(" ", lvl)
        for k,v in pairs(t) do
            if type(v) == "table" then
                print(indent .. k .. ":")
                recv_print(v, lvl+1)
            else
                print(indent .. k .. ": " .. tostring(v))
            end
        end
    end

    print("{")
    recv_print(table, 1)
    print("}")
end