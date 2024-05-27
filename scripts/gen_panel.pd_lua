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

    local config = require("param_presets." .. conf_file)
    local total_h = 0
    for i,p in pairs(config) do
        if not p.hidden then
            local component = p.component or "slider"
            local w = 140
            local h = 48
            local max_y = h * 10
            local y = (i-1)*h
            local x = (math.floor(y/max_y))*w
            y = y - math.floor(y/max_y)*max_y

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
