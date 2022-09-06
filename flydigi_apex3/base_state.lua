local BaseState = {}

function BaseState:new(action_id, action_bank_id, status)
    local newObj = {action_id = action_id, action_bank_id = action_bank_id}
    if status then
        for k, v in pairs(status) do
            newObj[k] = v
        end
    end            
    self.__index = self
    return setmetatable(newObj, self)
end

function BaseState:is_nil()
    local has_value = false
    for _, v in pairs(self) do 
        if v ~= nil then
            has_value = true
            break
        end
    end
    return not has_value
end

function BaseState:with_weapon()
    if self:is_nil() then return false end
    return self.action_bank_id == 100
end

function BaseState:is_hit()
    if self:is_nil() then return false end
    return self.action_bank_id == 1
end

function BaseState:changed(other)
    local changed = false
    local delta = {}
    for k, v in pairs(other) do
        if self[k] ~= v then
            changed = true
            delta[k] = true
        end
    end
    if not changed then return false end
    return delta
end

return BaseState