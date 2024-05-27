local gen_panel = pd.Class:new():register("gen_panel")

function gen_panel:initialize()
    self.inlets = 1
    self.outlets = 1
    local home = os.getenv("HOME")
    package.path = home .. "/pd/core-lib/scripts/?.lua;" .. package.path
    return true
end

function gen_panel:run(conf_file)
    self:outlet(1, "clear", {})
    local h = 48
    local w = 140
    local max_h = h*10
    local config = require("param_presets." .. conf_file)
    for i,p in pairs(config) do
        if not p.hidden then
            local y = (i-1)*h
            local x = (math.floor(y/max_h))*w
            y = y - math.floor(y/max_h)*max_h
            local component = p.component or "slider"
            -- primeiros 8 args sao path(label & receive), send, min, max, pow, mult, int & add
            local msg = {
                x+20, y+20, "panels/" .. component, p.path, p.send, p.min or 0, p.max or 1, p.pow or 1, p.mult or 1, p.int or 0, p.add or 0
            }
            -- args seguintes sao a list pro [list prepend] pra chegar nos [receive]
            for sub in string.gmatch(p.path, "([^/]+)") do
                table.insert(msg, sub)
            end
            self:outlet(1, "obj", msg)
        end
    end
    self:outlet(1, "loadbang", {})
end

function gen_panel:in_1_bang()
    self:run("fx")
end

function gen_panel:in_1_symbol(conf_file)
    self:run(conf_file)
end
