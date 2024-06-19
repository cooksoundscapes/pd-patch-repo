return function(tt, filepath)
    local str = ""

    local function count(t)
        local c = 0
        for _,_ in pairs(t) do c = c+1 end
        return c
    end

    local read_table
    read_table = function(t, lvl)
        local indent = string.rep("  ", lvl)
        local cnt = count(t)
        local i = 0
        for k,v in pairs(t) do
            i = i + 1
            if type(v) == "function" then
            elseif type(v) == "table" then
                str = str .. indent .. k .. " = {\n"
                read_table(v, lvl+1)
            else
                str = str .. indent .. k .. " = " .. tostring(v)
                if i < cnt then str = str .. "," end
                str = str .. "\n"
            end
            if i >= cnt then
                str = str .. string.rep("  ", lvl-1) .. "}\n"
            end
        end
    end

    str = "return {\n"
    read_table(tt, 1)
    local fd = assert(io.open(filepath, "w"))
    fd:write(str)
    fd:close()
end

