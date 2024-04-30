local fx_manager = pd.Class:new():register("fx_manager")

local all_params = {
    shifter = {
        {name="tone", default=0, max=24, min=-24, inc=1, postfix="T"}
    },
    drive = {
        {name="gain", default=0, max=100, min=0, inc=1, postfix="%"}
    },
    tremolo = {
        {name="wave", default=0, max=4, min=0, inc=1},
        {name="freq", default=0.5, max=18, min=0, inc=0.01, postfix="hz"}
    },
    flanger = {
        {name="rate", default=0.4, max=18, min=0, inc=0.01, postfix="hz"},
        {name="depth", default=20, max=500, min=5, inc=1, postfix="ms"},
        {name="coeff", default=-0.6, max=1, min=-1, inc=0.1}
    },
    chorus = {
        {name="level", default=0.5, min=0, max=1, inc=0.01},
        {name="rate", default=0.8, min=0, max= 12, inc=0.01, postfix="hz"},
        {name="intensity", default=8, min=0, max=20, inc=1, postfix="ms"},
        {name="waveform", default=0, min=0, max=1, inc=0.01}
    },
    crusher_pre = {
        {name="bitcrush", default=0, min=0, max=1, inc=0.001},
        {name="downsamp", default=1, min=0, max=1, inc=0.01, pow=3},
        {name="interp", default=0, min=0, max=1, inc=1}
    },
    crusher_post = {
        {name="bitcrush", default=0, min=0, max=1, inc=0.001},
        {name="downsamp", default=1, min=0, max=1, inc=0.01, pow=3},
        {name="interp", default=0, min=0, max=1, inc=1}
    },
    delay = {
        {name="dry", default=1, min=0, max=1, inc=0.01},
        {name="level", default=0, min=0, max=1, inc=0.01},
        {name="feedback", default=0.5, min=0, max=1, inc=0.01},
        {name="time", default=300, min=0.001, max=1, inc=0.01, mult=2000, pow=2, postfix="ms"},
        {name="pitch", default=0, max=24, min=-24, inc=1, postfix="T"},
        {name="magic", default=0, min=0, max=1, inc=0.01},
        {name="modInt", default=0, min=0, max=10, inc=1},
        {name="modRate", default=0, min=0, max=10, inc=0.01},
        {name="reverse", default=0, min=0, max=1, inc=1},
        {name="lp", default=1, min=0, max=1, pow=3, mult=18000, inc=0.005, postfix="hz"},
        {name="hp", default=0, min=0, max=1, pow=3, mult=18000, inc=0.005, postfix="hz"},
    },
    verb = {
        {name="level", default=0.5, min=0, max=1, inc=0.01, pow=2}
    },
}

local bypass = {
    {"drive",0},
    {"tremolo",0},
    {"chorus",0},
    {"delay",0},
    {"verb",0},
    {"shifter",0},
    {"flanger",0},
    {"crusher_post",0}
}

function fx_manager:initialize()
    self.inlets = 3
    self.outlets = 2
    self.selected_ch = 1
    self.selected_fx = "drive"
    self.selected_page = 1
    self.shift_is_pressed = false
    self.store = {}
    local channels = 4
    self.knob_count = 4
    for ch=1,channels do
        self.store[ch] = {}
        for fx,params in pairs(all_params) do
            self.store[ch][fx] = {}
            for i,param in pairs(params) do
                local page = math.ceil(i / self.knob_count)
                if self.store[ch][fx][page] == nil then
                    self.store[ch][fx][page] = {}
                end
                self.store[ch][fx][page][((i - 1) % self.knob_count) + 1] = {param.name, param.default}
            end
        end
    end
    return true
end

-- dump current state
function fx_manager:in_1_bang()
    self:setup_knob_ui()
end

-- seq buttons
function fx_manager:in_1_list(atoms)
    local button = atoms[1]
    local press = atoms[2]
    if button == nil or press == nil or press ~= 0 then return end

    local fx, active = table.unpack(bypass[button])

    if self.shift_is_pressed == 1 then
        self.selected_fx = fx
        self.selected_page = 1
        self:outlet(2, "list", {"set_fx", fx})
        self:outlet(2, "list", {"set_page", 1})
        self:outlet(2, "list", {"is_active", bypass[button][2]})
        self:setup_knob_ui()
    else
        local new_v = active ~ 1
        if self.selected_fx == fx then
            self:outlet(2, "list", {"is_active", new_v})
        end
        self:outlet(1, "list", {self.selected_ch, fx .. "_sw", new_v})
        bypass[button][2] = new_v
    end
end

-- nav buttons
function fx_manager:in_2_list(atoms)
    local button = atoms[1]
    local press = atoms[2]
    if button == nil or press == nil then return end

    if button == 4 then self.shift_is_pressed = press end
    
    if press ~= 1 then return end

    if button == 2 and self.selected_page > 1 then
        self.selected_page = math.max(1, self.selected_page - 1)
        self:outlet(2, "list", {"set_page", self.selected_page})
        self:setup_knob_ui()
    elseif button == 3 then
        local page_c = #self.store[self.selected_ch][self.selected_fx]
        self.selected_page = math.min(page_c, self.selected_page + 1)
        self:outlet(2, "list", {"set_page", self.selected_page})
        self:setup_knob_ui()
    end
end

-- encoders
function fx_manager:in_3_list(atoms)
    local knob = atoms[1]
    local direction = atoms[2]
    if knob == nil or direction == nil then return end

    local in_view = self:current_page()
    local param = in_view[knob]
    if param == nil then return end

    local param_name = param[1]
    local current = param[2]

    local info =  self:get_info(knob)

    local new_v = math.min(math.max(current + (direction * info.inc), info.min), info.max)
    self:set_param(knob, new_v)
    self:send_param_value(knob, info, new_v)
end

-- auxiliar methods
function fx_manager:current_page()
    return self.store[self.selected_ch][self.selected_fx][self.selected_page]
end

function fx_manager:set_param(pos, value)
    self.store[self.selected_ch][self.selected_fx][self.selected_page][pos][2] = value
end

function fx_manager:get_info(knob)
    local pos = knob + ((self.selected_page - 1) * self.knob_count)
    return all_params[self.selected_fx][pos]
end

function fx_manager:setup_knob_ui()
    local params = self:current_page()

    self:outlet(2, "list", {"param_amount", #params})
    for i,p in pairs(params) do
        local info = self:get_info(i)
        if info ~= nil then
            self:outlet(2, "list", {"focus", i})
            self:outlet(2, "list", {"label", info.name})
            self:outlet(2, "list", {"min", info.min})
            self:outlet(2, "list", {"max", info.max})
            self:outlet(2, "list", {"postfix", info.postfix})
            if info.inc == 1 then
                self:outlet(2, "list", {"int", 1})
            end
            self:send_param_value(i, info, p[2])
        end
    end
    
end

function fx_manager:send_param_value(i, info, value)
    if info.pow ~= nil then
        value = value ^ info.pow
        if info.mult ~= nil then
            value = value * info.mult
        end
    end
    self:outlet(2, "list", {"focus", i})
    self:outlet(2, "list", {"level", value})
    self:outlet(1, "list", {self.selected_ch, self.selected_fx, info.name, value})
    return value
end