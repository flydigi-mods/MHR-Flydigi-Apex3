local weapon_name = "LongSword"
local weapon_type = 2
local weapon_hook_name = "snow.player.LongSword"

local sdk_weapon_type = sdk.find_type_definition("snow.player.LongSword")
local gauge_field = sdk_weapon_type:get_field("_LongSwordGauge")
local gauge_lv_field = sdk_weapon_type:get_field("_LongSwordGaugeLv")

local hooks = {}
hooks['snow.player.LongSword'] = "set_LongSwordGaugeLv"

local BaseWeapon = require("flydigi_apex3/base_weapon")
local utils = require('flydigi_apex3/utils')
local c = require('flydigi_apex3/cache')
local setting = require('flydigi_apex3/setting')

local weapon = BaseWeapon:new(weapon_type, weapon_name, {sdk_weapon_type:get_method("update")})

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


local State = {}

function State:new(action_id, action_bank_id, status)
    local newObj = {action_id = action_id, action_bank_id = action_bank_id, 
    gauge_level = status and status.gauge_level or nil,
    gauge = status and status.gauge or nil}            
    self.__index = self
    return setmetatable(newObj, self)
end

function State:with_weapon()
    if self:is_nil() then return false end
    return self.action_bank_id == 100
end

function State:is_hit()
    if self:is_nil() then return false end
    return self.action_bank_id == 1
end

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

function State:changed(other)
    local changed = false
    local delta = {}
    if self.action_id ~= other.action_id then
        changed = true
        delta['action_id'] = true
    end
    if self.action_bank_id ~= other.action_bank_id then
        changed = true
        delta['action_bank_id'] = true
    end
    if self.gauge_level ~= other.gauge_level then
        changed = true
        delta['gauge_level'] = true
    end
    if self.gauge ~= other.gauge then
        changed = true
        delta['gauge'] = true
    end
    if not changed then return false end
    return delta
end

function State:is_nil()
    return self.action_id == nil and self.action_bank_id == nil and self.gauge_level == nil and self.gauge == nil
end

local current_state = State:new()

function weapon:get_status(manager)
    -- if this weapon has more than one hooks, use manager:get_type_definition():get_name() to determine which manager this is.
    -- local manager_name =  manager:get_type_definition():get_full_name()
    -- log.debug("manager_name "..manager_name)
    -- local fields = manager:get_type_definition():get_fields()
    -- for i = 1, #fields do 
    --     log.debug("fields "..fields[i]:get_name())
    -- end
    
    local status = {
        gauge = gauge_field:get_data(manager)
        gauge_level = gauge_lv_field:get_data(manager)
    }
    return status
end

function weapon:update_controller_config(config, action_id, action_bank_id, player)
    local new_state = State:new(action_id, action_bank_id, self.status)
    if current_state == nil or current_state:is_nil() then
        current_state = new_state
        return false
    end
    local changed = current_state:changed(new_state)
    if not changed then return false end
    local right = setting.right_default
    if changed.action_bank_id then
        if current_state:is_sheathe() and new_state:is_hit() then
            utils.chat("防御失败")
            right = "PushBack"
        end
    end
    if new_state:with_weapon() then
        if changed.action_id then
            if new_state.action_id == shenweizidongzhaojia then
                utils.chat("神威自动招架")
                right = "PushBack"
            end
            if new_state.action_id == teshunadao then
                utils.chat("特殊纳刀")
                right = "PushBack"
            end
            if new_state.action_id == teshunadaowancheng then
                utils.chat("特殊纳刀完成")
                right = "VibHardHalf"
            end
            if new_state.action_id == shenweinadao then
                utils.chat("神威纳刀")
                right = "LockHalf"
            end
            if new_state.action_id == shenweixuli then
                utils.chat("神威纳刀完成")
                right = "Normal"
            end
            if new_state.action_id == shenweixuliwanchen then
                utils.chat("神威蓄力完成")
                right = "VibHardSlowBottom"
            end
        end

        if 163 <= new_state.action_id and new_state.action_id <= 168 and new_state.gauge_level < current_state.gauge_level then
            -- 神威蓄力
            utils.chat("气刃消耗到"..new_state.gauge_level)
            if new_state.gauge_level == 3 then 
                right = "Normal"
            end
            if new_state.gauge_level == 2 then
                right = "VibVerySoftBottom"
            end
            if new_state.gauge_level == 1 then
                right = "VibSoftBottom"
            end
            if new_state.gauge_level == 0 then
                right = "VibHardSlowBottom"
            end
        end
    end
    current_state = new_state
    if right and right ~= config.RightTrigger then
        config.RightTrigger = right
        utils.chat(right)
        return true
    end
    return false
end

return weapon
