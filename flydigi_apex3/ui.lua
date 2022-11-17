local setting = require("setting")
local version = require("version")
local Packet = require("udp_client")
local utils = require('utils')
local BaseWeapon = require("base_weapon")
local Instruction = Packet.Instruction

local default_lock_pos_min = 50
local default_lock_pos_max = 200

local begin_test_udp_time = 0
local test_udp_secs = 5
local test_udp_result = false

local left_trigger_code = 512
local right_trigger_code = 2048

local packet

local about = "made by @songchenwen"

local function current_timestamp()
    return os.time(os.date("!*t"))
end

local function is_testing_udp()
    return current_timestamp() - begin_test_udp_time <= test_udp_secs
end

local function test_udp()
    begin_test_udp_time = current_timestamp()
    local vib = Instruction:new():Vib():VibForceMax():VibFreq(40):BeginTop():ForceMin()
    local p = Packet:new(vib, vib:clone())
    if p:send() then
        packet = p
        return true
    end
    return false
end

local function reset_controller()
    if packet == nil then return end
    local r = Packet:new(Instruction.left_default(), Instruction.right_default())
    if packet:delta(r):is_nil() then
        packet = nil
    else
        if r:send() then packet = nil end
    end
end

local function controller_default_changed()
    Packet.set_default(
        Instruction:new():Resistant():ForceMax():Begin(setting.left_default_lock_pos),
        Instruction:new():Resistant():ForceMax():Begin(setting.right_default_lock_pos)
    )
    Packet.get_default():send()
end

local function reload_weapon_configs()
    for _, w in pairs(BaseWeapon.weapons) do
        w:reload_configs()
    end
end

re.on_frame(function()
    if packet == nil then return end
    if not is_testing_udp() then reset_controller() end
end)

local function is_module_available(name)
    if package.loaded[name] then
      return true
    else
      for _, searcher in ipairs(package.searchers or package.loaders) do
        local loader = searcher(name)
        if type(loader) == 'function' then
          package.preload[name] = loader
          return true
        end
      end
      return false
    end
end

local modUI = nil

if is_module_available("ModOptionsMenu.ModMenuApi") then
	modUI = require("ModOptionsMenu.ModMenuApi")
end

local delay_test_trigger_offset = 20
local testing_delay_max_secs = 6
local testing_delay_begin_time = nil
local delay_secs = nil
local delay_frames = nil
local rt_down_time = nil
local socket = Packet.client.socket
local testing_delay_packet1 = Packet:new():Right(Instruction:new():Resistant():ForceMax():BeginTop(delay_test_trigger_offset):AdaptOutputData(true))
local testing_delay_packet2 = testing_delay_packet1:clone()
testing_delay_packet2:Right():AdaptOutputData(false)

local function test_delay()
    local sent = testing_delay_packet1:send()
    if not sent then return end
    delay_secs = nil
    rt_down_time = nil
    testing_delay_begin_time = current_timestamp()
    modUI.Repaint()
end

local function end_test_delay()
    rt_down_time = nil
    testing_delay_begin_time = nil
    Packet.get_default():send()
    modUI.Repaint()
end

re.on_frame(function()
    if testing_delay_begin_time == nil then return end
    local rt_down = utils.is_rt_down()
    if rt_down_time ~= nil then
        delay_frames = delay_frames + 1
        if not rt_down then
            delay_secs = socket.gettime() - rt_down_time
            end_test_delay()
        end
        modUI.Repaint()
        return
    end
    if rt_down_time == nil and rt_down then
        testing_delay_packet2:send()
        delay_frames = 0
        rt_down_time = socket.gettime()
        return
    end
    if current_timestamp() - testing_delay_begin_time > testing_delay_max_secs then 
        end_test_delay()
    end
end)

