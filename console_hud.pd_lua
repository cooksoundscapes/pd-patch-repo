local console_hud = pd.Class:new():register('console_hud')


local function append_lib_path()
    local home = os.getenv("HOME")
    local lib_path = home .. "/pd/core-lib/?.lua;"
    if not string.find(package.path, lib_path, 1, true) then
        package.path = lib_path .. package.path
    end
end

function console_hud:initialize()
    append_lib_path()
    self.inlets = 3
    return true
end

function console_hud:in_3(atoms)
    local preset_name
    if atoms[1] == 'symbol' then
        preset_name = atoms[2]
    else
        preset_name = atoms[1]
    end

    self.loaded_preset = require("presets." .. preset_name)
    -- ja pode carregar na tela o bank1
end

function console_hud:in_2(atoms)
    -- esse inlet cuida de receber seq button ou nav buttons.
    -- nav buttons interessam 2: o shift (4) e o assign (5)
    -- seq buttons buscam no preset os 4 itens
    -- j
end

function console_hud:in_1(atoms)
    -- aqui vai receber as mensagens de monitor do preset handler e printar
end
