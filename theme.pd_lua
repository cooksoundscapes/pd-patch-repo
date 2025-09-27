local theme = pd.Class:new():register("theme")


local function append_lib_path()
    local home = os.getenv("HOME")
    local lib_path = home .. "/pd/core-lib/?.lua;"

    if not string.find(package.path, lib_path, 1, true) then
        package.path = lib_path .. package.path
    end
end

function theme:initialize()
    append_lib_path()
    self.inlets = 1
    self.outlets = 1
    return true
end

function theme:in_1_symbol(title)
    local themes = require('themes')
    local chosen = themes[title]
    if chosen ~= nil then
        pd.send("pd", 'colors', {
            chosen.fg,
            chosen.bg,
            chosen.select,
            chosen.gop
        })
        pd.send("theme.obj", "color", {
            chosen.bg,
            chosen.action or chosen.select,
            chosen.labels or chosen.fg
        })
    else
        pd.error("Theme " .. title .. " does not exist;")
    end
end

function theme:in_1_bang()
    package.loaded["themes"] = nil
    local themes = require('themes')
    local names = {}
    for k,_ in pairs(themes) do
        table.insert(names, k)
    end
    self:outlet(1, 'list', names)
end