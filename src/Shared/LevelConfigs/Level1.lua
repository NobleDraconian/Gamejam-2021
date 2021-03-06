local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LightingFolder = ReplicatedStorage.Assets.Lighting.Level1

return {
	LevelOrder = 1,
	LevelName = "Tutorial Level",
	MapName = "Level1",
	MusicID = "1836627134",

	LightingState = {
		Properties = {
			Ambient = Color3.fromRGB(112,112,112),
			Brightness = 1,
			ColorShift_Bottom = Color3.fromRGB(0,170,255),
			ColorShift_Top = Color3.fromRGB(0,170,255),
			EnvironmentDiffuseScale = 1,
			EnvironmentSpecularScale = 1,
			GlobalShadows = true,
			OutdoorAmbient = Color3.fromRGB(0,0,0),
			ShadowSoftness = 0,
			ClockTime = 12.097,
			GeographicLatitude = 23.999,
			ExposureCompensation = 0.5
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