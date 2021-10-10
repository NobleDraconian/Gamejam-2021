--[[
	Double jump
	Handles the logic of the double jump mechanic
--]]

local DoubleJump = {}

---------------------
-- Roblox Services --
---------------------
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")

------------------
-- Dependencies --
------------------
local AvatarController;

-------------
-- Defines --
-------------
local Player = Players.LocalPlayer
local HumanoidState_Connection;
local DoubleJump_Anim_StateConnection;
local DoubleJump_Anim_Data = Instance.new('Animation')
DoubleJump_Anim_Data.AnimationId = "rbxassetid://5732750031"
local DoubleJump_Anim;
local HasSingleJumped = false
local HasDoubleJumped = false

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Helper functions
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function SetCharacterCollidable(Character,Collidable)
	for _,Object in pairs(Character:GetChildren()) do
		if Object:IsA("BasePart") then
			Object.CanCollide = Collidable
		end
	end
end

local function HandleCharacterAdded(Character)
	local Humanoid = Character:WaitForChild("Humanoid")
	local RootPart = Character:WaitForChild("HumanoidRootPart")
	local SingleJumpSound = Instance.new('Sound')
	SingleJumpSound.SoundId = "rbxassetid://6048433907"
	SingleJumpSound.Name = "SingleJump"
	SingleJumpSound.Parent = RootPart
	local DoubleJumpSound = Instance.new('Sound')
	DoubleJumpSound.SoundId = "rbxassetid://6048434976"
	DoubleJumpSound.Name = "DoubleJump"
	DoubleJumpSound.Parent = RootPart

	DoubleJump_Anim = Humanoid:LoadAnimation(DoubleJump_Anim_Data)

	if HumanoidState_Connection ~= nil then
		HumanoidState_Connection:Disconnect()
	end
	HumanoidState_Connection = Humanoid.StateChanged:connect(function(_,NewState)
		if NewState ~= Enum.HumanoidStateType.Jumping and NewState ~= Enum.HumanoidStateType.Freefall then -- Landed
			HasSingleJumped = false
			HasDoubleJumped = false
		elseif NewState == Enum.HumanoidStateType.Freefall then
			HasSingleJumped = true
		end
	end)

	if DoubleJump_Anim_StateConnection ~= nil then
		DoubleJump_Anim_StateConnection:Disconnect()
	end
	DoubleJump_Anim_StateConnection = DoubleJump_Anim:GetPropertyChangedSignal("IsPlaying"):connect(function()
		wait() --! Hack, we need to toggle collisions 1 frame after humanoid recalculates collisions due to state change
		SetCharacterCollidable(Character,not DoubleJump_Anim.IsPlaying)
	end)
end

local function HandleJumpButton(_,InputState)
	if InputState == Enum.UserInputState.Begin then
		if AvatarController:GetAvatarHealth() > 0 then
			if not HasSingleJumped then
				HasSingleJumped = true
				DoubleJump:DoJump()
				Player.Character.HumanoidRootPart.SingleJump:Play()
			elseif not HasDoubleJumped then
				HasDoubleJumped = true
				DoubleJump:DoJump()
				DoubleJump_Anim:Play(0.1,1,0.8)
				Player.Character.HumanoidRootPart.DoubleJump:Play()
			end
		end
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- API Methods
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : DoJump
-- @Description : Makes the player's avatar do a jump
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DoubleJump:DoJump()
	if Player.Character ~= nil then
		if Player.Character.Humanoid ~= nil then
			Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Init
-- @Description : Executes the doublejump logic
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DoubleJump:Init()

	AvatarController = self:GetController("AvatarController")

	-------------------------------------
	-- Assigning inputs to jump action --
	-------------------------------------
	ContextActionService:BindAction("Jump",HandleJumpButton,false,Enum.KeyCode.Space,Enum.KeyCode.ButtonA)
	if Player:WaitForChild("PlayerGui"):FindFirstChild("TouchGui") ~= nil then
		Player.PlayerGui.TouchGui.TouchControlFrame.JumpButton.MouseButton1Down:connect(function()
			HandleJumpButton(nil,Enum.UserInputState.Begin)
		end)
	end

	-----------------------------------------
	-- Handling humanoid state transitions --
	-----------------------------------------
	if Player.Character ~= nil then
		coroutine.wrap(HandleCharacterAdded)(Player.Character)
	end
	Player.CharacterAdded:connect(HandleCharacterAdded)
end

return DoubleJump