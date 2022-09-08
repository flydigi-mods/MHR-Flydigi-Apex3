local weapon_modules = {
    'great_sword', 'long_sword', 'short_sword', 'dual_blades',
    'lance', 'gun_lance', 'hammer', 'horn', 'switch_axe', 'charge_axe',
    'insect_glaive', 'light_bowgun', 'heavy_bowgun', 'bow'
}

local utils = require('flydigi_apex3.utils')
local c = require('flydigi_apex3.cache')
local setting = require('flydigi_apex3.setting')
local Config = require('flydigi_apex3.udp_client')

local udp_path = "./flydigi_apex3/udp_client"
if utils.os == 'windows' then
    udp_path = string.match(package.path, "(.-)([^\\/]-)?.lua;"):gsub("lua\\$", "").."reframework\\autorun\\flydigi_apex3\\udp_client"
end
Config.load(udp_path)

local action_id
local action_bank_id
local player 
local current_weapon_type
local current_weapon
local current_controller_config = Config.get_default()

local function load_weapon(name) 
    return require('flydigi_apex3.weapons.'..name)
end

local weapons = {}
for _, name in ipairs(weapon_modules) do
    local weapon = load_weapon(name)
    weapons[weapon.type] = weapon
end

local function update_controller_config(new_config)
    if current_controller_config:equal(new_config) then return end
    local delta = current_controller_config:delta(new_config)
    if delta:is_nil() then return end
    if delta:send() then
       current_controller_config = new_config
    end
end

local function reset_default_controller_config()
    update_controller_config(Config.get_default())
end

local function on_update()
    if current_weapon then
        local new_config = current_weapon:update_controller_config(current_controller_config, action_id, action_bank_id, player)
        if new_config and not new_config:is_nil() then
            update_controller_config(new_config)
        end
    end
end

reset_default_controller_config()

sdk.hook(c.motion_control_late_update_method,
function(args)
    if not setting.enable then return end
	local motionControl = utils.get_manager(args)
    local new_action_id = c.motion_control_old_motion_id_field:get_data(motionControl)
    local new_action_bank_id = c.motion_control_old_bank_id_field:get_data(motionControl)
    
    if new_action_id == action_id and new_action_bank_id == action_bank_id then
        return
    end

    action_id = new_action_id
    action_bank_id = new_action_bank_id

	local refPlayerBase = c.motion_control_player_field:get_data(motionControl)
    if not refPlayerBase then return end
    local isMasterPlayer = c.player_is_master_method:call(refPlayerBase)
    if not isMasterPlayer then return end
    player = refPlayerBase
    local weapon_type = c.player_weapon_type_field:get_data(player)
    if weapon_type == nil and current_weapon_type == nil then
        return
    end
    if weapon_type == nil and current_weapon_type then
        if current_weapon then
            current_weapon.on_update = nil
            current_weapon = nil
            reset_default_controller_config()
        end
        current_weapon_type = nil
        return
    end
    if weapon_type ~= current_weapon_type then
        current_weapon_type = weapon_type
        if current_weapon then
            current_weapon.on_update = nil
        end
        current_weapon = weapons[current_weapon_type]
        reset_default_controller_config()
        if current_weapon then
            current_weapon.on_update = on_update
            if not current_weapon.hooked then
                current_weapon:hook()
            end
            utils.chat("Weapon "..current_weapon.name.." "..tostring(current_weapon_type))
        else
            return
        end
    end
    if not current_weapon then
        return
    end

    on_update()
end,
function(retval) return retval end
)

local font = nil
if d2d then
    d2d.register(function()
        font = d2d.Font.new("Arial", setting.font_size)
    end, function()
        if not setting.debug_window then return end
        if not font then return end
        local str = "Act: "..action_id..", Bank: "..action_bank_id
        if current_weapon then
            for k, v in pairs(current_weapon.status) do
                str = str.."\n"..k..": "..v
            end
        end
        local w, h = font:measure(str)
        local screen_w, screen_h = d2d.surface_size()
        local margin = 40
        local padding = 2
        d2d.fill_rect(margin, screen_h - margin - h - padding * 2, w + padding * 2, h + padding * 2, 0x99000000)
        d2d.text(font, str, margin + padding, screen_h - margin - padding - h, 0xCCFFFFFF)
    end)
end

re.on_frame(function() 
    if d2d and font then return end
    if setting.debug_window then
        if imgui.begin_window("Flydigi Apex3 Debug", true, 64) then
            if action_id ~= nil and action_bank_id ~= nil then 
                imgui.text("Act: "..tostring(action_id)..", Bank: "..action_bank_id)
            end
            if current_weapon then
                for k, v in pairs(current_weapon.status) do
                    imgui.text(k..":"..v)
                end
            end
            imgui.end_window()
        else
            setting.debug_window = false
        end
    end
end)

require("flydigi_apex3/ui")
