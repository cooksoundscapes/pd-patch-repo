local gen_file_tree = pd.Class:new():register("gen_file_tree")

function gen_file_tree:initialize(_, atoms)
    self.inlets = 2
    self.outlets = 1
    self.base_x = 20
    self.base_y = 20
    self.obj_count = 0
    self.obj_height = 24
    self.indent = 20
    return true
end

function gen_file_tree:in_2_bang()
    self.obj_count = 0
end

function gen_file_tree:make_obj(type, name, level, args)
    local pd_msg = {
        self.base_x + (level * self.indent),
        self.base_y + (self.obj_count * self.obj_height),
        name
    }
    for _,v in pairs(args) do
        table.insert(pd_msg, v)
    end
    self:outlet(1, type, pd_msg)
    self.obj_count = self.obj_count + 1
end

function gen_file_tree:in_1_file(atoms)
    if #atoms ~= 3 then return end
    local name = atoms[1]
    local path = atoms[2]
    local level = atoms[3]
    self:make_obj("obj", "sample-file", level, {name, path})
end


function gen_file_tree:in_1_dir(atoms)
    if #atoms ~= 3 then return end
    local name = atoms[1]
    local path = atoms[2]
    local level = atoms[3]
    self:make_obj("obj", "folder-file", level, {name, path .. "/" .. name})
end