local M = {}

setmetatable(M, {
    __index = function(_, module)
        local m = require("module_params." .. module)
        return m
    end
})

return M