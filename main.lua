-- Steal a Brainrot Delta Hub v1.1 (2025) - Anti-Cheat Bypass
-- Bibliothèque Rayfield pour GUI incroyable
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Load config
local HttpService = game:GetService("HttpService")
local config = HttpService:JSONDecode(readfile("config.json")) or {theme="Dark"}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Anti-Cheat Bypass: Random delays et hooks
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if method == "FireServer" and string.find(tostring(self), "AntiCheat") then
        return -- Bloque les checks anti-cheat
    end
    return oldNamecall(self, ...)
end)

-- Variables globales
local flying = false
local espEnabled = false
local duplicating = false
local autoStealEnabled = config.toggles.autoSteal
local noclipEnabled = config.t subtracting = config.toggles.noclip
local fullbrightEnabled = config.toggles.fullbright
local autofarmEnabled = config.toggles.autofarm
local antibanEnabled = config.toggles.antiban
local visualEffectsEnabled = config.toggles.visualeffects
local jumpPower = config.sliders.jumpPower or 100
local speed = config.sliders.speed or 50
local teleportRange = config.sliders.teleportRange or 500
local farmDelay = config.sliders.farmDelay or 2

-- Fly Module
local function toggleFly()
    flying = not flying
    if flying then
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = rootPart
        
        local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
        bodyAngularVelocity.MaxTorque = Vector3.new(4000, 4000, 4000)
        bodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
        bodyAngularVelocity.Parent = rootPart
        
        spawn(function()
            while flying do
                local cam = workspace.CurrentCamera
                local vel = bodyVelocity
                vel.Velocity = cam.CFrame.LookVector * (UserInputService:IsKeyDown(Enum.KeyCode.W) and speed or 0) +
                               cam.CFrame.RightVector * (UserInputService:IsKeyDown(Enum.KeyCode.D) and speed or 0) +
                               cam.CFrame.RightVector * (UserInputService:IsKeyDown(Enum.KeyCode.A) and -speed or 0) +
                               Vector3.new(0, UserInputService:IsKeyDown(Enum.KeyCode.Space) and speed or (UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and -speed or 0), 0)
                wait(0.1 + math.random(0.01, 0.05))
            end
            bodyVelocity:Destroy()
            bodyAngularVelocity:Destroy()
        end)
    end
end

humanoid.Touched:Connect(function(hit)
    if string.find(hit.Name:lower(), "brainrot") and not flying then
        toggleFly()
        wait(2)
        flying = false
    end
end)

-- Saut haut
humanoid.JumpPower = jumpPower
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        humanoid.JumpPower = jumpPower * 2
        wait(0.5)
        humanoid.JumpPower = jumpPower
    end
end)

-- ESP Module
local function createESP(part, text, color)
    local billboard = Instance.new("BillboardGui")
    billboard.Parent = part
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    
    local label = Instance.new("TextLabel")
    label.Parent = billboard
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 14
    
    local box = Instance.new("BoxHandleAdornment")
    box.Parent = part
    box.Size = part.Size
    box.Color3 = color
    box.Transparency = 0.5
    box.AlwaysOnTop = true
end

local function toggleESP()
    espEnabled = not espEnabled
    if espEnabled then
        for _, obj in pairs(workspace:GetChildren()) do
            if string.find(obj.Name:lower(), "brainrot") or obj:FindFirstChild("Humanoid") then
                local dist = (obj.Position - rootPart.Position).Magnitude
                createESP(obj, obj.Name .. "\nDist: " .. math.floor(dist), Color3.new(1, 0, 0))
            end
        end
    else
        for _, obj in pairs(workspace:GetChildren()) do
            if obj:FindFirstChild("BillboardGui") then obj.BillboardGui:Destroy() end
            if obj:FindFirstChild("BoxHandleAdornment") then obj.BoxHandleAdornment:Destroy() end
        end
    end
end

-- Duplication
local function duplicateBrainrot()
    duplicating = true
    local brainrots = {}
    for _, obj in pairs(workspace:GetChildren()) do
        if string.find(obj.Name:lower(), "brainrot") then
            table.insert(brainrots, obj)
        end
    end
    for _, br in pairs(brainrots) do
        local clone = br:Clone()
        clone.Parent = workspace
        clone.Position = br.Position + Vector3.new(math.random(-5,5), 0, math.random(-5,5))
        ReplicatedStorage.Events.Collect:FireServer(clone)
        wait(math.random(0.1, 0.3))
    end
    duplicating = false
end

-- Auto Steal
spawn(function()
    while autoStealEnabled do
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                rootPart.CFrame = p.Character.HumanoidRootPart.CFrame
                for _, obj in pairs(workspace:GetChildren()) do
                    if obj.Parent == p.Character and string.find(obj.Name:lower(), "brainrot") then
                        ReplicatedStorage.Events.Steal:FireServer(obj)
                    end
                end
            end
        end
        wait(5 + math.random(1,3))
    end
end)

