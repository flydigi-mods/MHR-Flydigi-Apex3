local weapon_name = "SwitchAxe"
local weapon_type = 1

local sdk_weapon_type = sdk.find_type_definition("snow.player.SlashAxe")
local bottle_field = sdk_weapon_type:get_field("_BottleGauge")
local awake_field = sdk_weapon_type:get_field("_BottleAwakeGauge")
local mode_method = sdk_weapon_type:get_method("get_Mode")

local BaseWeapon = require("flydigi_apex3/base_weapon")
local utils = require('flydigi_apex3/utils')
local setting = require('flydigi_apex3/setting')
local BaseState = require('flydigi_apex3/base_state')

local chongtianfanji = 181 -- 属性充填反击
local chongtianfanjijiuxu = 182 -- 属性充填反击就绪
local chongtianfanji_empty = 183 -- 属性充填反击耗尽
local jiefangbaolie = 184 -- 属性解放爆裂
local gaoshuchuzhongjie = 185 -- 高输出终结
local feixianglongjianzhunbei = 160 -- 飞翔龙剑准备
local feixianglongjianqifei = 161 -- 飞翔龙剑起飞
local feixiangtujin = 168 -- 飞翔龙剑突进准备
local feixiangtujinluodi = 169 -- 飞翔龙剑突进出发
local feixianglongjianluodi = 172 -- 飞翔龙剑落地
local zhanjichongneng = 164 -- 斩击充能
local tiechongsibufaright = 186 -- 独轮车右
local tiechongsibufaleft = 187 -- 独轮车左
local jinganglianfu_axe = 157 -- 金刚连斧
local jinganglianfu_sword = 166 -- 金刚连斧
local awake_max = 70
local mode_axe = 0
local mode_sword = 1
local to_sword_min_bottle = 38

local State = BaseState:new()

local weapon = BaseWeapon:new(weapon_type, weapon_name, {sdk_weapon_type:get_method("update")}, State)

function weapon:get_status(manager)    
    local status = {
        bottle = bottle_field:get_data(manager),
        awake = awake_field:get_data(manager),
        mode = mode_method:call(manager)
    }
    return status
end

function weapon:get_controller_config(new_state, changed, player, config)
    local right = setting.right_default
    local left = setting.left_default
    if changed.action_bank_id then
        if not self.current_state:is_hit() and new_state:is_hit() then
            right = "PushBack"
            left = "PushBack"
        end
    end
    if new_state.action_id == chongtianfanjijiuxu or new_state.action_id == chongtianfanji or self.current_state.action_id == chongtianfanjijiuxu then
        right = "VibHardTop"
    end
    if new_state.action_id == feixianglongjianzhunbei or new_state.action_id == feixianglongjianqifei then
        left = "VibHardTopHard"
    end
    if changed.action_id then
        if new_state.action_id == zhanjichongneng then
            left = "LockBottom"
        end
        if new_state.action_id == tiechongsibufaright or new_state.action_id == tiechongsibufaleft then
            left = "LockBottom"
        end
        if new_state.action_id == jinganglianfu_axe or new_state.action_id == jinganglianfu_sword then
            left = "VibHardTop"
        end
    end
    if self.current_state.mode == mode_axe then
        if new_state.bottle < to_sword_min_bottle then
            right = "VibHardTopHard"
        end
    end
    return {LeftTrigger=left, RightTrigger=right}
end

return weapon
