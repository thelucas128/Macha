local function json_decode(s)
	local p = 1
	local function sk() while p <= #s and s:sub(p,p):match("%s") do p=p+1 end end
	local function dec()
		sk() local c = s:sub(p,p)
		if c == '"' then
			p=p+1 local r = ""
			while p <= #s do
				c = s:sub(p,p)
				if c == '"' then p=p+1 return r
				elseif c == "\\" then p=p+1 r=r..(({b="\b",f="\f",n="\n",r="\r",t="\t"})[s:sub(p,p)] or s:sub(p,p))
				else r=r..c end
				p=p+1
			end
		elseif c == "{" then
			p=p+1 local o = {} sk()
			if s:sub(p,p) == "}" then p=p+1 return o end
			while true do
				sk() local k = dec() sk() p=p+1 o[k] = dec() sk() c = s:sub(p,p)
				if c == "}" then p=p+1 return o end p=p+1
			end
		elseif c == "[" then
			p=p+1 local a = {} sk()
			if s:sub(p,p) == "]" then p=p+1 return a end
			while true do
				a[#a+1] = dec() sk() c = s:sub(p,p)
				if c == "]" then p=p+1 return a end p=p+1
			end
		elseif c == "t" then p=p+4 return true
		elseif c == "f" then p=p+5 return false
		elseif c == "n" then p=p+4 return nil
		else local n = s:match("^-?%d+%.?%d*[eE]?[+-]?%d*", p) p=p+#n return tonumber(n) end
	end
	return dec()
end

local jsonString = game:HttpGet("https://imtheo.lol/Offsets/Offsets.json")
local offsets = json_decode(jsonString)

offsets = offsets.Offsets

local MemoryManager = {}

local function typeof(v)

	if type(v) == "table" or type(v) == "userdata" then
		if v.ClassName then
			return "Instance"
		elseif v.Address then
			return "Instance"
		end
	end
	return type(v)
end


function decimalToHex(decimal)
	return "0x" .. string.format("%X", decimal)
end


function MemoryManager:GetFrameVisible(Address)
	if typeof(Address) == "Instance" then
		Address = Address.Address
	end
	return memory_read("byte", Address +  decimalToHex(offsets.GuiObject.Visible)) == 1
end

function MemoryManager:IsScreenGuiEnabled(Address)
	if typeof(Address) == "Instance" then
		Address = Address.Address
	end
	return memory_read("byte", Address +  decimalToHex(offsets.GuiObject.ScreenGui_Enabled)) == 1
end

function MemoryManager:GetGuiObjectRotation(Address)
	if typeof(Address) == "Instance" then
		Address = Address.Address
	end
	return memory_read("float", Address +  decimalToHex(offsets.GuiObject.Rotation))
end

function MemoryManager:GetImageId(Address)
	if typeof(Address) == "Instance" then
		Address = Address.Address
	end
	return  memory_read("string",memory_read("uintptr_t",Address + offsets.GuiObject.Image) + 0x0)
end

function MemoryManager:GetServerIp()
	return memory_read("string", memory_read("uintptr_t",game.Address + offsets.DataModel.ServerIP) + 0x0)
end

