local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera

local shakeOffset = CFrame.new()
local shaking = false

-- Handle camera shake from remote
ReplicatedStorage:WaitForChild("CameraShakeRemoteEvent").OnClientEvent:Connect(function()
	if shaking then return end
	shaking = true

	local duration = 0.3
	local strength = 0.4
	local elapsed = 0

	local conn
	conn = RunService.RenderStepped:Connect(function(dt)
		elapsed += dt
		if elapsed > duration then
			conn:Disconnect()
			shakeOffset = CFrame.new()
			shaking = false
			return
		end

		local offset = Vector3.new(
			math.random(-100, 100) / 100 * strength,
			math.random(-100, 100) / 100 * strength,
			math.random(-100, 100) / 100 * strength
		)
		local angle = math.rad(math.random(-5, 5))
		local rotation = CFrame.Angles(angle, angle, angle)

		shakeOffset = CFrame.new(offset) * rotation
	end)
end)

-- Lock FPS camera and apply shake
RunService.RenderStepped:Connect(function()
	if not player.Character then return end
	local humanoid = player.Character:FindFirstChild("Humanoid")
	if not humanoid then return end

	player.CameraMode = Enum.CameraMode.LockFirstPerson
	camera.CameraSubject = humanoid

	-- Apply shake offset manually
	if shaking then
		camera.CFrame = camera.CFrame * shakeOffset
	end
end)