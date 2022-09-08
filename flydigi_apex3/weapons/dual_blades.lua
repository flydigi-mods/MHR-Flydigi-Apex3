local weapon_name = "DualBlades"
local weapon_type = 9

local sdk_weapon_type = sdk.find_type_definition("snow.player.DualBlades")
local demon_gauge_field = sdk_weapon_type:get_field("<KijinKyoukaGuage>k__BackingField")

local Packet = require('flydigi_apex3.udp_client')
local Instruction = Packet.Instruction
local BaseWeapon = require("flydigi_apex3/base_weapon")
local utils = require('flydigi_apex3/utils')
local setting = require('flydigi_apex3/setting')
local BaseState = require('flydigi_apex3/base_state')

local State = BaseState:new()

local weapon = BaseWeapon:new(weapon_type, weapon_name, {sdk_weapon_type:get_method("update")}, State)

function weapon:get_status(manager)    
    local status = {
        demon_gauge = demon_gauge_field:get_data(manager)
    }
    return status
end

function weapon:get_controller_config(new_state, changed, player, config)
    local left = Instruction.left_default()
    local right = Instruction.right_default()
    -- TODO edit right trigger config here
    return Packet.new(left, right)
end

return weapon
