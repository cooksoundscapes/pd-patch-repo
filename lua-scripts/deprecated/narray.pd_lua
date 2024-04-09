local narray = pd.Class:new():register("narray")

function narray:initialize(sel, atoms)
    self.inlets = 1
    self.outlets = 2
    self.data = {}
    self.index = 0
    return true
end

function narray:in_1(sel, atoms)
    -- add list to the end of the array
    if sel == "add" then
        table.insert(self.data, atoms)

    -- 1st atom is index, add list to index position
    elseif sel == "insert" and type(atoms[1]) == 'number' and #atoms > 1 then
        local index = table.remove(atoms, 1)
        table.insert(self.data, math.max(1, index), atoms)
    
    -- 1st atom is index; replaces item in index position with list
    elseif sel == "replace" and type(atoms[1]) == 'number' and #atoms > 1 then
        local index = table.remove(atoms, 1)
        self.data[math.max(1, index)] = atoms

    -- get list by index
    elseif sel == "get" and type(atoms[1]) == 'number' then
        local i = atoms[1] + 1
        if i <= #self.data and i > 0 then
            self:outlet(1, "list", self.data[i])
        end

    -- get all entries
    elseif sel == "getAll" then
        for key, value in pairs(self.data) do
            self:outlet(2, "list", value)
        end
    
    -- get array size
    elseif sel == "length" then
        self:outlet(1, "list", {#self.data})

    -- sort the array
    elseif sel == "sort" then
        table.sort(self.data, function(a, b) return a[1] > b[1] end)

    -- remove item in index position
    elseif sel == "remove" and type(atoms[1]) == 'number' then
        if atoms[1] <= #self.data and atoms[1] > 0 then
            table.remove(self.data, math.max(1, atoms[1]))
        end

    -- clears entire array
    elseif sel == "clear" then
        self.data = {}
        
    end
end