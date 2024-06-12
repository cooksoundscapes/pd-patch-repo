local split = require("lib.string-split")
local trim = require("lib.string-trim")

return function()
    local home = os.getenv("HOME")
    local settings = io.open(home .. "/.bouncersettings")
    local t = {}
    if settings ~= nil then
        for line in settings:lines() do
            local p = split(line, "=")
            local k, v = trim(p[1]), trim(p[2])
            t[k] = v
        end
        return t
    end
end