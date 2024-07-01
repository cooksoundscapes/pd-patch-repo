return {
    src_page = function(self, btn, state)
        if state ~= self.press then return end
        if btn <= self.n_channel then
            self:select_channel(btn)
        end
    end
}