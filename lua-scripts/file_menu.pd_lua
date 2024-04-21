local file_menu = pd.Class:new():register("file_menu")

function file_menu:initialize(_, atoms)
    local home_dir = os.getenv("HOME")
    self.rootpath = home_dir .. "/samples"
    if type(atoms[1]) == "string" then
        -- looks for ~ abbreviation and substitute to actual HOME variable
        local tilde = string.find(atoms[1], "~")
        if tilde ~= nil and tilde == 1 then
            if home_dir ~= nil then
                atoms[1] = string.gsub(atoms[1], "~", home_dir)
            end
        end
        -- TODO remove trailing / if exists
        self.rootpath = atoms[1]
    end

    local handle = io.popen("ls " .. self.rootpath .. " -R")
    if handle == nil then
        self:error("error reading path")
        return false
    end
    self.dir_struct = {}

    -- folders will appear as "normal" files too,
    -- so we must filter them both while adding a folder
    -- or adding a normal file;
    local directories_names = {}
    local ref_dir = self.dir_struct
    for line in handle:lines() do
        -- match for directory; ":" is the last char
        local i = string.find(line, ":")
        local len = string.len(line)
        if i ~= nil and i == len then
            local dir = string.gsub(string.gsub(line, ":", ""), self.rootpath, "")
            local parent = self.dir_struct
            for sub in string.gmatch(dir, "([^/]+)") do
                table.insert(directories_names, sub)
                if parent[sub] == nil then
                    parent[sub] = {}
                end
                -- when adding new directory, check if the dir name is in the parent table as a string;
                -- if true, remove it
                local dupl_index = nil
                for ind,v in pairs(parent) do
                    if v == sub then
                        dupl_index = ind
                    end
                end
                if dupl_index ~= nil then
                    table.remove(parent, dupl_index)
                end
                parent = parent[sub]
                ref_dir = parent
            end
        elseif line ~= nil then
            local is_dir = false
            -- only add line to current directory if not a directory
            for _,d in pairs(directories_names) do
                if line == d then
                    is_dir = true
                end
            end
            if is_dir == false then
                table.insert(ref_dir, line)
            end
        end
    end
    handle:close()
    self.inlets = 1
    self.outlets = 2
    return true
end

function file_menu:stream_files(target_dir, path)
    for k,v in pairs(target_dir) do
        if type(v) == "table" then
            self:outlet(2, "symbol", {k})
        else
            self:outlet(1, "symbol", {path .. "/" .. v})
        end
    end
end

function file_menu:in_1_bang()
    self:stream_files(self.dir_struct, self.rootpath)
end

-- receives a list of symbols which must be a dir path
function file_menu:in_1_list(atoms)
    local target_dir = self.dir_struct
    local path = self.rootpath
    for _,d in pairs(atoms) do
        if type(d) == "string" then
            target_dir = target_dir[d]
            if target_dir == nil then return end
            path = path .. "/" .. d
        end
    end
    self:stream_files(target_dir, path)
end
