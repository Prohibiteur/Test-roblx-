-- Module Theme - Style néon pour GUI Rayfield
getgenv().ThemeModule = function()
    local theme = {
        Accent = Color3.fromRGB(255, 0, 100), -- Néon rouge
        Background = Color3.fromRGB(20, 20, 30), -- Fond violet foncé
        TextColor = Color3.fromRGB(200, 100, 255), -- Texte violet clair
        ElementBackground = Color3.fromRGB(30, 30, 50), -- Éléments semi-violets
        ElementTransparency = 0.8,
        BorderColor = Color3.fromRGB(255, 0, 100), -- Bordure néon rouge
        ShadowColor = Color3.fromRGB(0, 0, 0), -- Ombre noire
        Font = Enum.Font.SourceSansBold
    }
    -- Applique le thème à Rayfield (doit être appelé après CreateWindow)
    if getgenv().Rayfield then
        getgenv().Rayfield:UpdateTheme(theme)
    end
    return theme
end
