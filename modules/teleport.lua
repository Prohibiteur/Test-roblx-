-- Module Teleport - Téléportation rapide
getgenv().TeleportModule = function(targetType)
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local teleportRange = HttpService:JSONDecode(readfile("config.json")).sliders.teleportRange or 500

    if not rootPart then return end

    local closestTarget = nil
    local minDist = teleportRange

    if targetType == "brainrot" then
        for _, obj in pairs(workspace:GetChildren()) do
            if string.find(obj.Name:lower(), "brainrot") then
                local dist = (obj.Position - rootPart.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    closestTarget = obj
                end
            end
        end
    elseif targetType == "base" then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local base = workspace:FindFirstChild(p.Name .. "_Base") -- Assume base naming
                if base then
                    local dist = (base.Position - rootPart.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closestTarget = base
                    end
                end
            end
        end
    end

    if closestTarget then
        rootPart.CFrame = CFrame.new(closestTarget.Position + Vector3.new(0, 5, 0))
        wait(math.random(0.1, 0.3)) -- Random pour anti-detect
    end
end
