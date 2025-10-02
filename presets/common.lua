local M = {}

function M.simple_toggle(p)
    return function(press, state)
        if press == 127 then
            local is_on_args = p.is_on or p.on_activate or {}
            local is_on = true
            for _,v in ipairs(is_on_args) do
                is_on = is_on and state[v[1]][v[2]]:get() == v[3]
            end
            if not is_on then
                local on_activate = p.on_activate or {}
                for _,v in ipairs(on_activate) do
                    state[v[1]][v[2]]:set(v[3])
                end
            else
                local on_deactivate = p.on_deactivate or {}
                for _,v in ipairs(on_deactivate) do
                    state[v[1]][v[2]]:set(v[3])
                end
            end
            local params = {}
            for _,v in ipairs(p.on_activate) do
                table.insert(params, v)
            end
            return {
                params=params
            }
        end
    end
end

return M
