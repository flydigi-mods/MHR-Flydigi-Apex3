local utils = require("flydigi_apex3.utils")
local setting = require('flydigi_apex3.setting')

local Client = {}

function Client:new(udp_path)
    local path = package.path
    local cpath = package.cpath 

    if utils.os == 'windows' then
        package.cpath = udp_path.."\\?.dll;"..package.cpath
        package.path = udp_path.."\\?.lua;"..package.path:gsub(".dll", '.lua')
    else
        package.cpath = udp_path.."/?.so;"..package.cpath
        package.path = udp_path.."/?.lua;"..package.path
    end

    local socket = require('socket.socket')

    package.path = path
    package.cpath = cpath

    local newObj = {
        address = "127.0.0.1",
        udp = socket.udp()
    }
    self.__index = self
    return setmetatable(newObj, self)
end

function Client:connected() 
    return self.port == setting.udp_port    
end

function Client:connect()
    if self:connected() then
        return true
    end
    local success, err = self.udp:setpeername(self.address, setting.udp_port)
    if success then
        self.port = setting.udp_port
    else
        log.debug("connect err "..err)
        utils.chat("UDP Connect Error "..err, 'always')
    end
    return success ~= nil
end

function Client:send(msg)
    return self.udp:send(msg)
end

return Client
