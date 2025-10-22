-- Module VisualEffects - Particules et glow
getgenv().VisualEffectsModule = function(enabled)
    local RunService = game:GetService("RunService")

    local function addParticleEffect(part)
        local emitter = Instance.new("ParticleEmitter")
        emitter.Parent = part
        emitter.Texture = "rbxassetid://123456789" -- Remplace par un ID de particule (étoiles rouges)
        emitter.Rate = 50
        emitter.Speed = NumberRange.new(1, 3)
        emitter.Lifetime = NumberRange.new(1, 2)
        emitter.Color = ColorSequence.new(Color3.new(1, 0, 0))
        
        local glow = Instance.new("PointLight")
        glow.Parent = part
        glow.Color = Color3.new(1, 0, 0)
        glow.Range = 10
        glow.Brightness = 1
    end

    if enabled then
        for _, obj in pairs(workspace:GetChildren()) do
            if string.find(obj.Name:lower(), "brainrot") then
                addParticleEffect(obj)
            end
        end
        -- Update pour nouveaux brainrots
        RunService.Heartbeat:Connect(function()
            for _, obj in pairs(workspace:GetChildren()) do
                if string.find(obj.Name:lower(), "brainrot") and not obj:FindFirstChild("ParticleEmitter") then
                    addParticleEffect(obj)
                end
            end
        end)
    else
        for _, obj in pairs(workspace:GetChildren()) do
            if obj:FindFirstChild("ParticleEmitter") then obj.ParticleEmitter:Destroy() end
            if obj:FindFirstChild("PointLight") then obj.PointLight:Destroy() end
        end
    end
end
