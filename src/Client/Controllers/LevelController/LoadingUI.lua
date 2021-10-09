--[[
	Loading UI
	Handles the logic of the loading UI
--]]

local LoadingUI = {}

---------------------
-- Roblox Services --
---------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-------------
-- Defines --
-------------
local UI = ReplicatedStorage.Assets.UIs.LoadingUI:Clone()
UI.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Show
-- @Description : Shows the UI
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LoadingUI:Show()
	local FadeInTween = TweenService:Create(
		UI.Frame,
		TweenInfo.new(0.5,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),
		{
			BackgroundTransparency = 0
		}
	)

	FadeInTween:Play()
	FadeInTween.Completed:wait()
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name: Hide
-- @Description : Hides the UI
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LoadingUI:Hide()
	local FadeOutTween = TweenService:Create(
		UI.Frame,
		TweenInfo.new(0.5,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),
		{
			BackgroundTransparency = 1
		}
	)

	FadeOutTween:Play()
end

return LoadingUI