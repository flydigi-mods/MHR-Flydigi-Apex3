local utils = require('utils')
local c = require('cache')
local setting = require('setting')
local Config = require('udp_client')
local BaseWeapon = require('base_weapon')
local Instruction = Config.Instruction

local udp_path = "./flydigi_apex3/udp_client"
if utils.os == 'windows' then
    udp_path = string.match(package.path, "(.-)([^\\/]-)?.lua;"):gsub("lua\\$", "").."\\udp_client"
end
Config.setup(udp_path, json.dump_string, 
Instruction.new_left():Resistant():ForceMax():Begin(setting.left_default_lock_pos):AdaptOutputData(true),
Instruction.new_right():Resistant():ForceMax():Begin(setting.right_default_lock_pos):AdaptOutputData(true),
function() return setting.udp_port end
)
Config.current = Config.get_default()
Config.current:send()

local action_id
local action_bank_id
local player 
local current_weapon_type
local current_weapon

local function update_controller_config(new_config)
    Config.current:change(new_config)
end

local function reset_default_controller_config()
    Config.current:change(Config.get_default())
end

local function on_update()
    if current_weapon then
        local new_config = current_weapon:update_controller_config(action_id, action_bank_id, player)
        if new_config and not new_config:is_nil() then
            update_controller_config(new_config)
        end
    end
end

reset_default_controller_config()

local function get_current_weapon()
    return BaseWeapon.get_weapon(current_weapon_type)
end

local function find_current_weapon_type() 
    local player_def = player:get_type_definition():get_name()
    if player_def == "PlayerLobbyBase" then 
        if current_weapon then
            current_weapon.on_update = nil
            current_weapon = nil
            reset_default_controller_config()
        end
        current_weapon_type = nil
        return
    end 
    if player_def ~= current_weapon_type then
        current_weapon_type = player_def
        if current_weapon then
            current_weapon.on_update = nil
        end
        current_weapon = get_current_weapon()
        reset_default_controller_config()
        if current_weapon then
            current_weapon.on_update = on_update
            utils.chat("Weapon "..current_weapon.name)
        end
    end
end

sdk.hook(c.motion_control_late_update_method,
function(args)
    if not setting.enable then return end
	local motionControl = utils.get_manager(args)
    
	local refPlayerBase = c.motion_control_player_field:get_data(motionControl)
    if not refPlayerBase then return end
    local isMasterPlayer = c.player_is_master_method:call(refPlayerBase)
    if not isMasterPlayer then return end
    player = refPlayerBase

    local new_action_id = c.motion_control_old_motion_id_field:get_data(motionControl)
    local new_action_bank_id = c.motion_control_old_bank_id_field:get_data(motionControl)
    
    if new_action_id == action_id and new_action_bank_id == action_bank_id then
        return
    end

    action_id = new_action_id
    action_bank_id = new_action_bank_id

    find_current_weapon_type()
    
    if not current_weapon then
        return
    end
    
    on_update()
end,
function(retval) return retval end
)

sdk.hook(c.player_update_method, function(args)
    if not setting.enable then return end
    local p = utils.get_manager(args)
    local isMasterPlayer = c.player_is_master_method:call(p)
    if not isMasterPlayer then return end
    player = p
    find_current_weapon_type()
    if not current_weapon then return end
    current_weapon:status_update(player)
end, function(retval) return retval end)

local font = nil
if d2d then
    d2d.register(function()
        font = d2d.Font.new("Arial", setting.font_size)
    end, function()
        if not setting.debug_window then return end
        if not font then return end
        if player == nil then return end
        local str = "In Lobby"
        if player:get_type_definition():get_name() ~= "PlayerLobbyBase" then 
            str = "Act: "..action_id..", Bank: "..action_bank_id
            if current_weapon_type then
                str = str.."\n"..current_weapon_type
                if current_weapon then
                    for k, v in pairs(current_weapon.status) do
                        str = str.."\n"..k..": "..v
                    end
                end
            end
            if Config.current then
                local left = Config.current.left
                local right = Config.current.right
                if left ~= nil and not left:is_nil() then
                    str = str.."\nLT: "..left.mode.." "..left.param1.." "..left.param2.." "..left.param3.." "..left.param4
                end
                if right ~= nil and not right:is_nil() then
                    str = str.."\nRT: "..right.mode.." "..right.param1.." "..right.param2.." "..right.param3.." "..right.param4
                end
            end
        end 
        local w, h = font:measure(str)
        local screen_w, screen_h = d2d.surface_size()
        local margin = 40
        local padding = 2
        d2d.fill_rect(margin, screen_h - margin - h - padding * 2, w + padding * 2, h + padding * 2, 0x44000000)
        d2d.text(font, str, margin + padding, screen_h - margin - padding - h, 0x99FFFFFF)
    end)
end

re.on_frame(function() 
    if Config.current ~= nil then
        Config.current:tick()
    end
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

require("ui")
