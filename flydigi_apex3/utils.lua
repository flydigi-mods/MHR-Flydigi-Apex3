local utils = {}

local setting = require('flydigi_apex3/setting')

local PlayerManager
local InputManager
local ChatManager

function utils.chat(text)
    if not setting.debug_window then return end
    if not ChatManager then ChatManager = sdk.get_managed_singleton("snow.gui.ChatManager") end
    if ChatManager then
        ChatManager:call("reqAddChatInfomation", "Apex3: "..text, 0)
    end
end

function utils.get_default_controller_config()
    return {
        LeftTrigger = setting.left_default,
        RightTrigger = setting.right_default,
        UDPSplit = true,
        UDPLogs = true
    }
end

function utils.deepcompare(t1,t2,ignore_mt)
    local ty1 = type(t1)
    local ty2 = type(t2)
    if ty1 ~= ty2 then return false end
    -- non-table types can be directly compared
    if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
    -- as well as tables which have the metamethod __eq
    local mt = getmetatable(t1)
    if not ignore_mt and mt and mt.__eq then return t1 == t2 end
    for k1,v1 in pairs(t1) do
    local v2 = t2[k1]
    if v2 == nil or not utils.deepcompare(v1,v2) then return false end
    end
    for k2,v2 in pairs(t2) do
    local v1 = t1[k2]
    if v1 == nil or not utils.deepcompare(v1,v2) then return false end
    end
    return true
end

function utils.get_manager(args) 
    return sdk.to_managed_object(args[2]) 
end

function utils.save_controller_config(config)
    content = ""
    for k, v in pairs(config) do
        if type(v) == "string" then
            content = content..k..'='..v..'\n'
        else
            content = content..k..'='..tostring(v)..'\n'
        end
    end
    fs.write('flydigi_apex3/DualSenseXConfig.txt', content)
end

function utils.empty_controller_config()
    fs.write('flydigi_apex3/DualSenseXConfig.txt', "")
end

return utils
