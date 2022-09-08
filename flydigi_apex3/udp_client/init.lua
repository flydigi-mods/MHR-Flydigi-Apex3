local Client = require("flydigi_apex3.udp_client.client")
local Packet = require("flydigi_apex3.udp_client.packet")
local Instruction = require("flydigi_apex3.udp_client.instruction")
Packet.Instruction = Instruction

Packet.load = function(path)
    Packet.client = Client:new(path)
end

return Packet
