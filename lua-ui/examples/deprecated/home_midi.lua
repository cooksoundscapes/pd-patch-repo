local Timer = require("lib.timer")
local anim = require("components.text_anim")

local loading = anim:new()

local page = {
    init = function(self, cmd_runner)
        self.pd_ports = 0
        self.found_devices = {}
        cmd_runner:call("aconnect -l")
        local last_dev = ""
        for line in cmd_runner:lines() do
            local id,dev = line:match("client%s(%d+):%s'(.*)'")
            if dev ~= nil and id ~= nil then
                last_dev = dev
                self.found_devices[dev] = {id=id, ports={}}
            else
                local port,name = line:match("^%s*(%d+)%s'(.*)'")
                if port ~= nil and name ~= nil then
                    if last_dev == "Pure Data" then
                        self.pd_ports = self.pd_ports + 1
                    end
                    self.found_devices[last_dev].ports[port] = name
                end
            end
        end
        cmd_runner:close()
        -- for each saved connection, check if:
        for _,saved in pairs(self.saved_connections) do
            local input_exists = false
            local output_exists = false
            saved.ready = false
            -- connection name must exist in the found dev. keys
            for found,info in pairs(self.found_devices) do
                -- if the dev was found, check if it has the port number of the saved conn.
                if found == saved.input.name then
                    for port,_ in pairs(info.ports) do
                        if tonumber(port) == saved.input.port then
                            input_exists = true
                            saved.input.id = info.id
                            break
                        end
                    end
                end
                if found == saved.output.name then
                    for port,_ in pairs(info.ports) do
                        if tonumber(port) == saved.output.port then
                            output_exists = true
                            saved.output.id = info.id
                            break
                        end
                    end
                end
                if output_exists and input_exists then
                    saved.ready = true
                end
            end
        end
        self.ok_cooldown = Timer:new(function()
            self.ok_screen = false
            self.ok_cooldown.active = false
        end, 15)
    end,

    draw = function(self)
        self.ok_cooldown:tick()
        if self.ok_screen == true then
            text(loading:get())
            return
        end
        SetColor(Color.white)
        text("Pd MIDI Port Count: " .. self.pd_ports)
        move_to(0, FontSize)
        text("Saved Connections:")
        move_to(0, FontSize*2)
        for i,c in pairs(self.saved_connections) do
            SetColor(Color.red)
            local r = "X"
            if c.ready == true then
                SetColor(Color.green)
                r = "\u{2713}"
            end
            text(c.output.name .. "->" .. c.input.name .. ": " .. r)
            move_to(0, FontSize*(i+2))
        end
        move_to(screen_w - FontSize*5.5, screen_h - FontSize)
        text("connect all?")
    end,

    action = function(self)
        for _,con in pairs(self.saved_connections) do
            os.execute(
                "aconnect " .. con.output.id .. ":" .. con.output.port ..
                " " .. con.input.id .. ":" .. con.input.port)
        end
        self.ok_screen = true
        self.ok_cooldown.active = true
    end,

    encoder = function() end,

    ok_cooldown = nil,
    ok_screen = false,

    -- TODO: um mecanismo pra registrar novos!
    -- de repente salva em alguma config file.. 
    saved_connections = {
        {output={name="APC MINI", port=0, id=nil}, input={name="Pure Data", port=0, id=nil}, ready=false},
        {output={name="Pure Data", port=2, id=nil}, input={name="APC MINI", port=0, id=nil}, ready=false},
    },

    found_devices = {},

    pd_ports = 0,
}
return page