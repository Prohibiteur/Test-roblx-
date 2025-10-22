-- Module AntiBan - Protection proactive
getgenv().AntiBanModule = function(enabled)
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer

    spawn(function()
        while enabled do
            -- Simule comportement légitime
            local randomMove = Vector3.new(
                math.random(-10, 10),
                0,
                math.random(-10, 10)
            )
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid:MoveTo(player.Character.HumanoidRootPart.Position + randomMove)
            end
            -- Bloque logs suspects
            for _, conn in pairs(getconnections(game:GetService("LogService").MessageOut)) do
                conn:Disable() -- Désactive logs côté client
            end
            wait(math.random(5, 10)) -- Intervalles aléatoires
        end
    end)
end
