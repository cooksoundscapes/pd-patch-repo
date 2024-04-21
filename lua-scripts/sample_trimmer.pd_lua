local sample_trimmer = pd.Class:new():register("sample_trimmer")

function sample_trimmer:initialize(_,atoms)
    self.inlets = 2
    self.outlets = 2
    self.start = 0
    self.length = 1
    if type(atoms[1]) == "number" then
        self.start = math.max(atoms[1], math.min(atoms[1], 1), 0)
    end
    if type(atoms[2]) == "number" then
        self.length = atoms[2]
    end
    return true
end

function sample_trimmer:in_1_bang()
    self:outlet(2, "float", {self.length})
    self:outlet(1, "float", {self.start})
end

function sample_trimmer:in_1_float(start)
    self.start = math.max(math.min(start, 1), 0)
    local diff = 1 - (self.length + start)
    local length = self.length
    if diff < 0 then
        length = math.max(math.min(length + diff, 1), 0)
    end
    self:outlet(2, "float", {length})
    self:outlet(1, "float", {self.start})
end

function sample_trimmer:in_2_float(length)
    self.length = math.max(math.min(length, 1 - self.start), 0)
    self:outlet(2, "float", {self.length})
    self:outlet(1, "float", {self.start})
end

function sample_trimmer:in_1_list(atoms)
    local start = atoms[1]

    local new_length = atoms[2]
    if new_length ~= nil then
        self.length = new_length
    end

    self.start = math.max(math.min(start, 1), 0)
    local diff = 1 - (self.length + self.start)
    local length = self.length
    if diff < 0 then
        length = math.max(math.min(length + diff, 1), 0)
    end
    self:outlet(2, "float", {length})
    self:outlet(1, "float", {self.start})
end

function sample_trimmer:in_2_list(atoms)
    local length = atoms[1]
    self.length = math.max(math.min(length, 1 - self.start), 0)
    self:outlet(2, "float", {self.length})
    self:outlet(1, "float", {self.start})
end