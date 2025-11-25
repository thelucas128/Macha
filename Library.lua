local jsonString = game:HttpGet("https://imtheo.lol/Offsets/Offsets.json")
local offsets = json.decode(jsonString)

offsets = offsets.Offsets

MemoryManager = {
    typeof = function(v)
        if type(v) == "table" or type(v) == "userdata" then
            if v.ClassName then
                return "Instance"
            end
        end
        return type(v)
    end,


    GetServerIp = function()
	    return memory_read("string", memory_read("uintptr_t",game.Address + offsets.DataModel.ServerIP) + 0x0)
    end,

    GetFrameVisible = function(Address :  number?)
        if MemoryManager.typeof(Address) == "Instance" then
            Address = Address.Address
        end
        return memory_read("byte", Address +  decimalToHex(offsets.GuiObject.Visible)) == 1
    end,

    IsScreenGuiEnabled = function(Address : number?)
        if MemoryManager.typeof(Address) == "Instance" then
            Address = Address.Address
        end
        return memory_read("byte", Address +  decimalToHex(offsets.GuiObject.ScreenGui_Enabled)) == 1
    end,

    GetGuiObjectRotation = function(Address : number?)
        if MemoryManager.typeof(Address) == "Instance" then
            Address = Address.Address
        end
        return memory_read("float", Address +  decimalToHex(offsets.GuiObject.Rotation))
    end,


    GetImageId = function(Address : number?)
        if MemoryManager.typeof(Address) == "Instance" then
            Address = Address.Address
        end
        return  memory_read("string",memory_read("uintptr_t",Address + offsets.GuiObject.Image) + 0x0)
    end,

}
