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

return MemoryManager
