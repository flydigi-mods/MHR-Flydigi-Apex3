local c = {}

c.motion_control_type = sdk.find_type_definition("snow.player.PlayerMotionControl")
c.player_type = sdk.find_type_definition("snow.player.PlayerBase")

c.motion_control_late_update_method = c.motion_control_type:get_method("lateUpdate")
c.motion_control_player_field = c.motion_control_type:get_field("_RefPlayerBase")
c.motion_control_old_motion_id_field = c.motion_control_type:get_field("_OldMotionID")
c.motion_control_old_bank_id_field = c.motion_control_type:get_field("_OldBankID")

c.player_is_master_method = c.player_type:get_method("isMasterID")
c.player_weapon_type_field = c.player_type:get_field("_playerWeaponType") -- type userdata
c.player_update_method = c.player_type:get_method("update") -- type userdata

-- local a = c.player_type:get_field('ac') -- type table
-- c.player_check_muteki_method = c.player_type:get_method("checkMuteki")
-- c.player_check_super_armor_method = c.player_type:get_method("checkSuperArmor")
-- c.player_check_hyper_armor_method = c.player_type:get_method("checkHyperArmor")
-- c.player_is_guard_point_method = c.player_type:get_method("get_IsGuardActionDuration")
-- c.player_damage_reflex_method = c.player_type:get_method("get_DamageReflex")
-- c.player_damage_reflex_checking_field = c.player_damage_reflex_method:get_return_type():get_field("_IsChecking")

return c
