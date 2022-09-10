local weapon_name = "Horn"
local weapon_type = 10

local sdk_weapon_type = sdk.find_type_definition("snow.player.Horn")
local gauge_field = sdk_weapon_type:get_field("<RevoltGuage>k__BackingField")

local Packet = require('udp_client')
local Instruction = Packet.Instruction
local BaseWeapon = require("base_weapon")
local utils = require('utils')
local setting = require('setting')
local BaseState = require('base_state')

local State = BaseState:new()

local weapon = BaseWeapon:new(weapon_type, weapon_name, {sdk_weapon_type:get_method("update")}, State)

function weapon:get_status(manager)    
    local status = {
        gauge = gauge_field:get_data(manager)
    }
    return status
end

function weapon:get_controller_config(new_state, changed, player)
    local left = Instruction.left_default()
    local right = Instruction.right_default()
    -- TODO edit right trigger config here
    return Packet:new(left, right)
end

return weapon
