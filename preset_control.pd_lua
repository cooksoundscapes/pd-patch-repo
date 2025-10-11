local preset_control = pd.Class:new():register('preset_control')

local function append_lib_path()
    local home = os.getenv("HOME")
    local lib_path = home .. "/pd/core-lib/?.lua;"
    if not string.find(package.path, lib_path, 1, true) then
        package.path = lib_path .. package.path
    end
end


function preset_control:initialize()
    append_lib_path()
    self.inlets = 1
    self.outlets = 1
    self.nav_buttons_pressed = {
        [4]=false, -- shift
        [5]=false  -- assign
    }
    self.exp_pedal_assign = {
        inverted=false,
        module=nil,
        param=nil,
        min=0,
        max=1
    }
    self.current_bank = 0
    return true
end


function preset_control:in_1_loadmap(atoms)
    self.control_map = require('presets.' .. atoms[1])
    self.current_bank = 1
end

function preset_control:in_1_nav_buttons(atoms)
    local n = tonumber(atoms[1])
    local press = atoms[2]
    if n == nil or press == nil then
        self:error("DOOOH")
        return
    end
    self.nav_buttons_pressed[n] = press > 0
    -- signal outlet if shift was pressed!
end

function preset_control:in_1_seq_buttons(atoms)
    local press = atoms[2]
    if press > 0 then
        local n = tonumber(atoms[1])
        if n == nil or press == nil then
            self:error("DOOOH")
            return
        end
        if self.nav_buttons_pressed[5] then
            local param
            if n <= 4 then
                param = self.control_map[self.current_bank].normal[n]
            else
                param = self.control_map[self.current_bank].shift[n - 4]
            end
            if param then
                self.exp_pedal_assign.module = param[1]
                self.exp_pedal_assign.param = param[2]
                self.exp_pedal_assign.inverted = self.nav_buttons_pressed[4] -- shift pressed inverts
                self.exp_pedal_assign.min = 0
                self.exp_pedal_assign.max = 1
            end
            -- signal outlet about pedal assign
            return
        end
        self.current_bank = n
        -- signal outlet about bank change
    end
end

function preset_control:in_1_encoders(atoms)
    local n = tonumber(atoms[1])
    local direction = atoms[2]
    local param
    if not self.nav_buttons_pressed[4] then
        param = self.control_map[self.current_bank].normal[n]
    else
        param = self.control_map[self.current_bank].shift[n]
    end
    if param then
        self:outlet(1, 'increment', {param[1], param[2], direction})
    end
end

function preset_control:in_1_exp_pedal(atoms)
    local position = math.min(self.exp_pedal_assign.max, math.max(self.exp_pedal_assign.min, atoms[1]))
    self:outlet(1, 'pot', {self.exp_pedal_assign.module, position})
end
