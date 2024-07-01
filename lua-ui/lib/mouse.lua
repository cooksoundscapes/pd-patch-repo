return {
    start_x = 0,
    start_y = 0,
    delta_x = 0,
    delta_y = 0,
    drag_areas = {},
    is_dragging = false,
    areas = {}, -- {id=number, x=number, y=number, w=number, h=number, click=fn, drag=fn, release=fn}
    _drag = function(self)
        for _,a in pairs(self.drag_areas) do
            a:drag(self.delta_x, self.delta_y)
        end
    end,
    _release = function(self)
        for _,a in pairs(self.drag_areas) do
            if a.release ~= nil then
                a:release()
            end
        end
    end,
    _test = function(self, area)
        if
        mouse_x >= area.x and mouse_x <= (area.x + area.w) and
        mouse_y >= area.y and mouse_y <= (area.y + area.h) then
            if area.click ~= nil then
                area:click()
            end
            if area.drag ~= nil then
                table.insert(self.drag_areas, area)
            end
        end
    end,

    check = function(self)
        if self.is_dragging == false and mouse_button > 0 then
            self.is_dragging = true
            self.start_x = mouse_x
            self.start_y = mouse_y
            for _,a in pairs(self.areas) do
                self:_test(a)
            end
        elseif mouse_button == 0 then
            self:_release()
            self.is_dragging = false
            self.drag_areas = {}
        elseif self.is_dragging == true then
            local delta_x = mouse_x - self.start_x
            local delta_y = mouse_y - self.start_y
            if delta_x ~= self.delta_x or delta_y ~= self.delta_y then
                self.delta_x = delta_x
                self.delta_y = delta_y
                self:_drag()
            end
        end
    end,

    add_area = function(self, area)
        if
        type(area.x) ~= "number" or
        type(area.y) ~= "number" or
        type(area.w) ~= "number" or
        type(area.h) ~= "number" then
            print("Error while adding new area to Mouse: invalid bounding box.")
            return
        end
        table.insert(self.areas, area)
    end,

    remove_area_by_id = function(self, id)
        local r
        for i,a in pairs(self.areas) do
            if a.id ~= nil and a.id == id then
               r = i
            end
        end
        if r ~= nil then
            self.areas[r] = nil
        end
    end,
}