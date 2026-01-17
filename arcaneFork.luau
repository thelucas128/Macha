--Credits to : https://www.arcanecheats.xyz/docs/matcha/esplib
local camera = workspace.CurrentCamera
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer

local ArcaneEsp = {}
ArcaneEsp.__index = ArcaneEsp

local drawings = {}

local function clamp(x, a, b)
    if x > b then return b elseif x < a then return a else return x end
end

local function Insert(t, v)
    table.insert(t, v)
end

local function Draw(t, props)
    local o = Drawing.new(t)
    for k, v in pairs(props) do
        o[k] = v
    end
    Insert(drawings, o)
    return o
end

local function magnitude(point1, point2)
    local dx = point2.X - point1.X
    local dy = point2.Y - point1.Y
    local dz = point2.Z - point1.Z
    return math.sqrt(dx*dx + dy*dy + dz*dz)
end

local function getModelData(model)
    local minX, minY, minZ = math.huge, math.huge, math.huge
    local maxX, maxY, maxZ = -math.huge, -math.huge, -math.huge
    local found = false

    local descendants = model:GetDescendants()
    table.insert(descendants, model)

    for _, part in pairs(descendants) do
        if part:IsA("BasePart") then
            local pos = part.Position
            local size = part.Size
            if pos and size then
                found = true
                local hX, hY, hZ = size.X / 2, size.Y / 2, size.Z / 2
                minX, minY, minZ = math.min(minX, pos.X - hX), math.min(minY, pos.Y - hY), math.min(minZ, pos.Z - hZ)
                maxX, maxY, maxZ = math.max(maxX, pos.X + hX), math.max(maxY, pos.Y + hY), math.max(maxZ, pos.Z + hZ)
            end
        end
    end

    if not found then return nil, nil end
    
    local size = Vector3.new(maxX - minX, maxY - minY, maxZ - minZ)
    local center = Vector3.new((minX + maxX) / 2, (minY + maxY) / 2, (minZ + maxZ) / 2)
    return center, size
end

function ArcaneEsp.new(targetInstance)
    if not targetInstance then return nil end
    local self = setmetatable({}, ArcaneEsp)
    self.Instance = targetInstance
    self.Enabled = true
    self.Components = {Box = nil, Title = nil, Distance = nil, Glow = nil}
    self.TextFont = 0
    self.GlowLayers = {}
    self:Start()
    return self
end

function ArcaneEsp:SetFont(font)
    self.TextFont = font
    if self.Components.Title then self.Components.Title.Font = font end
    if self.Components.Distance then self.Components.Distance.Font = font end
    return self
end

function ArcaneEsp:AddEsp(color)
    self.Components.Box = Draw("Square", {
        Visible = false,
        Color = color or Color3.fromRGB(0, 255, 0),
        Thickness = 2,
        Filled = false,
        Corner = 5,
        ZIndex = 2
    })
    return self
end

function ArcaneEsp:AddTitle(color, text)
    self.Components.Title = Draw("Text", {
        Visible = false,
        Color = color or Color3.fromRGB(255, 255, 255),
        Center = true,
        Outline = true,
        Font = self.TextFont,
        Text = text or self.Instance.Name,
        ZIndex = 10
    })
    return self
end

function ArcaneEsp:AddDistance(color)
    self.Components.Distance = Draw("Text", {
        Visible = false,
        Color = color or Color3.fromRGB(255, 255, 255),
        Center = true,
        Outline = true,
        Font = self.TextFont,
        ZIndex = 10
    })
    return self
end

function ArcaneEsp:AddGlow(color, spread)
    self.Components.Glow = {
        Color = color or Color3.fromRGB(0, 255, 0),
        Spread = spread or 8
    }
    return self
end

function ArcaneEsp:Start()
    spawn(function()
        while self.Instance and self.Instance.Parent do
            if not self.Enabled then
                self:SetVisibility(false)
                wait()
                continue
            end

            local targetPos, targetSize
            
            if self.Instance:IsA("Model") then
                targetPos, targetSize = getModelData(self.Instance)
            elseif self.Instance:IsA("BasePart") then
                targetPos = self.Instance.Position
                targetSize = self.Instance.Size
            end

            if not targetPos or not targetSize then 
                self:SetVisibility(false)
                wait()
                continue 
            end

            local screenPos, onScreen = WorldToScreen(targetPos)
            local char = localPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")

            if onScreen and root then
                local distFromRoot = magnitude(root.Position, targetPos)
                local distFromCam = magnitude(camera.Position, targetPos)
                local multiplier = 1000 
                
                local size = Vector2.new((targetSize.X * multiplier) / distFromCam, (targetSize.Y * multiplier) / distFromCam)
                local position = screenPos - (size / 2)
                local textSize = clamp(500 / distFromCam, 10, 22)

                if self.Components.Box then
                    self.Components.Box.Position = position
                    self.Components.Box.Size = size
                    self.Components.Box.Visible = true
                end

                if self.Components.Title then
                    self.Components.Title.Size = math.floor(textSize)
                    self.Components.Title.Position = Vector2.new(screenPos.X, position.Y - (textSize + 5))
                    self.Components.Title.Visible = true
                end

                if self.Components.Distance then
                    self.Components.Distance.Text = math.floor(distFromRoot) .. " studs"
                    self.Components.Distance.Size = math.floor(textSize * 0.8)
                    self.Components.Distance.Position = Vector2.new(screenPos.X, position.Y + size.Y + 5)
                    self.Components.Distance.Visible = true
                end

                if self.Components.Glow then
                    local color = self.Components.Glow.Color
                    local spread = self.Components.Glow.Spread
                    if #self.GlowLayers == 0 then
                        for i = 1, spread do
                            local glow = Draw("Square", {
                                Visible = true,
                                Filled = false,
                                Thickness = 2,
                                Transparency = 0.3 * (1 - (i / spread)),
                                Color = color,
                                Corner = 5 + i,
                                ZIndex = 1
                            })
                            table.insert(self.GlowLayers, glow)
                        end
                    end
                    for i, glow in pairs(self.GlowLayers) do
                        glow.Visible = true
                        glow.Size = size + Vector2.new(i * 6, i * 6)
                        glow.Position = position - Vector2.new(i * 3, i * 3)
                        glow.Color = color
                    end
                end
            else
                self:SetVisibility(false)
            end
            wait()
        end
        self:Destroy()
    end)
end

function ArcaneEsp:SetVisibility(state)
    if self.Components.Box then self.Components.Box.Visible = state end
    if self.Components.Title then self.Components.Title.Visible = state end
    if self.Components.Distance then self.Components.Distance.Visible = state end
    for _, glow in pairs(self.GlowLayers) do glow.Visible = state end
end

function ArcaneEsp:Destroy()
    self.Enabled = false
    if self.Components.Box then self.Components.Box:Remove() end
    if self.Components.Title then self.Components.Title:Remove() end
    if self.Components.Distance then self.Components.Distance:Remove() end
    for _, glow in pairs(self.GlowLayers) do glow:Remove() end
end

return ArcaneEsp
