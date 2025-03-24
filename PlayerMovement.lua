local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Double tap tracking
local tapTimes = {
	W = 0,
	A = 0,
	S = 0,
	D = 0,
}
local DOUBLE_TAP_TIME = 0.3 -- seconds allowed between taps
local dashCooldown = 0.5
local isDashing = false

-- Double Jump
local canDoubleJump = true
local hasDoubleJumped = false
local isJumping = false
local isFalling = false
local isGrounded = true
local DOUBLE_JUMP_FORCE = 60

-- Dash function
local function dash(direction)
	if isDashing then return end
	isDashing = true

	local dashForce = Instance.new("BodyVelocity")
	dashForce.Velocity = direction * 80
	dashForce.MaxForce = Vector3.new(1e5, 0, 1e5)
	dashForce.P = 1e5
	dashForce.Parent = rootPart
	Debris:AddItem(dashForce, 0.2)

	task.delay(dashCooldown, function()
		isDashing = false
	end)
end

-- Key to direction mapping
local keyDirections = {
	W = function() return rootPart.CFrame.LookVector end,
	S = function() return -rootPart.CFrame.LookVector end,
	A = function() return -rootPart.CFrame.RightVector end,
	D = function() return rootPart.CFrame.RightVector end,
}

-- Input Detection
UserInputService.InputBegan:Connect(function(input, isTyping)
	if isTyping then return end

	local keyName = input.KeyCode.Name
	if keyDirections[keyName] then
		local now = tick()
		if now - tapTimes[keyName] < DOUBLE_TAP_TIME then
			-- Second tap detected: dash!
			local direction = keyDirections[keyName]()
			dash(direction)
		end
		tapTimes[keyName] = now
	end
end)


-- Track grounded state
humanoid.StateChanged:Connect(function(_, newState)
	if newState == Enum.HumanoidStateType.Landed or newState == Enum.HumanoidStateType.Running then
		hasDoubleJumped = false
		isGrounded = true
	elseif newState == Enum.HumanoidStateType.Freefall then
		isGrounded = false
	end
end)

-- Detect SPACE key
UserInputService.InputBegan:Connect(function(input, isTyping)
	if isTyping then return end

	if input.KeyCode == Enum.KeyCode.Space then
		if not isGrounded and not hasDoubleJumped then
			hasDoubleJumped = true

			-- Upward force
			local JUMP_FORCE = 60
			local FORWARD_BOOST = 25
			local currentVelocity = rootPart.Velocity

			-- Forward direction (camera-based or character-based)
			local forwardDir = rootPart.CFrame.LookVector

			-- Create BodyVelocity for forward + upward boost
			local dash = Instance.new("BodyVelocity")
			dash.Velocity = forwardDir * FORWARD_BOOST + Vector3.new(0, JUMP_FORCE, 0)
			dash.MaxForce = Vector3.new(1e5, 1e5, 1e5)
			dash.P = 1e5
			dash.Parent = rootPart

			game:GetService("Debris"):AddItem(dash, 0.2)

			-- Optional: tell Humanoid to play jump animation
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)