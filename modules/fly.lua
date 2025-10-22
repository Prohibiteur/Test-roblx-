-- Module Fly - Vol fluide avec activation auto sur brainrot
getgenv().FlyModule = function()
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local HttpService = game:GetService("HttpService")
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")
    local config = HttpService:JSONDecode(readfile("config.json")) or {sliders={speed=50}}
    local speed = config.sliders.speed or 50
    local flying = false

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
                    wait(0.1 + math.random(0.01, 0.05)) -- Random pour anti-detect
                end
                bodyVelocity:Destroy()
                bodyAngularVelocity:Destroy()
            end)
        end
    end

    -- Auto Fly sur brainrot
    humanoid.Touched:Connect(function(hit)
        if string.find(hit.Name:lower(), "brainrot") and not flying then
            toggleFly()
            wait(2)
            flying = false
        end
    end)

    return toggleFly -- Retourne pour toggle via GUI
end
