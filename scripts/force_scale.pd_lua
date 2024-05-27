local force_scale = pd.Class:new():register("force_scale")

local scale = {}

function force_scale:initialize(sel, atoms)
    self.inlets = 1
    self.outlets = 1
    for _,a in pairs(atoms) do
        table.insert(scale, a)
    end
    return true
end

function force_scale:in_1_float(note)
    if note == nil or type(note) ~= "number" then return end

    local base_note = (note % 12) + 0.5
    local octave = math.floor(note / 12)
    for i=1,#scale do
        if base_note <= scale[i] then
            self:outlet(1, "float", {scale[i]+(octave*12)})
            break
        end
    end
end