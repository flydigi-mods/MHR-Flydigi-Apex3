local weapon_name = "ShortSword"
local weapon_type = 8

local Packet = require('flydigi_apex3.udp_client')
local Instruction = Packet.Instruction
local BaseWeapon = require("flydigi_apex3/base_weapon")
local utils = require('flydigi_apex3/utils')
local setting = require('flydigi_apex3/setting')
local BaseState = require('flydigi_apex3/base_state')

local weapon = BaseWeapon:new(weapon_type, weapon_name, {}, BaseState)

function weapon:get_status(manager)
    return {}
end

function weapon:get_controller_config(new_state, changed, player, config)
    local left = Instruction.left_default()
    local right = Instruction.right_default()
    -- TODO edit right trigger config here
    return Packet.new(left, right)
end

return weapon
