local folder_stream = pd.Class:new():register("folder_stream")

--[[
    non-recursive file dump in a directory - hides subfolders
]]

function folder_stream:initialize(_,atoms)
    self.inlets = 1
    self.outlets = 1
    local home_dir = os.getenv("HOME")
    self.rootpath = home_dir .. "/pd"

    -- if arg_1 is present
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
    self.files = {}
    local handle = io.popen("ls -p " .. self.rootpath .. " | grep -v /")
    if handle == nil then return false end

    for line in handle:lines() do
        table.insert(self.files, line)
    end

    handle:close()
    return true
end

function folder_stream:in_1_bang()
    for i,f in pairs(self.files) do
        self:outlet(1, "list", {i-1, f})
    end
end