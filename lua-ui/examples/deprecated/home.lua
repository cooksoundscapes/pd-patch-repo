LastPage = "home"

local menu = require("components.menu")
local scrollbar = require("components.scrollbar")
local cmd_runner = require("lib.cmd_runner")

local audio_page = require("home_audio")
local network_page = require("home_network")
local midi_page = require("home_midi")

local pd_menu = require("pd_menu")
pd_menu:init()
local pd_menu_entry = {
	name = "failed to load PD patches"
}
if pd_menu ~= nil then
	pd_menu_entry.name = "load PD patch"
	pd_menu_entry.submenu = pd_menu.entries
end

local current_view = "menu"

local views = {}

----------------- main menu setup --------------------
local main_menu = menu:new()
main_menu.entries = {
	pd_menu_entry,
	{
		name = "audio settings",
		action = function()
			current_view = "audio_settings"
			views.audio_settings:init(cmd_runner)
		end
	},
	{
		name = "MIDI settings",
		action = function()
			current_view = "midi_settings"
			views.midi_settings:init(cmd_runner)
		end
	},
	{
		name = "OSC settings",
		action = function()
			current_view = "osc_settings"
		end
	},
	{
		name = "system settings",
		submenu = {
			{
				name = "network",
				action = function()
					current_view = "network"
					views.network:init(cmd_runner)
				end
			},
			{
				name = "reboot system",
				action = function()
					current_view = "rebooting"
					os.execute("sudo reboot")
				end
			},
			{
				name = "shutdown",
				action = function()
					current_view = "shutting_down"
					os.execute("sudo poweroff")
				end
			},
		},
	},
}

--------------------- views -------------------------

views = {
	menu = {
		draw = function()
			main_menu:draw()
			scrollbar(
				main_menu:get_entries_count(),
				main_menu.selected,
				0,
				0,
				screen_w,
				screen_h
			)
		end,
		encoder = function(self, pin, value)
			if pin == 1 then
				main_menu:select(value)
			end
		end,
		action = function()
			main_menu:call()
		end,
	},

	osc_settings = {
		draw = function()
			text("OSC settings")
		end
	},

	midi_settings = midi_page,

	network = network_page,

	audio_settings = audio_page,

	shutting_down = {
		draw = function()
			text("Shutting down...")
		end
	},

	rebooting = {
		draw = function()
			text("Rebooting...")
		end
	},
}

function Draw()
	SetColor(Color.white)
	views[current_view]:draw()
end

----------------------- input ----------------------

local button_action = {
	function() -- home button
		load_module(app, LastPage)
	end,
	function() -- "left" button
		if current_view ~= "menu" then
			current_view = "menu"
		else
			main_menu:back()
		end
	end,
	function() -- "right" button
		views[current_view]:action()
	end
}

-- MINIMIM: botoes 2, 4 e 5 sao -1/1, botoes 1 e 3 sao 1/-1
local buttonmap = {1,-1,1,-1,-1}

function PanelInput(device, pin, value)
	if cmd_runner:is_running() == true then return end
	-- apenas pra minimim
	-- local press_value = buttonmap[pin]
	-- megazord
	local press_value = -1

	if device == "encoders" then
		views[current_view]:encoder(pin, value)
	elseif
			value == press_value and
			device == "nav_buttons" and
			pin <= 3
	then
		button_action[pin]()
	end
end
