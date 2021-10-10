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
local function GetCharacterMass(Character)
	local Mass = 0
	for _, Obj in pairs(Character:GetChildren()) do
		if Obj:IsA("BasePart") and not Obj.Massless then
			Mass += Obj.Mass
		elseif Obj:IsA("Accoutrement") then
			local Handle = Obj:FindFirstChildWhichIsA("BasePart")
			if Handle and not Handle.Massless then
				Mass += Handle.Mass
			end
		end
	end

	return Mass
end

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

local function SetCharacterCollidable(Character,Collidable)
	for _,Object in pairs(Character:GetChildren()) do
		if Object:IsA("BasePart") then
			Object.CanCollide = Collidable
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

		SetCharacterCollidable(Player.Character,true)
		PrimaryPart:ApplyImpulse(Vector3.new(0,40 * GetCharacterMass(Character),0) + PrimaryPart.CFrame.LookVector * 100 * GetCharacterMass(Character))

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
	if IsDiving then
		Stepped_Connection:Disconnect()

		local Character = Player.Character
		local PrimaryPart = Character.PrimaryPart
		PrimaryPart.Velocity = Vector3.new(0,0,0)

		if ShouldFling then

			PrimaryPart:ApplyImpulse(-CastResult.Normal * 500 * GetCharacterMass(Character))
		end
		IsDiving = false
	end
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