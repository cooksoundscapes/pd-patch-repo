local preset = pd.Class:new():register('preset')

function preset:initialize()
    self.inlets = 1
    self.outlets = 1
    return true
end

