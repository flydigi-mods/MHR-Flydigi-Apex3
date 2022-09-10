local weapon_name = "LightBowgun"
local weapon_type = 3

local Packet = require('udp_client')
local Instruction = Packet.Instruction
local BaseWeapon = require("base_weapon")
local utils = require('utils')
local setting = require('setting')
local BaseState = require('base_state')

local State = BaseState:new()

local weapon = BaseWeapon:new(weapon_type, weapon_name, {}, State)

function weapon:get_status(manager)    
    return {}
end

function weapon:get_controller_config(new_state, changed, player)
    local left = Instruction.left_default()
    local right = Instruction.right_default()
    -- TODO edit right trigger config here
    return Packet:new(left, right)
end

return weapon
