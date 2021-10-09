--[[
	Menu UI
	Handles the logic of the main menu UI
--]]

local MenuUI = {}

---------------------
-- Roblox Services --
---------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

------------------
-- Dependencies --
------------------
local LevelController;

-------------
-- Defines --
-------------
local UI = ReplicatedStorage.Assets.UIs.MainMenu:Clone()
UI.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Show
-- @Description : Shows the UI
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function MenuUI:Show()
	UI.Enabled = true
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name: Hide
-- @Description : Hides the UI
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function MenuUI:Hide()
	UI.Enabled = false
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Init
-- @description : Initializes the UI
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function MenuUI:Init()
	LevelController = self:GetController("LevelController")

	for LevelID,LevelConfigs in pairs(LevelController:GetLevelConfigs()) do
		local LevelButton = UI.LevelSelect.BaseLevelButton:Clone()
		LevelButton.LevelNumber.Text = LevelConfigs.LevelOrder
		LevelButton.LayoutOrder = LevelConfigs.LevelOrder
		LevelButton.Parent = UI.LevelSelect
		LevelButton.Visible = true

		LevelButton.MouseButton1Click:connect(function()
			LevelController:RunLevel(LevelID)
			self:Hide()
		end)
	end
end

return MenuUI