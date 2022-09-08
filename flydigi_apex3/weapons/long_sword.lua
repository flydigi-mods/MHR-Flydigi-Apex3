local weapon_name = "LongSword"
local weapon_type = 2
local weapon_hook_name = "snow.player.LongSword"

local sdk_weapon_type = sdk.find_type_definition("snow.player.LongSword")
local gauge_field = sdk_weapon_type:get_field("_LongSwordGauge")
local gauge_lv_field = sdk_weapon_type:get_field("_LongSwordGaugeLv")

local hooks = {}
hooks['snow.player.LongSword'] = "set_LongSwordGaugeLv"

local Packet = require('udp_client')
local Instruction = Packet.Instruction
local BaseWeapon = require("base_weapon")
local utils = require('utils')
local setting = require('setting')
local BaseState = require('base_state')

local shenweinadao = 161 -- 神威纳刀
local shenweizidongzhaojia = 173 -- 神威自动招架
local shenweinadaozhaojia = 162 -- 神威招架
local shenweixuli = 163 -- 神威蓄力 163-168
local shenweixuliwanchen = 164 -- 神威蓄力完成
local shenweixulihuabu = {165, 168}
local dahuixuan = 109 -- 大回旋
local shenweixulichudao = 172 -- 神威蓄力出刀
local teshunadao = 156 -- 特殊纳刀
local teshunadaowancheng = 152 -- 特殊纳刀完成
local juhebadaozhan = 154 -- 居合拔刀斩
local juhe = 155 -- 大居合
local hit_action_bank_id = 1 -- 被击中时 action_bank_id = 1


local State = BaseState:new()

function State:in_sacred_sheathe()
    -- 神威纳刀
    if self:with_weapon() then
        if 161 <= self.action_id and self.action_id <= 168 then
            return true
        end
    end
    return false
end

function State:in_special_sheathe()
    -- 特殊纳刀
    if self:with_weapon() then
        if self.action_id == 156 or self.action_id == 152 then
            return true
        end
    end
    return false
end

function State:is_sheathe()
    return self:in_sacred_sheathe() or self:in_special_sheathe()
end

local weapon = BaseWeapon:new(weapon_type, weapon_name, {sdk_weapon_type:get_method("update")}, State)

function weapon:get_status(manager)
    -- if this weapon has more than one hooks, use manager:get_type_definition():get_name() to determine which manager this is.
    -- local manager_name =  manager:get_type_definition():get_full_name()
    -- log.debug("manager_name "..manager_name)
    -- local fields = manager:get_type_definition():get_fields()
    -- for i = 1, #fields do 
    --     log.debug("fields "..fields[i]:get_name())
    -- end
    
    local status = {
        -- gauge = gauge_field:get_data(manager),
        gauge_level = gauge_lv_field:get_data(manager)
    }
    return status
end

function weapon:get_controller_config(new_state, changed, player, config)
    local left = Instruction.left_default()
    local right = Instruction.right_default()
    if changed.action_bank_id then
        if self.current_state:is_sheathe() and new_state:is_hit() then
            utils.chat("防御失败")
            right = Instruction:new():PushBack()
        end
    end
    if not changed.action_id and self.current_state.action_id == shenweixuliwanchen then
        return Packet:new()
    end
    if new_state:with_weapon() then
        if changed.action_id then
            if new_state.action_id == shenweizidongzhaojia then
                utils.chat("神威自动招架")
                right = Instruction:new():PushBack()
            end
            if new_state.action_id == teshunadao then
                utils.chat("特殊纳刀")
                right = Instruction:new():PushBack()
            end
            if new_state.action_id == teshunadaowancheng then
                utils.chat("特殊纳刀完成")
                right = Instruction.right_default():BeginOffset(-20)
            end
            if new_state.action_id == shenweinadaozhaojia then
                utils.chat("神威纳刀招架")
                right = Instruction.right_default():BeginOffset(-20)
            end
            if new_state.action_id == shenweinadao then
                utils.chat("神威纳刀")
                right = Instruction.right_default()
            end
            if new_state.action_id == shenweixuli then
                utils.chat("神威纳刀完成")
                right = Instruction:new():Resistant():ForceMax():BeginBottom(-20)
            end
            if new_state.action_id == shenweixuliwanchen then
                utils.chat("神威蓄力完成")
                right = Instruction:new():Vib():VibForceMax():VibFreq(3):ForceMin():BeginBottom(-20)
            end
        end

        if 163 <= new_state.action_id and new_state.action_id <= 168 then
            -- 神威蓄力
            if changed.gauge_level then
                utils.chat("气刃消耗到"..new_state.gauge_level)
            end
            if new_state.gauge_level == 3 then 
                right = Instruction:new():Resistant():ForceMax():BeginBottom(-20)
            end
            if new_state.gauge_level == 2 then
                right = Instruction:new():Vib():VibForce(10):VibFreq(20):ForceMin():BeginBottom(-40)
            end
            if new_state.gauge_level == 1 then
                right = Instruction:new():Vib():VibForce(30):VibFreq(50):ForceMin():BeginBottom(-40)
            end
            if new_state.gauge_level == 0 then
                right = Instruction:new():Vib():VibForceMax():VibFreq(3):ForceMin():BeginBottom(-40)
            end
        end
    end
    return Packet:new(left, right)
end

return weapon