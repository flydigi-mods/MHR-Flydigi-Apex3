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

function utils.end_with(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end

function utils.start_with(str, prefix)
    return prefix == "" or str:sub(0, #prefix) == prefix
end

function utils.trim_prefix(str, prefix)
    if utils.start_with(str, prefix) then
        return str:sub(#prefix + 1)
    end
    return str
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

function utils.all_fields_for_type(t)
    local fields = t:get_fields()
    local pt = t:get_parent_type()
    if pt ~= nil then
        local pfs = utils.all_fields_for_type(pt)
        for _, f in ipairs(pfs) do
            table.insert(fields, f)
        end
    end
    return fields
end

function utils.dump_obj(obj, filepath)
    if not sdk.is_managed_object(obj) then
        return
    end
    local d = {}
    local t = obj:get_type_definition()
    local fields = utils.all_fields_for_type(t)
    for _, f in ipairs(fields) do
        local name = f:get_name()
        local is_static = f:is_static()
        d[name] = {
            is_static = is_static,
            type = f:get_type():get_full_name()
        }
        local value
        if is_static then
            value = f:get_data(nil)
        else
            value = f:get_data(obj)
        end
        if value ~= nil and type(value) == "userdata" then
            if not sdk.is_managed_object(value) then
                value = sdk.to_managed_object(value)
            end
            if value ~= nil then
                value = utils.dump_obj(value)
            end
        end
        d[name]['value'] = value
    end
    if filepath == nil then
        log.debug(json.dump_string(d, 2))
    else
        json.dump_file(filepath, d, 4)
    end
    return d
end

function utils.get_manager(args) 
    return sdk.to_managed_object(args[2]) 
end

return utils
