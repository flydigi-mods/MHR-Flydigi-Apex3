local weapon_name = "HeavyBowgun"
local weapon_type = 13

local BaseWeapon = require("flydigi_apex3/base_weapon")
local utils = require('flydigi_apex3/utils')
local setting = require('flydigi_apex3/setting')
local BaseState = require('flydigi_apex3/base_state')

local State = BaseState:new()

local weapon = BaseWeapon:new(weapon_type, weapon_name, {}, State)

function weapon:get_status(manager)    
    return {}
end

function weapon:get_controller_config(new_state, changed, player, config)
    local right = setting.right_default
    local left = setting.left_default
    -- TODO edit right trigger config here
    return {LeftTrigger=left, RightTrigger=right}
end

return weapon
