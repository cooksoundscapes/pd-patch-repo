local keys = pd.Class:new():register("keys")

function keys:initialize(sel, atoms)
    self.inlets = 2
    self.outlets = 1
    if atoms[1] then
        self.octave = atoms[1] * 12
    else
        self.octave = 48
    end
    self.last_symbol = ""
    local order = {'a','w','s','e','d','f','t','g','y','h','u','j','k','o','l','p',{'ç', 'ccedilla'}}
    self.mapping = {}
    for i,k in ipairs(order) do
        if type(k) == "table" then
            for _,sk in pairs(k) do
                self.mapping[sk] = i-1
            end
        else
            self.mapping[k] = i-1
        end
    end

    return true
end

function keys:in_2_symbol(key)
    self.last_symbol = key
end

function keys:in_1_float(f)
    local note = self.mapping[self.last_symbol]
    if note then
        self:outlet(1, "list", {note + self.octave, f})
    end
end

function keys:in_1_octave(oct)
    self.octave = oct * 12
end

function keys:in_1(sel, atoms)
    local note = nil
    if sel == "symbol" then
        note = self.mapping[atoms[1]]
    else
        note = self.mapping[sel]
    end
    if note then
        note = note + self.octave
        self:outlet(1, "float", {note})
    end
end