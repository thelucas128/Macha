local HttpService = game:GetService("HttpService")


local jsonString = game:HttpGet("https://imtheo.lol/Offsets/Offsets.json")
local offsetsData = HttpService:JSONDecode(jsonString)
local offsets = offsetsData.Offsets

local MemoryManager = {}

function MemoryManager.typeof(v)
    if type(v) == "table" or type(v) == "userdata" then
        if v.ClassName then
            return "Instance"
        end
    end
    return type(v)
end

function MemoryManager.GetServerIp()
    return memory_read("string", memory_read("uintptr_t", game.Address + offsets.DataModel.ServerIP) + 0x0)
end

function MemoryManager.GetFrameVisible(Address)
    if MemoryManager.typeof(Address) == "Instance" then
        Address = Address.Address
    end
    return memory_read("byte", Address + offsets.GuiObject.Visible) == 1
end

function MemoryManager.IsScreenGuiEnabled(Address)
    if MemoryManager.typeof(Address) == "Instance" then
        Address = Address.Address
    end
    return memory_read("byte", Address + offsets.GuiObject.ScreenGui_Enabled) == 1
end

function MemoryManager.GetGuiObjectRotation(Address)
    if MemoryManager.typeof(Address) == "Instance" then
        Address = Address.Address
    end
    return memory_read("float", Address + offsets.GuiObject.Rotation)
end

function MemoryManager.GetImageId(Address)
    if MemoryManager.typeof(Address) == "Instance" then
        Address = Address.Address
    end
    return memory_read("string", memory_read("uintptr_t", Address + offsets.GuiObject.Image) + 0x0)
end

function MemoryManager.GetRotationMatrix(part)
    if not part then
        return nil
    end
    
    local address = part.Address or part
    if not address then
        return nil
    end
    
    local primitive = memory_read("uintptr_t", address + offsets.BasePart.Primitive)
    if not primitive then
        return nil
    end
    
    
    local m = {}
    for i = 0, 8 do
        m[i] = memory_read("float", primitive + offsets.BasePart.Rotation  + (i * 0x04))
    end
    
    return m
end

function MemoryManager.GetLookVector(part)
    local m = MemoryManager.GetRotationMatrix(part)
    if not m then
        return nil
    end
    return Vector3.new(-m[2], -m[5], -m[8])
end

-- Get RightVector (X axis)
function MemoryManager.GetRightVector(part)
    local m = MemoryManager.GetRotationMatrix(part)
    if not m then
        return nil
    end
    return Vector3.new(m[0], m[3], m[6])
end

-- Get UpVector (Y axis)
function MemoryManager.GetUpVector(part)
    local m = MemoryManager.GetRotationMatrix(part)
    if not m then
        return nil
    end
    return Vector3.new(m[1], m[4], m[7])
end

function MemoryManager.GetEulerAngles(part)
    local m = MemoryManager.GetRotationMatrix(part)
    if not m then
        return nil
    end
    
    local m21 = -m[5]
    local pitch, yaw, roll
    
    if m21 < 0.99999 then
        if m21 > -0.99999 then
            pitch = math.asin(m21)
            yaw = math.atan2(-m[2], -m[8])
            roll = math.atan2(-m[3], -m[4])
        else
            pitch = math.pi / 2
            yaw = -math.atan2(m[6], m[0])
            roll = 0
        end
    else
        pitch = -math.pi / 2
        yaw = math.atan2(m[6], m[0])
        roll = 0
    end
    
    return {
        Yaw = yaw,
        Pitch = pitch,
        Roll = roll
    }
end

return MemoryManager
