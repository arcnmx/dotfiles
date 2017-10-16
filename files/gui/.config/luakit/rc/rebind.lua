local lousy = require "lousy"

return function (mode, new_bind, old_bind, remove)
    -- remove old_bind defaults to true
    -- note: requires lousy.bind.convert_bind_syntax
    -- example: "d" -> "<d>" and "D" -> "<shift-d>"
    for i, m in ipairs(mode.binds) do
        if m[1] == old_bind then
            lousy.bind.remove_bind(mode.binds, new_bind)
            if remove == false then
                table.insert(mode.binds, { m[1], m[2], m[3] })
            end
            m[1] = new_bind
            return
        end
    end
    msg.warn("failed to remap binding " .. old_bind)
end

-- vim: et:sw=4:ts=8:sts=4:tw=80
