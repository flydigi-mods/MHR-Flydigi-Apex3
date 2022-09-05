local file_path = "flydigi_apex3/setting.json"
local setting = json.load_file(file_path)
if not setting then
    setting = {enable = true, debug_window = false, left_default='LockHalf', right_default='LockHalf'}
else
    if setting.left_default = "Gap1" then setting.left_default = 'LockHalf' end
    if setting.right_default = "Gap1" then setting.right_default = 'LockHalf' end
end

re.on_config_save(function()
    json.dump_file(file_path, setting, 4)
end)

re.on_draw_ui(function() 
    if imgui.tree_node("Flydigi Apex3") then
        _, setting.enable = imgui.checkbox("Enable Apex3 Adaptive Trigger", setting.enable)
        local debug_window = imgui.small_button("Debug Window")
        if debug_window then
            setting.debug_window = true
        end
        imgui.tree_pop();
    end
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

if modUI then
    local name = "Flydigi Apex3"
    local description = ""
    modUI.OnMenu(name, description, function()
        if modUI.version < 1.6 then
			modUI.Label("Please update mod menu API.")
            return
        end
        _, setting.enable = modUI.CheckBox("Enable", setting.enable, "Enable Flydigi Apex3 Adaptive Trigger")
    end)
end

return setting
