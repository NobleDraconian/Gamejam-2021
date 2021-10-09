--[[
	Death UI
	Handles the logic of the death UI
--]]

local DeathUI = {}

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
local UI = ReplicatedStorage.Assets.UIs.DeathUI:Clone()
UI.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Show
-- @Description : Shows the UI
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DeathUI:Show()
	UI.Enabled = true
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name: Hide
-- @Description : Hides the UI
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DeathUI:Hide()
	UI.Enabled = false
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Init
-- @Description : Initializes the UI
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DeathUI:Init()
	LevelController = self:GetController("LevelController")

	UI.Respawn.MouseButton1Click:connect(function()
		self:Hide()
		LevelController:RequestPlayerRespawn()
	end)

	UI.Quit.MouseButton1Click:connect(function()
		self:Hide()
		LevelController:StopLevel()
	end)
end

return DeathUI