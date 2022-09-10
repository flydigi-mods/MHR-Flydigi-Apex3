local utils = {}

local setting = require('setting')

local PlayerManager
local InputManager
local ChatManager
local GamepadApp 

utils.os = 'unix'
if package.config:sub(1,1) == '\\' then
    utils.os = 'windows'
end

local rt_code = 2048
local lt_code = 512

function utils.is_rt_down()
    return is_trigger_down(rt_code)
end

function utils.is_lt_down()
    return is_trigger_down(lt_code)
end

function is_trigger_down(code)
    if not GamepadApp then
        local p = sdk.get_managed_singleton("snow.Pad")
        if p then
            GamepadApp = p:get_field("app")
        end
    end
    if not GamepadApp then
        log.debug("cannot get GamepadApp")
        return false
    end
    gamepad_on = GamepadApp:get_field("_on")
    return gamepad_on & code ~= 0
end

function utils.chat(text, always)
    if not setting.debug_window and not always then return end
    if not ChatManager then ChatManager = sdk.get_managed_singleton("snow.gui.ChatManager") end
    if ChatManager then
        ChatManager:call("reqAddChatInfomation", text, 0)
    end
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

return utils
