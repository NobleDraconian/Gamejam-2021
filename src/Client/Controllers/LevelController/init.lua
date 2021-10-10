--[[
	Level Controller
	Handles the client sided logic of the game's levels
--]]

local LevelController = {}

---------------------
-- Roblox Services --
---------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

------------------
-- Dependencies --
------------------
local LevelService;
local LightingController;
local MenuUI = require(script.MenuUI)
setmetatable(MenuUI,{__index = LevelController})
local LoadingUI = require(script.LoadingUI)

-------------
-- Defines --
-------------
local Player = Players.LocalPlayer
local Music = Instance.new('Sound')
Music.Looped = true
Music.Parent = script
local LevelConfigs = {}

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Helper functions
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function PlayMusic(ID)
	Music.SoundId = "rbxassetid://" .. ID
	Music:Play()
end

local function StopMusic()
	Music:Stop()
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : RequestPlayerRespawn
-- @Description : Respawns the player
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LevelController:RequestPlayerRespawn()
	LevelService:RequestRespawn()
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Client.RunLevel
-- @Description : Loads & Runs the specified level
-- @Params : string "LevelID" - The ID of the level to run
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LevelController:RunLevel(LevelID)
	local LevelConfig = LevelConfigs[LevelID]
	local Map;
	local LevelEnd_TouchedConnection;

	LoadingUI:Show()
	PlayMusic(LevelConfig.MusicID)
	LightingController:LoadLightingState(LevelConfig.LevelName)
	LevelService:RunLevel(LevelID)
	LoadingUI:Hide()

	Map = LevelService:GetMap()

	LevelEnd_TouchedConnection = Map.LevelEnd.Touched:connect(function(TP)
		if TP:IsDescendantOf(Player.Character) then
			LevelEnd_TouchedConnection:Disconnect()

			self:StopLevel()
		end
	end)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : StopLevel
-- @Description : Stops the currently running level
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LevelController:StopLevel()
	LoadingUI:Show()
	MenuUI:Show()
	LightingController:LoadLightingState("Default")
	StopMusic()
	LevelService:StopLevel()
	LoadingUI:Hide()
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : GetLevelConfigs
-- @Description : Returns the configs for all registered levels
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LevelController:GetLevelConfigs()
	return LevelConfigs
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Init
-- @Description : Called when the Controller module is first loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LevelController:Init()
	LevelService = self:GetService("LevelService")

	for _,LevelConfigModule in pairs(ReplicatedStorage.LevelConfigs:GetChildren()) do
		LevelConfigs[LevelConfigModule.Name] = require(LevelConfigModule)
	end

	MenuUI:Init()

	self:DebugLog("[Level Controller] Initialized!")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Start
-- @Description : Called after all Controllers are loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LevelController:Start()
	self:DebugLog("[Level Controller] Started!")

	LightingController = self:GetController("LightingController")

	for _,LevelConfig in pairs(LevelConfigs) do
		LightingController:RegisterLightingState(LevelConfig.LevelName,LevelConfig.LightingState)
	end
end

return LevelController