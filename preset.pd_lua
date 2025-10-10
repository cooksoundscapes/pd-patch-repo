local preset = pd.Class:new():register('preset')


local function append_lib_path()
    local home = os.getenv("HOME")
    local lib_path = home .. "/pd/core-lib/?.lua;"
    if not string.find(package.path, lib_path, 1, true) then
        package.path = lib_path .. package.path
    end
end

--[[
    1st inlet takes care of CONTROLS;
    2nd inlet takes care of PRESETS;
    3rd inlet takes care of MODULES;
    The idea is to have 3 types of config files:
    1. control mappings
    2. parameters presets
    3. modules

    general workflow is:
    1. loading each module individually
    2. loading one control mapping at a time - these defines what encoders can control
    3. loading presets for setting groups os parameters and shortcuts to control mapping
]]

function preset:initialize()
    append_lib_path()
    self.inlets = 3
    self.outlets = 1
    self.loaded_modules = {}
    return true
end


-- add module
function preset:in_3_add(atoms)
    local module_name = atoms[1]
    local receiver = atoms[2]

    if not module_name then
        self:error("'add' needs module name as 1st arg;")
        return
    end

    local mod_factory = require('presets.modules.' .. module_name)
    if mod_factory then
        local instance = mod_factory.new()
        instance.receiver = receiver or module_name
        self.loaded_modules[module_name] = instance
        for param_name, param in pairs(instance) do
            if param.set_default then
                self:send_param(module_name, param_name)
            end
        end
    end
end


function preset:in_3_remove(atoms)
    local m_name = atoms[1]
    self.loaded_modules[m_name] = nil
end

-- load preset
function preset:in_1_load(atoms)
    local preset_name = atoms[1]
    local preset_module = require("presets." .. preset_name)

    if not preset_module then
        self:error("Invalid preset name" .. preset_name)
        return
    end

    local applied_params = {}

    if preset_module.defaults then
        -- aplica defaults definidos no preset
        for module_name, param in ipairs(preset_module.defaults) do
            if self.loaded_modules[module_name] then
                for param_name,value in pairs(param) do
                    self.loaded_modules[module_name][param_name]:set(value)
                    self:send_param(module_name, param_name)
                    applied_params[module_name..':'..param_name] = true
                end
            else
                self:error("Preset '" .. preset_name .. "' needs module '" .. module_name .. "'")
            end
        end
    end
    -- reseta parâmetros não listados no defaults
    for module_name, module in pairs(self.loaded_modules) do
        for param_name, param in pairs(module) do
            if param.set_default and not applied_params[module_name..":"..param_name] then
                param:set_default()
                self:send_param(module_name, param_name)
            end
        end
    end
    self.current_preset = preset_module
end

function preset:send_param(module, param)
    local omit =
        self.loaded_modules[module].config and
        self.loaded_modules[module].config.omit_module
    local receiver = self.loaded_modules[module].receiver or module
    local value = self.loaded_modules[module][param]:get()
    local suffix = self.loaded_modules[module][param].suffix or ""
    if omit then
        pd.send(
            param,
            'float',
            value
        )
    else
        pd.send(
            receiver,
            param,
            value
        )
    end
    pd.send(
        'monitor',
        'list',
        {receiver, param, value[1], suffix}
    )
end

function preset:set_param(module,param,value,action)
    if
        self.loaded_modules[module] and
        self.loaded_modules[module][param]
    then
        local target = self.loaded_modules[module][param]
        local method = target[action]
        if not method then
            self:error("Invalid set method: " .. action)
        end
        method(target, value)
        self:send_param(module, param)
    end
end

function preset:in_1_pot(atoms)
    self:set_param(atoms[1], atoms[2], atoms[3], 'pot')
end

function preset:in_1_increment(atoms)
    self:set_param(atoms[1], atoms[2], atoms[3], 'increment')
end

function preset:in_1_set(atoms)
    self:set_param(atoms[1], atoms[2], atoms[3], 'set')
end
