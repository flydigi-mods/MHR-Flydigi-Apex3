local Client = require("udp_client.client")
local Packet = require("udp_client.packet")
local Instruction = require("udp_client.instruction")
Packet.Instruction = Instruction

Packet.load = function(path)
    Packet.client = Client:new(path)
end

return Packet
