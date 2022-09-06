local weapon_name = "SwitchAxe"
local weapon_type = 9

local sdk_weapon_type = sdk.find_type_definition("snow.player.SlashAxe")
local bottle_field = sdk_weapon_type:get_field("_BottleGauge")
local awake_field = sdk_weapon_type:get_field("_BottleAwakeGauge")

local BaseWeapon = require("flydigi_apex3/base_weapon")
local utils = require('flydigi_apex3/utils')
local setting = require('flydigi_apex3/setting')
local BaseState = require('flydigi_apex3/base_state')

local State = BaseState:new()

local weapon = BaseWeapon:new(weapon_type, weapon_name, {sdk_weapon_type:get_method("update")}, State)

function weapon:get_status(manager)    
    local status = {
        bottle = bottle_field:get_data(manager),
        awake = awake_field:get_data(manager)
    }
    return status
end

function weapon:get_controller_config(new_state, changed, player, config)
    local right = setting.right_default
    local left = setting.left_default
    -- TODO edit right trigger config here
    return {LeftTrigger=left, RightTrigger=right}
end

return weapon
