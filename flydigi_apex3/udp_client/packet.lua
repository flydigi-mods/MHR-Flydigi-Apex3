local Instruction = require("udp_client.instruction")

local Packet = {}

function Packet:new(left, right)
    local newObj = {
        left = left,
        right = right 
    }
    if not left then newObj.left = Instruction:new() end
    if not right then newObj.right = Instruction:new() end
    newObj.left:Left()
    newObj.right:Right()
    self.__index = self
    return setmetatable(newObj, self)
end

function Packet:clone()
    return Packet:new(self.left:clone(), self.right:clone())
end

function Packet:Left(left)
    if not left then return self.left end
    left:Left()
    self.left = left
    return self
end

function Packet:Right(right)
    if not right then return self.right end
    right:Right()
    self.right = right
    return self
end

function Packet:to_json()
    local data = {
        instructions = {self.left:Left():packet(), self.right:Right():packet()}
    }
    return json.dump_string(data)
end

function Packet:equal(other)
    if not self.left:equal(other.left) then return false end
    if not self.right:equal(other.right) then return false end
    return true
end

function Packet:is_nil()
    return self.left:is_nil() and self.right:is_nil()
end

function Packet:delta(new_packet)
    local d = new_packet:clone()
    if self.left:equal(new_packet.left) then d:Left(Instruction:new()) end
    if self.right:equal(new_packet.right) then d:Right(Instruction:new()) end
    return d
end

function Packet:send()
    if self:is_nil() then
        return false
    end
    if Packet.client == nil then
        log.error("Packet.client not initialized you should call Packet.load first")
        error("Packet.client not initialized you should call Packet.load first")
        return false
    end
    if Packet.client:connect() then
        local sent, err = Packet.client:send(self:to_json())
        if err then 
            log.debug(err)
        end
        return not err
    end
    log.debug("not connected")
    return false
end



function Packet.get_default()
    return Packet:new(
        Instruction.left_default(),
        Instruction.right_default()
    )
end

return Packet
