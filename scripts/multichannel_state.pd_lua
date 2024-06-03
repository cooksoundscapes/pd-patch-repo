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
    self.n_channels = atoms[1] or 8
    self.inlets = 1
    self.outlets = 2
    self.state = {}
    self.selected = 1
    for _=1,self.n_channels do
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
                    ch[path] = {value=value, pow=p.pow, mult=p.mult, int=p.int}
                end
            end
        end
    end
    return true
end

function multichannel_state:in_1_float(ch)
    self.selected = ch + 1 -- expects 0 index
    self:deserialize_current()
end

function multichannel_state:in_1_list(msg)
    local key = msg[1]
    local value = msg[2]
    local existing = self.state[self.selected][key]
    if existing == nil then
        existing = {value=value}
    else
        existing.value = value
    end
end

function multichannel_state:in_1_select(atoms)
    local ch = atoms[1]
    if self.state[ch] ~= nil then
        self.selected = ch + 1
    end
end


function multichannel_state:in_1_dump()
    local sel = self.selected
    for i=1,self.n_channels do
        self.selected = i
        self:deserialize_current()
    end
    self.selected = sel
end

-- deprecated
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
        local msg = {self.selected-1}
        -- transform key into list (split by "/")
        for p in k:gmatch("([^/]+)") do
            table.insert(msg, p)
        end
        -- "cook" value using pow, mult and int properties
        local real_value = v.value
        if v.pow ~= nil then
            real_value = real_value ^ v.pow
        end
        if v.mult ~= nil then
            real_value = real_value * v.mult
        end
        if v.int ~= nil then
            real_value = math.floor(real_value)
        end
        -- apend value in the end of the list
        table.insert(msg, real_value)
        -- output raw key/value in 2nd outlet
        self:outlet(2, "list", {k, v.value})
        -- output a list of the deserialized key plus calculated value in 1st outlet
        self:outlet(1, "list", msg)
    end
end

function multichannel_state:dump_current_state()
    if self.state[self.selected] == nil then return end

    local s = 0
    for k,v in pairs(self.state[self.selected]) do
        self:outlet(1, "list", {k, v.value})
        s = s + 1
    end
    if s < 1 then
        self:outlet(1, "empty", {})
    end
end