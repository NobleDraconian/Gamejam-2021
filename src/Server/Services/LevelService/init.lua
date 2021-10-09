--[[
	Level service
	Handles the server sided logic of the game's levels
--]]

local LevelService = {Client = {}}
LevelService.Client.Server = LevelService

---------------------
-- Roblox Services --
---------------------
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

-------------
-- Defines --
-------------
local Player;
local CurrentMap;
local LevelConfigs = {}

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Client.RequestRespawn
-- @Description : Respawns the player
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LevelService.Client:RequestRespawn(CallingPlayer)
	CallingPlayer:LoadCharacter()
	CallingPlayer.Character:SetPrimaryPartCFrame(CurrentMap.Spawn.CFrame)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Client.GetMap
-- @Description : Returns a reference of the current level's map to the client
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LevelService.Client:GetMap()
	return CurrentMap
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Client.RunLevel
-- @Description : Loads & Runs the specified level
-- @Params : string "LevelID" - The ID of the level to run
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LevelService.Client:RunLevel(_,LevelID)
	local LevelConfig = LevelConfigs[LevelID]

	if CurrentMap ~= nil then
		CurrentMap:Destroy()
	end

	local Map = ServerStorage.Assets.Maps[LevelConfig.MapName]:Clone()
	Map.Parent = Workspace
	CurrentMap = Map

	Player:LoadCharacter()
	Player.Character:SetPrimaryPartCFrame(Map.Spawn.CFrame)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Client.StopLevel
-- @Description : Stops the current level
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LevelService.Client:StopLevel()
	CurrentMap:Destroy()

	if Player.Character ~= nil then
		Player.Character:Destroy()
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Init
-- @Description : Called when the service module is first loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LevelService:Init()

	for _,LevelConfigModule in pairs(ReplicatedStorage.LevelConfigs:GetChildren()) do
		LevelConfigs[LevelConfigModule.Name] = require(LevelConfigModule)
	end

	self:DebugLog("[Level Service] Initialized!")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Start
-- @Description : Called after all services are loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LevelService:Start()
	self:DebugLog("[Level Service] Started!")

	if #Players:GetPlayers() > 0 then
		Player = Players:GetPlayers()[1]
	end
	Players.PlayerAdded:connect(function(PlayerObject)
		Player = PlayerObject
	end)
end

return LevelService