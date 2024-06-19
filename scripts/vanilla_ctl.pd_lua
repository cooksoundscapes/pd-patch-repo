local vanilla_ctl = pd.Class:new():register("vanilla_ctl")

local state = {
    empty = 0,
    stopped = 1,
    stop_cue = 2,
    rec = 3,
    rec_cue = 4,
    playing = 5,
    play_cue = 6,
    stop_rec_cue = 7
}

function vanilla_ctl:initialize(_,atoms)
    local home = os.getenv("HOME")
    package.path = home .. "/pd/core-lib/scripts/?.lua;" .. package.path

    self.seq_btn_actions = require("vanilla.seq_btn_actions")
    self.inlets = 1
    self.outlets = 2
    self.n_channel = atoms[1] or 0
    self.n_source = 4

    self.global_config = {
        title = "Untitled",
        bpm = 95,
        bar_size = 4,
        click_lvl = 0
    }
    self.press = -1 -- press value for the panel buttons
    self.current_page = "src_page"
    self.selected_ch = 1

    self.channels = {}
    for _=1,self.n_channel do
        table.insert(self.channels, {
            filename = "",
            input_vol = 1,
            direct_out = 1,
            own_bpm = 0,
            length = 0,
            trim_start = 0,
            trim_end = 0,
            loop = 1,
            reverse = 0,
            speed = 1,
            state = state.empty,
            sync = 0,
            auto_stop_rec = 0,
            recorded_bars = 0,
            input_channels = {1},
            rec_trig_threshold = 0
        })
    end
    return true
end

function vanilla_ctl:in_1_nav_buttons(atoms) end

function vanilla_ctl:in_1_seq_buttons(atoms)
    local btn = atoms[1]
    local bstate = atoms[2]
    if btn == nil or bstate == nil then return end
    self.seq_btn_actions(self, btn, bstate)
end

function vanilla_ctl:in_1_encoders(atoms) end

function vanilla_ctl:select_channel(ch)
    if self.channels[ch] == nil then return end

    self.selected_ch = ch
    for p,v in pairs(self.channels[self.selected_ch]) do
        if type(v) == "table" then
            self:outlet(2, p, v)
        else
            self:outlet(2, p, {v})
        end
    end
end