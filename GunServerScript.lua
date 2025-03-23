local tool = script.Parent
local fireEvent = tool:WaitForChild("FireEvent")

fireEvent.OnServerEvent:Connect(function(player, origin, direction)
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {player.Character}
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	
	local result = workspace:Raycast(origin, direction, rayParams)
	
	if result then 
		local hitpart = result.Instance
		local hitHumanoid = hitpart.Parent:FindFirstChild("Humanoid")
		
		if hitHumanoid then 
			hitHumanoid:TakeDamage(25)
		end
		
		local bulletHole = Instance.new("Part")
		bulletHole.Size = Vector3.new(0.2, 0.2, 0.2)
		bulletHole.Position = result.Position
		bulletHole.Anchored = true
		bulletHole.CanCollide = false
		bulletHole.BrickColor = BrickColor.new("Bright red")
		bulletHole.Parent = workspace
		
		game.Debris:AddItem(bulletHole, 2)
	end
end)
