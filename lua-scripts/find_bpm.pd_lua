local find_bpm = pd.Class:new():register("find_bpm")

function find_bpm:initialize(_,atoms)
    self.inlets = 2
    self.outlets = 2
    self.smp_rate = 48
    -- optionally uses 1st arg as sample rate
    if type(atoms[1]) == "number" then
        self.smp_rate = atoms[1] / 1000
    end
    return true
end

function find_bpm:in_2_float(smp_rate)
    self.smp_rate = smp_rate / 1000
end

function find_bpm:in_1_float(length)
    local duration = length / self.smp_rate
    local ntimes = -1
    print(length)
    print(duration)
    -- determine minimum beat duration, this case should be < than 60bpm or 1sec
    while duration >= 900 do
        duration = duration / 2
        ntimes = ntimes + 1
    end
    -- divide 60000 by duration to find bpm
    self:outlet(1, "float", {60000 / duration})
    self:outlet(2, "float", {ntimes})
end
