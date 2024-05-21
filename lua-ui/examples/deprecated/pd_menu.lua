local pd_menu = {
	current_patch="",
	entries={},
	pdsend_port = "7779",
	pd_dir = "/home/now/pd",

	pdsend = function(self, msg)
		local command = "echo '" .. msg .. ";' | pdsend " .. self.pdsend_port
		print(command)
		os.execute(command)
	end,

	init = function(self)
		local file_handler = io.popen("ls ~/pd/*.pd")
		local count = #self.entries
		if count > 0 then
			for i=0,count do self.entries[i] = nil end
		end
		if file_handler ~= nil then
			for line in file_handler:lines() do
				local file_name = line:match(".+/([^/]+)")   -- Get the last part after the last '/'
				local patch_name = file_name:match("(.+)%..+") -- strip file extension
				table.insert(self.entries, {
					name = patch_name,
					action = function(_, name)
						-- if current path is not empty, close it first
						self:pdsend("pd dsp 0")
						self:pdsend("pd dsp 1")
						if self.current_patch ~= "" then
							local msg = "pd-" .. self.current_patch .. ".pd menuclose"
							self:pdsend(msg)
						else
							-- if current patch is empty, connect for 1st time
							for i=1,8 do
								os.execute("jack_connect pure_data:output_"..i.." craddle:input_"..i)
							end
						end
						self.current_patch = name
						local msg = "pd open " .. name .. ".pd " .. self.pd_dir
						self:pdsend(msg)
					end
				})
			end
			file_handler:close()
		end
	end
}

return pd_menu