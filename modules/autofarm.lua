-- Module AutoFarm - Farming cash et brainrots
getgenv().AutoFarmModule = function(enabled)
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local player = Players.LocalPlayer
    local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local farmDelay = HttpService:JSONDecode(readfile("config.json")).sliders.farmDelay or 2

    spawn(function()
        while enabled do
            if not rootPart then
                player.CharacterAdded:Wait()
                rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            end
            -- Collect brainrots
            for _, obj in pairs(workspace:GetChildren()) do
                if string.find(obj.Name:lower(), "brainrot") then
                    rootPart.CFrame = CFrame.new(obj.Position)
                    ReplicatedStorage.Events.Collect:FireServer(obj)
                    wait(farmDelay + math.random(0.1, 0.5))
                end
            end
            -- Collect cash
            for _, obj in pairs(workspace:GetChildren()) do
                if string.find(obj.Name:lower(), "cash") then
                    rootPart.CFrame = CFrame.new(obj.Position)
                    ReplicatedStorage.Events.Pickup:FireServer(obj) -- Assume cash pickup event
                    wait(farmDelay + math.random(0.1, 0.5))
                end
            end
            wait(farmDelay)
        end
    end)
end
