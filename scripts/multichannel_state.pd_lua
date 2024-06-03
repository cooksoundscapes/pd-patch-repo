local multichannel_state = pd.Class:new():register("multichannel_state")

--[[
    agnostic state manager for keys/values;
    receives n-sized lists and treats last item as value,
    the rest of the list is concatenated by "/" and used as key
    optionally can use a table to have default values
    1st arg: number of channels
    2nd arg: parameter preset file
]]

function multichannel_state:initialize(_,atoms)
    local channels = atoms[1] or 8
    self.inlets = 1
    self.outlets = 1
    self.state = {}
    self.selected = 1
    for _=1,channels do
        table.insert(self.state, {})
    end

    -- if provided with a preset file, preload each channel with path:value
    if atoms[2] ~= nil then
        local home = os.getenv("HOME")
        package.path = home .. "/pd/core-lib/scripts/?.lua;" .. package.path
        local default = require("param_presets." .. atoms[2])
        for _,ch in pairs(self.state) do
            for _,p in pairs(default) do
                local path = p.path
                local value = p.default or p.min
                if path ~= nil and value ~= nil then
                    ch[path] = value
                end
            end
        end
    end
    return true
end

function multichannel_state:dump_current_state()
    if self.state[self.selected] == nil then return end

    local s = 0
    for k,v in pairs(self.state[self.selected]) do
        self:outlet(1, "list", {k, v})
        s = s + 1
    end
    if s < 1 then
        self:outlet(1, "empty", {})
    end
end

function multichannel_state:in_1_float(ch)
    self.selected = ch
    self:dump_current_state()
end

function multichannel_state:in_1_list(msg)
    local key = msg[1]
    local value = msg[2]
    self.state[self.selected][key] = value
end

function multichannel_state:in_1_select(atoms)
    local ch = atoms[1]
    if self.state[ch] ~= nil then
        self.selected = ch
    end
end

-- deprecate those---------

function multichannel_state:serialize(msg)
    local key = ""
    local value
    -- serialize key
    for i,v in pairs(msg) do
        if i ~= #msg then
            if key == "" then
                key = v
            else
                key = key .. "/" .. v
            end
        else
            value = v
        end
    end
    self.state[self.selected][key] = value
end

function multichannel_state:deserialize_current()
    for k,v in pairs(self.state[self.selected]) do
        -- deserialize key
        local msg = {}
        for p in k:gmatch("([^/]+)") do
            table.insert(msg, p)
        end
        table.insert(msg, v)
        self:outlet(1, "list", msg)
    end
end
