local BaseWeapon = {}
local utils = require('flydigi_apex3/utils')
local setting = require('flydigi_apex3/setting')


function BaseWeapon:get_status(manager)
    error("need to implement get_status for "..self.name..", "..self.type);
end


function BaseWeapon:update_controller_config(current_config, action_id, action_bank_id, player)
    error("need to impelment update_controller_config for "..self.name..", "..self.type)
end


function BaseWeapon:new(weapon_type, weapon_name, weapon_hook_names)
    local newObj = {type = weapon_type, name = weapon_name, on_update = nil, status = {}, hooks=weapon_hook_names, hooked = false}            
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
