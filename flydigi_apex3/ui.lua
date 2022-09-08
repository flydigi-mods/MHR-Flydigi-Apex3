local setting = require("setting")
local version = require("version")
local Packet = require("udp_client")
local Instruction = Packet.Instruction

local default_lock_pos_min = 50
local default_lock_pos_max = 150

local begin_test_udp_time = 0
local test_udp_secs = 5
local test_udp_result = false

local packet

local about = "made by @songchenwen"
if version then about = about.." "..version end

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

re.on_draw_ui(function() 
    if imgui.tree_node("Flydigi Apex3") then
        imgui.indent()
        _, setting.enable = imgui.checkbox("Enable Apex3 Adaptive Trigger", setting.enable)
        _, setting.left_default_lock_pos = imgui.slider_int("Left Trigger Default Lock Position", setting.left_default_lock_pos, default_lock_pos_min, default_lock_pos_max)
        _, setting.right_default_lock_pos = imgui.slider_int("Right Trigger Default Lock Position", setting.right_default_lock_pos, default_lock_pos_min, default_lock_pos_max)
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
                _, setting.font_size = imgui.slider_int("Font Size (Need Restart)", setting.font_size, 12, 72)
            end
            imgui.unindent()
        end
        imgui.unindent()
        imgui.tree_pop();
    end
end)

if modUI then
    modUI.OnMenu("Flydigi Apex3", "Flydigi Apex3 Controller", function()
        if modUI.version < 1.6 then
			modUI.Label("Please update mod menu API.")
            return
        end
        modUI.Header("Flydigi Apex3 Controller")
        _, setting.enable = modUI.CheckBox("Enable Adaptive Trigger", setting.enable, "Enable Adaptive Trigger")
        _, setting.left_default_lock_pos = modUI.Slider("Left Trigger Default Lock Position", setting.left_default_lock_pos, default_lock_pos_min, default_lock_pos_max)
        _, setting.right_default_lock_pos = modUI.Slider("Right Trigger Default Lock Position", setting.right_default_lock_pos, default_lock_pos_min, default_lock_pos_max)
        _, setting.udp_port = modUI.Slider("Flydigi Space Port", setting.udp_port, 1024, 65535)
        local reset_default = modUI.Button("Reset Default")
        if reset_default then setting.reset_default() end
        modUI.Header(about)
        modUI.IncreaseIndent()
            if is_testing_udp() then
                modUI.IncreaseIndent()
                if test_udp_result then
                    modUI.Label("Push Trigger, It Should Vibrate")
                else
                    modUI.Label("Connect Flydigi Space Failed")
                end
                modUi.DecreaseIndent()
            else
                local send_udp = modUI.Button("Test Connection")
                if send_udp then
                    test_udp_result = test_udp()
                end
            end
            _, setting.debug_window = modUI.CheckBox("Open Debug Window", setting.debug_window)
            if d2d then
                _, setting.font_size = modUI.Slider("Font Size (Need Restart)", setting.font_size, 12, 72)
            end
        modUI.DecreaseIndent()
    end)
end
