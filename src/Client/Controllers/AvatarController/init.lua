--[[
	Avatar Controller
	Handles the mechanics of the player's avatar
--]]

local AvatarController = {}

---------------------
-- Roblox Services --
---------------------
local Players = game:GetService("Players")

-------------
-- Defines --
-------------
local Player = Players.LocalPlayer

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Helper functions
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function HandleRagdollDeath(Character)
	Character:WaitForChild("Humanoid").Died:connect(function()
		AvatarController:SetRagdolled(true)
	end)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- API Methods
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : SetRagdolled
-- @Description : Sets whether or not the player's current avatar is ragdolled
-- @Params : bool "ShouldRagdoll" - Whether or not the player's avatar should ragdoll
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AvatarController:SetRagdolled(ShouldRagdoll)
	shared.SetRagdolled(ShouldRagdoll) -- Bridge to roblox ragdoll library
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Init
-- @Description : Called when the Controller module is first loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AvatarController:Init()
	self:DebugLog("[Avatar Controller] Initialized!")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Start
-- @Description : Called after all Controllers are loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AvatarController:Start()
	self:DebugLog("[Avatar Controller] Started!")

	--------------------------------
	-- Ragdolling player on death --
	--------------------------------
	if Player.Character ~= nil then
		HandleRagdollDeath(Player.Character)
	end
	Player.CharacterAdded:connect(HandleRagdollDeath)
end

return AvatarController