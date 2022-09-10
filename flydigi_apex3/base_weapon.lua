local BaseWeapon = {}
local utils = require('utils')
local setting = require('setting')


function BaseWeapon:get_status(manager)
    error("need to implement get_status for "..self.name..", "..self.type);
end

function BaseWeapon:get_controller_config(new_state, changed, player, config)
    error("need to impelment get_controller_config for "..self.name..", "..self.type)
end

function BaseWeapon:update_controller_config(action_id, action_bank_id, player)
    local new_state = self.state_type:new(action_id, action_bank_id, self.status)
    if self.current_state == nil or self.current_state:is_nil() then
        self.current_state = new_state
        return false
    end
    local changed = self.current_state:changed(new_state)
    if not changed then return false end
    local new_config = self:get_controller_config(new_state, changed, player)
    self.current_state = new_state
    return new_config
end

function BaseWeapon:new(weapon_type, weapon_name, weapon_hook_names, state_type)
    local newObj = {
        type = weapon_type, name = weapon_name, on_update = nil, 
        status = {}, hooks=weapon_hook_names, hooked = false,
        state_type = state_type
    }
    newObj['current_state'] = state_type:new()            
    self.__index = self
    return setmetatable(newObj, self)
end


local function status_update_static_func(weapon)
    return function(args)
        if not setting.enable then return end
        BaseWeapon.status_update(weapon, args)
    end
end


function BaseWeapon:status_update(args)
    if self.on_update == nil then 
        return
    end
    manager = utils.get_manager(args)
    status = self:get_status(manager)
    local changed = false
    for k, v in pairs(status) do 
        if self.status[k] ~= v then
            changed = true
            self.status[k] = v
        end
    end
    if changed then
        self.on_update()
    end
end


function BaseWeapon:hook()
    if self.hooked then
        return
    end
    log.debug("hooking for "..self.name)
    for _, hook in ipairs(self.hooks) do
        sdk.hook(hook, status_update_static_func(self), function(retval) return retval end)
    end
    self.hooked = true
end


return BaseWeapon
