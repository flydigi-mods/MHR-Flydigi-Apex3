local utils = {}

local setting = require('setting')

local PlayerManager
local InputManager
local ChatManager

utils.os = 'unix'
if package.config:sub(1,1) == '\\' then
    utils.os = 'windows'
end

function utils.chat(text, always)
    if not setting.debug_window and not always then return end
    if not ChatManager then ChatManager = sdk.get_managed_singleton("snow.gui.ChatManager") end
    if ChatManager then
        ChatManager:call("reqAddChatInfomation", "Apex3: "..text, 0)
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
