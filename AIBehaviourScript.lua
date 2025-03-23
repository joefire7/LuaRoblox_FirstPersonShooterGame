local robot = script.Parent
local humanoid = robot:WaitForChild("Humanoid")
local root = robot:WaitForChild("HumanoidRootPart")
local RunService = game:GetService("RunService")
local players= game:GetService("Players")
local shootCooldown = 4
local canShoot = true

local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(8, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

-- Server-side
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local cameraShakeEvent = ReplicatedStorage:WaitForChild("CameraShakeRemoteEvent")

local currentTween = nil

-- disable extra physics stuff
humanoid.PlatformStand = false
humanoid.AutoRotate = false

--local dead = false

local isDead = robot:FindFirstChild("IsDead")
if not isDead then
	isDead = Instance.new("BoolValue")
	isDead.Name = "IsDead"
	isDead.Value = false
	isDead.Parent = robot
end


local function getClosestPlayer()
	local closestPlayer = nil
	local shortestDistance = math.huge
	
	for _, player in ipairs(players:GetPlayers()) do 
		local character = player.Character
		if character and character:FindFirstChild("HumanoidRootPart") then 
			local distance = (character.HumanoidRootPart.Position - root.Position).Magnitude
			if distance < shortestDistance then
				shortestDistance = distance
				closestPlayer = character
			end
		end
	end
	return closestPlayer, shortestDistance
end

local function shoot(target)
	if not canShoot then return end
	canShoot = false
	
	-- simulate shooting (raycast or projectile)
	local direction = (target.HumanoidRootPart.Position - root.Position).Unit
	local rayOrigin = root.Position
	local rayDistance = 500
	local rayDirection = direction * rayDistance
	
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {robot}
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	
	local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)
	local hitPosition = result and result.Position or (rayOrigin + rayDirection)
	
	-- visualize the laser beam
	local beamPart = Instance.new("Part")
	beamPart.Anchored = true;
	beamPart.CanCollide = false
	beamPart.Color = Color3.fromRGB(255, 0, 0) 
	beamPart.Material = Enum.Material.Neon
	beamPart.Transparency = 0
	beamPart.Size = Vector3.new(0.1, 0.1, (rayOrigin - hitPosition).Magnitude)
	beamPart.CFrame = CFrame.new(rayOrigin, hitPosition) * CFrame.new(0, 0, -beamPart.Size.Z / 2)
	beamPart.Parent = workspace
	
	-- Remove the beam after a short time
	game:GetService("Debris"):AddItem(beamPart, 0.15)
	
	if result and result.Instance then 
		local hitHumanoid = result.Instance.Parent:FindFirstChild("Humanoid")
		if hitHumanoid then
			hitHumanoid:TakeDamage(10)
			
			-- send caera shake to client
			local player = game.Players:GetPlayerFromCharacter(hitHumanoid.Parent)
			if player then
				cameraShakeEvent:FireClient(player)
			end
		end
	end
	print("Robot shot at player!")
	
	-- cool down before next shot
	task.delay(shootCooldown, function()
		canShoot = true
	end)
end


-- Blink effect
local function blink()
	for _, part in ipairs(robot:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			part.Transparency = 1
		end
	end
	task.wait(0.1)
	for _, part in ipairs(robot:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			part.Transparency = 0
		end
	end
end

-- Health check
humanoid.HealthChanged:Connect(function(health)
	if health <= 0 and not isDead.Value then
		isDead.Value = true
		canShoot = false

		print("Robot is dead!")
		task.wait(5.0)
		robot:Destroy()

		-- Respawn another robot somewhere else
		local newRobot = ReplicatedStorage:WaitForChild("Bluey roboty"):Clone()
		newRobot.Parent = workspace
		newRobot:SetPrimaryPartCFrame(CFrame.new(Vector3.new(math.random(-50, 50), 5, math.random(-50, 50)))) -- Change spawn logic as needed
	end

	-- Blink only if still alive
	if health > 0 then
		blink()
	end
end)

RunService.Heartbeat:Connect(function(deltaTime)
	local target, distance = getClosestPlayer()
	if target then
		local targetPos = target.HumanoidRootPart.Position
		-- follow if far
		if distance > 500 then
			-- cancel old tween if one is playing
			if currentTween then
				currentTween:Cancel()
				currentTween = nil
			end
			--humanoid:MoveTo(targetPos)
			--local goal = {}
			--goal.Position = targetPos
			--currentTween = TweenService:Create(root, tweenInfo, goal)
			--currentTween:Play()
			
			local lookAt = CFrame.lookAt(root.Position, target.HumanoidRootPart.Position)
			root.CFrame = root.CFrame:Lerp(lookAt, 0.1)
			
		-- face the player
		else 
			-- Cancel movement tween when 
			if currentTween then
				currentTween:Cancel()
				currentTween = nil
			end
			
			-- look at the player
			local lookAt = CFrame.lookAt(root.Position, targetPos)
			root.CFrame = root.CFrame:Lerp(lookAt, 0.1)
			
			-- Shoot if close
			shoot(target)
		end
	end
end)
