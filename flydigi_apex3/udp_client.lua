local os = 'unix'
if package.config:sub(1,1) == '\\' then
    os = 'windows'
end

local path = package.path
local cpath = package.cpath 


if os == 'windows' then
    local p = string.match(package.path, "(.-)([^\\/]-)?.lua;"):gsub("lua\\$", "").."reframework\\autorun\\flydigi_apex3\\"
    package.cpath = p.."?.dll;"..package.cpath
    package.path = p.."?.lua;"..package.path:gsub(".dll", '.lua')
else
    package.cpath = "./flydigi_apex3/?.so;"..package.cpath
    package.path = "./flydigi_apex3/?.lua;"..package.path
end

local socket = require('socket.socket')

package.path = path
package.cpath = cpath

local udp = socket.udp()

udp:setpeername('127.0.0.1', 7878) -- as client, can send
-- udp:setsockname('127.0.0.1', 7878) -- as server, can receive
udp:settimeout(10)

return udp
