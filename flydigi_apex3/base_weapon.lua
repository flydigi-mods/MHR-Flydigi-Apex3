local BaseWeapon = {}
local utils = require('utils')
local setting = require('setting')
local c = require('cache')
local BaseState = require("base_state")
local weapon_status = require("weapon_status")
local Config = require("config")
local Packet = require("udp_client")
local Instruction = Packet.Instruction


local function generate_status_func(t, name)
    local field = t:get_field(name)
    if type(field) == 'userdata' then
        return function(player) return field:get_data(player) end
    end
    local method = t:get_method(name)
    if type(method) == 'userdata' then
        return function(player) return method:call(player) end
    end
    return nil
end

function BaseWeapon:get_status(player)
    local s = {}
    local t = player:get_type_definition()
    for k, v in pairs(self.status_dict) do
        if type(v) == "string" then
            self.status_dict[k] = generate_status_func(t, v)
        end
    end
    for k, v in pairs(self.status_dict) do
        if v ~= nil then
            s[k] = v(player)
        end
    end
    return s
end

function BaseWeapon:update_controller_config(action_id, action_bank_id, player)
    local new_state = self.state_type:new(action_id, action_bank_id, self.status)
    if self.current_state == nil or self.current_state:is_nil() then
        self.current_state = new_state
        return false
    end
    local changed = self.current_state:changed(new_state)
    if not changed then return false end
    local packet = nil
    for _, c in ipairs(self.configs) do 
        if type(c.func) == "function" then
            local ok, n = pcall(c.func, self.current_state, new_state, changed)
            if ok then
                if n ~= nil then 
                    utils.chat(tostring(new_state.action_id).." from "..c.name)
                    packet = n
                    break
                end
            else
                log.debug("run error "..c.name.." "..n)
            end
        elseif type(c) == 'table' then
            local n = c:get_packet(self.current_state, new_state, changed)
            if n ~= nil then 
                packet = n
                break
            end
        end
    end
    if not packet then
        packet = Packet.get_default()
    end
    self.current_state = new_state
    return packet
end

local function load_configs(name)
    local path_prefix = "flydigi_apex3/weapons/"
    local configs = {}
    for _, p in ipairs({name..".lua", name..".json", name..".default.lua", name..".default.json"}) do
        local path = path_prefix..p
        if utils.end_with(p, '.lua') then
            local f = io.open(path, 'r')
            if f ~= nil then
                local s = f:read("*a")
                f:close()
                local func, err = load(s, p, 'bt', {Packet = Packet, Instruction = Instruction, utils=utils, log=log})
                if func then
                    local ok, func = pcall(func)
                    if ok then
                        table.insert(configs, {name=p, func=func})
                    end
                end
            end
        end
        if utils.end_with(p, '.json') then
            local c = Config.load_file(path, p)
            if c ~= nil then
                table.insert(configs, c)
            end
        end
    end
    log.debug("loaded "..tostring(#configs).." configs for "..name)
    return configs
end

function BaseWeapon:new(weapon_name, status_dict, state_type)
    if state_type == nil then state_type = BaseState end
    local newObj = {
        name = weapon_name, on_update = nil, 
        status = {}, status_dict = status_dict,
        state_type = state_type
    }
    newObj['current_state'] = state_type:new()          
    newObj.configs = load_configs(weapon_name)  
    self.__index = self
    return setmetatable(newObj, self)
end

function BaseWeapon:reload_configs()
    self.configs = load_configs(self.name)
end

local function status_update_static_func(weapon)
    return function(args)
        if not setting.enable then return end
        BaseWeapon.status_update(weapon, args)
    end
end

function BaseWeapon:status_update(player)
    status = self:get_status(player)
    local changed = false
    for k, v in pairs(status) do 
        if self.status[k] ~= v then
            changed = true
            self.status[k] = v
        end
    end
    if changed then
        self.on_update()
    end
end

BaseWeapon.weapons = {}

function BaseWeapon.get_weapon(name)
    local w = BaseWeapon.weapons[name]
    if w == nil then
        w = BaseWeapon:new(name, weapon_status[name])
        BaseWeapon.weapons[name] = w
    end
    return w
end

return BaseWeapon
