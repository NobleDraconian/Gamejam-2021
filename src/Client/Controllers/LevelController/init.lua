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
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

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
local MenuCamRunning = false
local CurrentCamTween;

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

local function RunMenuCam()
	MenuCamRunning = true

	local MenuMap = ReplicatedStorage.Assets.MenuMap:Clone()
	MenuMap.Parent = Workspace
	local SequenceNumber = 1

	coroutine.wrap(function()
		while true do
			local Sequence = MenuMap.CamSequences[tostring(SequenceNumber)]
			CurrentCamTween = TweenService:Create(
				Workspace.CurrentCamera,
				TweenInfo.new(7,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),
				{
					CFrame = Sequence.End.CFrame
				}
			)

			Workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
			Workspace.CurrentCamera.CFrame = Sequence.Start.CFrame

			CurrentCamTween:Play()
			wait(7)

			if not MenuCamRunning then
				MenuMap:Destroy()
				break
			else
				SequenceNumber = SequenceNumber + 1

				if MenuMap.CamSequences:FindFirstChild(tostring(SequenceNumber)) == nil then
					SequenceNumber = 1
				end
			end
		end
	end)()
end

local function StopMenuCam()
	MenuCamRunning = false
	CurrentCamTween:Cancel()
	Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
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
	StopMenuCam()
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
	LightingController:LoadLightingState("Tutorial Level")
	StopMusic()
	LevelService:StopLevel()
	PlayMusic("1842066455")
	RunMenuCam()
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
	LightingController:LoadLightingState("Tutorial Level")

	MenuUI:Init()
	PlayMusic("1842066455")
	RunMenuCam()
end

return LevelController