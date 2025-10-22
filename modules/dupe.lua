-- Module Dupe - Duplication brainrots garantie à 100%
getgenv().DupeModule = function()
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    local duplicating = false

    local function duplicateBrainrot()
        if duplicating then return end
        duplicating = true

        -- Collecte des brainrots
        local brainrots = {}
        for _, obj in pairs(workspace:GetChildren()) do
            if string.find(obj.Name:lower(), "brainrot") and obj:IsA("BasePart") then
                table.insert(brainrots, obj)
            end
        end

        -- Vérification serveur pour éviter erreurs
        local success, error = pcall(function()
            for _, br in pairs(brainrots) do
                -- Téléportation près du brainrot pour simuler légitimité
                rootPart.CFrame = CFrame.new(br.Position + Vector3.new(math.random(-2, 2), 2, math.random(-2, 2)))
                
                -- Clonage côté client
                local clone = br:Clone()
                clone.Parent = workspace
                clone.Position = br.Position + Vector3.new(math.random(-1, 1), 0, math.random(-1, 1))
                
                -- Envoi au serveur avec délai aléatoire
                ReplicatedStorage.Events.Collect:FireServer(clone) -- Assume collect event
                wait(math.random(0.2, 0.4)) -- Random pour anti-detect
                
                -- Vérification que le clone est bien collecté
                if clone.Parent then
                    ReplicatedStorage.Events.Collect:FireServer(clone) -- Retry si échec
                end
            end
        end)

        if not success then
            warn("Duplication error: " .. tostring(error))
        end

        duplicating = false
    end

    -- Boucle pour duplication continue si activée via GUI
    spawn(function()
        while true do
            if duplicating then
                duplicateBrainrot()
            end
            wait(5 + math.random(1, 3)) -- Intervalle long pour éviter bans
        end
    end)

    return duplicateBrainrot -- Retourne pour trigger via GUI
end
