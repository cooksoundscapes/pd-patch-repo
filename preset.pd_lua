local preset = pd.Class:new():register('preset')


local function append_lib_path()
    local home = os.getenv("HOME")
    local lib_path = home .. "/pd/core-lib/?.lua;"
    if not string.find(package.path, lib_path, 1, true) then
        package.path = lib_path .. package.path
    end
end

--[[
    1st inlet takes care of PRESETS;
    2nd inlet takes care of MODULES;
]]

function preset:initialize()
    append_lib_path()
    self.inlets = 2
    self.outlets = 1
    self.loaded_modules = {}
    return true
end

-- add module
function preset:in_2_add(atoms)
    local module_name = atoms[1]
    local receiver = atoms[2]

    if not module_name then
        pd.error("'add' needs module name as 1st arg;")
        return
    end

    local mod_factory = require('presets.modules.' .. module_name)
    if mod_factory then
        local instance = mod_factory.new()
        instance.receiver = receiver or module_name
        self:reset(instance)
        self.loaded_modules[module_name] = instance -- a definir: sempre name ou receiver?
    end
end

function preset:in_2_remove(atoms)
    local m_name = atoms[1]
    self.loaded_modules[m_name] = nil
end

-- prints out loaded modules
function preset:in_2_bang()
    for k,_ in pairs(self.loaded_modules) do
        self:outlet(1, "loaded", {k})
    end
end

-- load preset
function preset:in_1_load(atoms)
    local preset_name = atoms[1]
    local preset_module = require("presets." .. preset_name)

    if not preset_module then
        pd.error("Invalid preset name" .. preset_name)
        return
    end

    local applied_params = {}

    if preset_module.defaults then
        -- aplica defaults definidos no preset
        for _, def in ipairs(preset_module.defaults) do
            local module = def[1]
            local param  = def[2]
            local value  = def[3]

            self.loaded_modules[module][param]:set(value)
            self:send_param(module, param)
            applied_params[param] = true
        end
    end
    -- reseta parâmetros não listados no defaults
    for _, module in pairs(self.loaded_modules) do
        self:reset(module, applied_params)
    end
    self.current_preset = preset_module
end

function preset:send_param(module, param)
    if self.loaded_modules[module].omit_module then
        pd.send(
            param,
            'float',
            self.loaded_modules[module][param]:get()
        )
        return
    end
    pd.send(
        module,
        param,
        self.loaded_modules[module][param]:get()
    )
end

function preset:in_1_reset()
    for _,m in pairs(self.loaded_modules) do
        self:reset(m)
    end
end

function preset:reset(m, skip) -- module instance
    skip = skip or {}
    for p_name,param in pairs(m) do
        if not skip[p_name] and param.set_default then
            param:set_default()
            pd.send(m.receiver, p_name, param:get())
        end
    end
end

--[[
a liberdade é total para definir os controles de um preset;
1 arg é sempre o nome do controller, que deve ser uma chave na table do preset;
o restante sao argumentos que a funçao definida no preset recebe, 1o sempre vem os modulos.
]]
function preset:in_1_controller(atoms)
    local c_type = table.remove(atoms, 1)
    if self.current_preset[c_type] then
        local changes = self.current_preset[c_type](
            self.loaded_modules,
            table.unpack(atoms)
        )
        if changes ~= nil then
            if changes.params ~= nil then
                for _,affected in ipairs(changes.params) do
                    local module = affected[1]
                    local param  = affected[2]
                    self:send_param(module, param)
                end
            end
            if changes.leds ~= nil then
                for led,state in pairs(changes.leds) do
                    pd.send(
                        'visuals',
                        'led',
                        {led, state and 1 or 0}
                    )
                end
            end
            
        end
    end
end