-- Noclip
local function toggleNoclip()
    noclipEnabled = not noclipEnabled
    spawn(function()
        while noclipEnabled do
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
            wait()
        end
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end)
end

-- Fullbright
if fullbrightEnabled then
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
end

-- Speed
humanoid.WalkSpeed = speed

-- Load Modules
local modules = {
    "autofarm.lua",
    "teleport.lua",
    "antiban.lua",
    "visualeffects.lua",
    "fly.lua",
    "esp.lua",
    "dupe.lua"
}
for _, module in pairs(modules) do
    if isfile("modules/" .. module) then
        loadfile("modules/" .. module)()
    end
end

-- GUI Rayfield
local Window = Rayfield:CreateWindow({
    Name = "Steal a Brainrot Hub 🔥",
    LoadingTitle = "Chargement Brainrot...",
    LoadingSubtitle = "par xAI Grok",
    ConfigurationSaving = {Enabled = true, FolderName = "BrainrotConfig", FileName = "config"},
    Discord = {Enabled = false},
    KeySystem = false
})

local MainTab = Window:CreateTab("Main", 4483362458)
local CombatTab = Window:CreateTab("Combat", 4483362458)
local FarmTab = Window:CreateTab("Farm", 4483362458)
local VisualTab = Window:CreateTab("Visual", 4483362458)

-- Main Section
local MainSection = MainTab:CreateSection("Features Principales")
MainTab:CreateToggle({
    Name = "Auto Steal",
    CurrentValue = autoStealEnabled,
    Flag = "AutoSteal",
    Callback = function(Value)
        autoStealEnabled = Value
    end
})
MainTab:CreateToggle({
    Name = "Fly (Auto sur Brainrot)",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(Value)
        if Value then toggleFly() end
    end
})
MainTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 200},
    Increment = 10,
    CurrentValue = jumpPower,
    Flag = "JumpPower",
    Callback = function(Value)
        jumpPower = Value
        humanoid.JumpPower = Value
    end
})
MainTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 100},
    Increment = 5,
    CurrentValue = speed,
    Flag = "Speed",
    Callback = function(Value)
        speed = Value
        humanoid.WalkSpeed = Value
    end
})

-- Combat Section
local CombatSection = CombatTab:CreateSection("ESP & Dupe")
CombatTab:CreateToggle({
    Name = "ESP (Brainrots/Joueurs)",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
        toggleESP()
    end
})
CombatTab:CreateButton({
    Name = "Dupliquer Brainrots",
    Callback = function()
        duplicateBrainrot()
    end
})
CombatTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(Value)
        toggleNoclip()
    end
})

-- Farm Section
local FarmSection = FarmTab:CreateSection("Farming & Teleport")
FarmTab:CreateToggle({
    Name = "Auto Farm (Cash/Brainrots)",
    CurrentValue = autofarmEnabled,
    Flag = "AutoFarm",
    Callback = function(Value)
        autofarmEnabled = Value
        if getgenv().AutoFarmModule then AutoFarmModule(Value) end
    end
})
FarmTab:CreateSlider({
    Name = "Farm Delay (s)",
    Range = {1, 10},
    Increment = 1,
    CurrentValue = farmDelay,
    Flag = "FarmDelay",
    Callback = function(Value)
        farmDelay = Value
    end
})
FarmTab:CreateButton({
    Name = "Teleport to Nearest Brainrot",
    Callback = function()
        if getgenv().TeleportModule then TeleportModule("brainrot") end
    end
})
FarmTab:CreateButton({
    Name = "Teleport to Enemy Base",
    Callback = function()
        if getgenv().TeleportModule then TeleportModule("base") end
    end
})

-- Visual Section
local VisualSection = VisualTab:CreateSection("Visual Effects")
VisualTab:CreateToggle({
    Name = "Brainrot Particles & Glow",
    CurrentValue = visualEffectsEnabled,
    Flag = "VisualEffects",
    Callback = function(Value)
        visualEffectsEnabled = Value
        if getgenv().VisualEffectsModule then VisualEffectsModule(Value) end
    end
})
VisualTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = fullbrightEnabled,
    Flag = "Fullbright",
    Callback = function(Value)
        fullbrightEnabled = Value
        if Value then
            Lighting.Brightness = 2
        else
            Lighting.Brightness = 1
        end
    end
})
VisualTab:CreateToggle({
    Name = "Anti-Ban (Proactif)",
    CurrentValue = antibanEnabled,
    Flag = "AntiBan",
    Callback = function(Value)
        antibanEnabled = Value
        if getgenv().AntiBanModule then AntiBanModule(Value) end
    end
})

-- Notification
Rayfield:Notify({
    Title = "Hub Chargé !",
    Content = "Steal a Brainrot Hub v1.1 avec AutoFarm, Teleport, AntiBan, Visuals !",
    Duration = 3,
    Image = 4483362458
})

print("Steal a Brainrot Hub v1.1 chargé avec succès - Anti-Cheat Bypass actif.")
