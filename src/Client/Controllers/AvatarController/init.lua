--[[
	Avatar Controller
	Handles the mechanics of the player's avatar
--]]

local AvatarController = {}

---------------------
-- Roblox Services --
---------------------
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

------------------
-- Dependencies --
------------------
local DeathUI = require(script.DeathUI)
setmetatable(DeathUI,{__index = AvatarController})

-------------
-- Defines --
-------------
local Falling_Connection;
local AvatarDied;
local Player = Players.LocalPlayer
local Abilities = {}

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Helper functions
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function HandleRagdollDeath()
	AvatarController.AvatarDied:connect(function()
		AvatarController:SetRagdolled(true)

		wait(1)
		for _,Object in pairs(Player.Character:GetDescendants()) do
			if Object:IsA("BasePart") then
				local FadeTween = TweenService:Create(
					Object,
					TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),
					{
						Transparency = 1
					}
				)
				local DecompileParticle = ReplicatedStorage.Assets.Particles.DecompileParticle:Clone()
				DecompileParticle.Enabled = true
				DecompileParticle.Parent = Object

				FadeTween:Play()
			end
		end
		wait(1)
		for _,Object in pairs(Player.Character:GetDescendants()) do
			if Object:IsA("ParticleEmitter") then
				Object.Enabled = false
			end
		end
		DeathUI:Show()
	end)
end

local function DisableProblematicHumanoidStates(Character)
	local Humanoid = Character:WaitForChild("Humanoid")

	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,false)
end

local function HandleHumanoidHealth(Character)
	local Humanoid = Character:WaitForChild("Humanoid")

	Humanoid:SetAttribute("Health",1)

	Humanoid:GetAttributeChangedSignal("Health"):connect(function()
		if Humanoid:GetAttribute("Health") == 0 then
			AvatarDied:Fire()
		end
	end)

	Humanoid.Touched:connect(function(TP)
		if TP.Name == "_Damage" then
			AvatarController:SetAvatarHealth(0)
		end
	end)
end

local function HandleJumpGravity(Character)
	local RootPart = Character:WaitForChild("HumanoidRootPart")

	Falling_Connection = RunService.Stepped:connect(function()
		if RootPart.AssemblyLinearVelocity.Y < 0 then
			Workspace.Gravity = 120
		else
			Workspace.Gravity = 196.2
		end

		if Character.Parent == nil then
			Falling_Connection:Disconnect()
			Workspace.Gravity = 196.2
		end
	end)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- API Methods
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : GetAbility
-- @Description : Returns the APIs of the specified ability
-- @Params : string "AbilityName" - The name of the ability to get the APIs of
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AvatarController:GetAbility(AbilityName)
	return Abilities[AbilityName]
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : SetAvatarHealth
-- @Description : Sets the health of the player's current avatar
-- @Params : int "Health" - The health to set the player's health to
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AvatarController:SetAvatarHealth(Health)
	if Player.Character ~= nil then
		if Player.Character.Humanoid ~= nil then
			Player.Character.Humanoid:SetAttribute("Health",Health)
		end
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : GetAvatarHealth
-- @Description : Returns the health of the player's current avatar
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AvatarController:GetAvatarHealth()
	if Player.Character == nil then
		return 0
	elseif Player.Character.Humanoid == nil then
		return 0
	else
		return Player.Character.Humanoid:GetAttribute("Health")
	end
end

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
	AvatarDied = self:RegisterControllerClientEvent("AvatarDied")

	self:DebugLog("[Avatar Controller] Initialized!")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Start
-- @Description : Called after all Controllers are loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AvatarController:Start()
	self:DebugLog("[Avatar Controller] Started!")

	DeathUI:Init()

	---------------------------
	-- Handling reset button --
	---------------------------
	local ResetBindable = Instance.new('BindableEvent')

	while true do
		local Success,_ = pcall(function()
			StarterGui:SetCore("ResetButtonCallback",ResetBindable)
		end)

		if Success then
			break
		else
			RunService.Stepped:wait()
		end
	end

	ResetBindable.Event:connect(function()
		self:SetAvatarHealth(0)
	end)

	------------------------------
	-- Running avatar abilities --
	------------------------------
	for _,AbilityModule in pairs(script.Abilities:GetChildren()) do
		local Ability = require(AbilityModule)

		setmetatable(Ability,{__index = self})
		Ability:Init()

		Abilities[AbilityModule.Name] = Ability
	end

	--------------------------------
	-- Ragdolling player on death --
	--------------------------------
	if Player.Character ~= nil then
		HandleRagdollDeath(Player.Character)
	end
	Player.CharacterAdded:connect(HandleRagdollDeath)

	-------------------------------------------
	-- Disabling problematic humanoid states --
	-------------------------------------------
	if Player.Character ~= nil then
		coroutine.wrap(DisableProblematicHumanoidStates)(Player.Character)
	end
	Player.CharacterAdded:connect(DisableProblematicHumanoidStates)

	------------------------------
	-- Handling falling gravity --
	------------------------------
	if Player.Character ~= nil then
		coroutine.wrap(HandleJumpGravity)(Player.Character)
	end
	Player.CharacterAdded:connect(HandleJumpGravity)

	--------------------------------
	-- Initializing avatar health --
	--------------------------------
	if Player.Character ~= nil then
		coroutine.wrap(HandleHumanoidHealth)(Player.Character)
	end
	Player.CharacterAdded:connect(HandleHumanoidHealth)
end

return AvatarController