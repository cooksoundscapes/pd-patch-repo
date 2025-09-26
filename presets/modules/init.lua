local M = {}

setmetatable(M, {
    __index = function(_, module)
        local m = require("presets.modules." .. module)
        return m
    end
})

return M