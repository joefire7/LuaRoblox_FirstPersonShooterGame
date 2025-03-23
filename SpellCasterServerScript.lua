local tool = script.Parent
local fireSpellEvent = tool:WaitForChild("FireSpellEvent")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

fireSpellEvent.OnServerEvent:Connect(function(player, origin, direction)
	print("fireSpellEvent")
	
	-- Retrieve the player's character and HumanoidRootPart
	local character = player.Character
	if not character then return end
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	-- Calculate the spawn position in front of the player's HumanoidRootPart
	local spawnOffset = 6 -- Distance in studs in front of the player
	local spawnPosition = humanoidRootPart.Position + (humanoidRootPart.CFrame.LookVector * spawnOffset)

	-- Create and configure the fireball
	local fireball = ReplicatedStorage:WaitForChild("FireBall"):Clone()
	fireball.CFrame = CFrame.new(spawnPosition, spawnPosition + direction)
	fireball.Anchored = false
	fireball.CanCollide = true
	fireball.Parent = workspace

	-- Set custom physical properties for heaviness and bounciness
	local customPhysics = PhysicalProperties.new(10, 1.3, 0.5) -- Density, Friction, Elasticity
	fireball.CustomPhysicalProperties = customPhysics

	-- Apply LinearVelocity
	local attachment = Instance.new("Attachment", fireball)
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = attachment
	linearVelocity.VectorVelocity = direction * 20 -- Adjust this value to control speed
	linearVelocity.Parent = fireball

	-- Detect collisions
	fireball.Touched:Connect(function(hit)
		local hitCharacter = hit.Parent
		local humanoid = hitCharacter:FindFirstChild("Humanoid")
		
		if humanoid and hitCharacter ~= character then
			humanoid:TakeDamage(25)
		end
		--fireball:Destroy()
	end)

	-- Clean up after 5 seconds
	Debris:AddItem(fireball, 5)
end)
