local begin_gauge_lv = nil

local function config(prev, now, changed)
    if changed.action_id and now.action_id == 161 then
        begin_gauge_lv = now.gauge_level
    end
    if Packet.current.right.after == nil and prev.action_id ~= 161 and now.action_id >= 163 and now.action_id <= 168 and now.gauge_level == 0 and not changed.gauge_level then
        if begin_gauge_lv ~= nil and begin_gauge_lv > 1 then
            return Packet:new(nil, Instruction.new_right():Vib():BeginDefault():VibFreq(30 * begin_gauge_lv))
        else
            return Packet.get_default()
        end
    end
    if changed.action_id and now.action_id == 404 then
        return Packet:new(nil, Instruction.new_right():PushBack())
    end
end
return config
