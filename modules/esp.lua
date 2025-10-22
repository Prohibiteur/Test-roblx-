-- Module ESP - Affichage brainrots/joueurs/bases
getgenv().ESPModule = function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    local espEnabled = false

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
                if string.find(obj.Name:lower(), "brainrot") or obj:FindFirstChild("Humanoid") or string.find(obj.Name:lower(), "base") then
                    local dist = (obj.Position - rootPart.Position).Magnitude
                    createESP(obj, obj.Name .. "\nDist: " .. math.floor(dist), Color3.new(1, 0, 0))
                end
            end
            -- Mise à jour dynamique
            RunService.Heartbeat:Connect(function()
                if not espEnabled then return end
                for _, obj in pairs(workspace:GetChildren()) do
                    if (string.find(obj.Name:lower(), "brainrot") or obj:FindFirstChild("Humanoid") or string.find(obj.Name:lower(), "base")) and not obj:FindFirstChild("BillboardGui") then
                        local dist = (obj.Position - rootPart.Position).Magnitude
                        createESP(obj, obj.Name .. "\nDist: " .. math.floor(dist), Color3.new(1, 0, 0))
                    end
                end
            end)
        else
            for _, obj in pairs(workspace:GetChildren()) do
                if obj:FindFirstChild("BillboardGui") then obj.BillboardGui:Destroy() end
                if obj:FindFirstChild("BoxHandleAdornment") then obj.BoxHandleAdornment:Destroy() end
            end
        end
    end

    return toggleESP -- Retourne pour toggle via GUI
end