local right_default_changed = false
local left_default_changed = false
if modUI then
    modUI.OnMenu("飞智八爪鱼3", "飞智八爪鱼3手柄支持", function()
        if modUI.version < 1.6 then
			modUI.Label("Please update mod menu API.")
            return
        end
        modUI.Header("飞智八爪鱼3")
        _, setting.enable = modUI.CheckBox("开启自适应扳机", setting.enable, "开启自适应扳机")
        left_default_changed, setting.left_default_lock_pos = modUI.Slider("左扳机默认扳机锁位置", setting.left_default_lock_pos, default_lock_pos_min, default_lock_pos_max)
        right_default_changed, setting.right_default_lock_pos = modUI.Slider("右扳机默认扳机锁位置", setting.right_default_lock_pos, default_lock_pos_min, default_lock_pos_max)
        if left_default_changed or right_default_changed then
            controller_default_changed()
        end
        _, setting.udp_port = modUI.Slider("飞智空间站端口号", setting.udp_port, 1024, 65535)
        local reset_default = modUI.Button("恢复默认设置")
        if reset_default then setting.reset_default() end
        local reload_w = modUI.Button("重载武器配置")
        if reload_w then reload_weapon_configs() end
        if testing_delay_begin_time == nil then
            local to_test_delay = modUI.Button("测试扳机配置延迟")
            if to_test_delay then 
                test_delay()
            end
        else
            if delay_secs == nil then
                local time_str = ""
                for i = 1, testing_delay_max_secs - (current_timestamp() - testing_delay_begin_time) do
                    time_str = time_str.."."
                end
                modUI.Label("请按住右扳机并保持不动"..time_str)
            end
        end
        if delay_secs ~= nil or testing_delay_begin_time ~= nil then
            local delay_str = "..."
            if delay_secs ~= nil then
                delay_str = string.format("%.0fms", delay_secs * 1000)
                if delay_frames > 0 then
                    delay_str =  delay_str..", "..tostring(delay_frames).."帧"
                end
            end
            modUI.Label("延迟: "..delay_str)
        end
        if version then
            modUI.Label("版本: "..version)
        end
        modUI.Header(about)
        modUI.IncreaseIndent()
            if is_testing_udp() then
                if test_udp_result then
                    modUI.Label("按下扳机, 如果设置成功, 它应该会震动")
                else
                    modUI.Label("无法与飞智空间站取得联系")
                end
            else
                local send_udp = modUI.Button("测试连接")
                if send_udp then
                    test_udp_result = test_udp()
                    modUI.Repaint()
                end
            end
            _, setting.debug_window = modUI.CheckBox("Open Debug Window", setting.debug_window)
            if d2d then
                _, setting.font_size = modUI.Slider("Font Size (Need Restart)", setting.font_size, 10, 24)
            end
        modUI.DecreaseIndent()
    end)
end

re.on_draw_ui(function() 
    if imgui.tree_node("Flydigi Apex3") then
        imgui.indent()
        _, setting.enable = imgui.checkbox("Enable Apex3 Adaptive Trigger", setting.enable)
        left_default_changed, setting.left_default_lock_pos = imgui.slider_int("Left Trigger Default Lock Position", setting.left_default_lock_pos, default_lock_pos_min, default_lock_pos_max)
        right_default_changed, setting.right_default_lock_pos = imgui.slider_int("Right Trigger Default Lock Position", setting.right_default_lock_pos, default_lock_pos_min, default_lock_pos_max)
        if left_default_changed or right_default_changed then
            controller_default_changed()
        end
        local port_changed, port = imgui.input_text("Flydigi Space Port", tostring(setting.udp_port))
        if port_changed then
            port = tonumber(port)
            if port ~= nil then 
                if port >= 1024 and port <= 65535 then
                    setting.udp_port = port 
                end
            end
        end
        local reset_default = imgui.button("Reset Default")
        if reset_default then setting.reset_default() end
        local reload_w = imgui.button("Reload Weapon Configs")
        if reload_w then reload_weapon_configs() end
        if version then
            imgui.text("Version: "..version)
        end
        imgui.text(about)
        if imgui.tree_node("Debug") then
            imgui.indent()
            if is_testing_udp() then
                if test_udp_result then
                    imgui.text("Push Trigger, It Should Vibrate")
                else
                    imgui.text("Connect Flydigi Space Failed")
                end
            else
                local send_udp = imgui.small_button("Test Connection")
                if send_udp then
                    test_udp_result = test_udp()
                end
            end
            _, setting.debug_window = imgui.checkbox("Open Debug Window", setting.debug_window)
            if d2d then
                _, setting.font_size = imgui.slider_int("Font Size (Need Restart)", setting.font_size, 10, 24)
            end
            imgui.unindent()
        end
        imgui.unindent()
        imgui.tree_pop();
    end
end)
