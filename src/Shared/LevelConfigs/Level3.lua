local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LightingFolder = ReplicatedStorage.Assets.Lighting.Level3

return {
    LevelOrder = 3,
    LevelName = "Level 3",
    MapName = "Level3",
    MusicID = "1842066455",

    LightingState = {
        Properties = {
            Ambient = Color3.fromRGB(112,112,112),
            Brightness = 1.25,
            ColorShift_Bottom = Color3.fromRGB(255,0,0),
            ColorShift_Top = Color3.fromRGB(255,0,0),
            EnvironmentDiffuseScale = 1,
            EnvironmentSpecularScale = 1,
            GlobalShadows = true,
            OutdoorAmbient = Color3.fromRGB(0,0,0),
            ShadowSoftness = 0,
            ClockTime = 12.097,
            GeographicLatitude = 23.999,
            ExposureCompensation = 0.25
        },
        Effects = {
            Atmosphere = LightingFolder.Atmosphere,
            Bloom = LightingFolder.Bloom,
            Blur = LightingFolder.Blur,
            ColorCorrection = LightingFolder.ColorCorrection,
            Skybox = LightingFolder.Skybox
        }
    }
}