--[[
	Dive
	Handles the logic of the dive ability
--]]

local Dive = {}

---------------------
-- Roblox Services --
---------------------
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

------------------
-- Dependencies --
------------------
local AvatarController;

-------------
-- Defines --
-------------
local Stepped_Connection;
local Player = Players.LocalPlayer
local IsDiving = false

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Helper functions
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function HandleDiveButton(_,InputState)
	if InputState == Enum.UserInputState.Begin then
		if AvatarController:GetAvatarHealth() > 0 then
			if Player.Character ~= nil then
				if Player.Character.Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
					Dive:DoDive()
				end
			end
		end
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- API Methods
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : DoDive
-- @Description : Makes the player's avatar dive
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Dive:DoDive()
	if not IsDiving then
		IsDiving = true

		local Character = Player.Character
		local PrimaryPart = Character.PrimaryPart
		local Humanoid = Character.Humanoid
		local CastParams = RaycastParams.new()
		CastParams.FilterDescendantsInstances = {Player.Character}
		CastParams.FilterType = Enum.RaycastFilterType.Blacklist

		PrimaryPart.Velocity = PrimaryPart.Velocity + Vector3.new(0,20,0) + (PrimaryPart.CFrame.LookVector * 120)

		Stepped_Connection = RunService.Stepped:connect(function()
			local ForwardRaycastResult = Workspace:Raycast(
				PrimaryPart.Position,
				PrimaryPart.CFrame.LookVector * 5,
				CastParams
			)

			if AvatarController:GetAvatarHealth() == 0 or Character.Parent == nil then
				self:StopDive(false)
			elseif Humanoid:GetState() ~= Enum.HumanoidStateType.Freefall and Humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
				self:StopDive(false)
			elseif ForwardRaycastResult ~= nil then
				if ForwardRaycastResult.Instance.CanCollide then
					self:StopDive(true,ForwardRaycastResult)
				end
			end
		end)
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : StopDive
-- @Description : Stops the player's avatar dive
-- @Params : bool "ShouldFling" - Whether or not the player should get flung in the opposite direction of the impact
--           Instance <RaycastResult> "CastResult" - The results of the impact raycast
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Dive:StopDive(ShouldFling,CastResult)
	Stepped_Connection:Disconnect()

	if ShouldFling then
		local Character = Player.Character
		local PrimaryPart = Character.PrimaryPart
		PrimaryPart.Velocity = PrimaryPart.Velocity + (-CastResult.Normal * 300)
	end
	IsDiving = false
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Init
-- @Description : Executes the dive logic
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Dive:Init()
	AvatarController = self:GetController("AvatarController")

	ContextActionService:BindAction("Dive",HandleDiveButton,true,Enum.KeyCode.LeftShift,Enum.KeyCode.ButtonX)
end

return Dive