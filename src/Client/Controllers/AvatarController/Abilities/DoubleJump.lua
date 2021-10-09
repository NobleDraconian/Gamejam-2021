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
local HasSingleJumped = false
local HasDoubleJumped = false

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Helper functions
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function HandleCharacterAdded(Character)
	local Humanoid = Character:WaitForChild("Humanoid")

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
end

local function HandleJumpButton(_,InputState)
	if InputState == Enum.UserInputState.Begin then
		if AvatarController:GetAvatarHealth() > 0 then
			if not HasSingleJumped then
				HasSingleJumped = true
				DoubleJump:DoJump()
			elseif not HasDoubleJumped then
				HasDoubleJumped = true
				DoubleJump:DoJump()
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