-- Shotting logic
local tool = script.Parent
local fireEvent = tool:WaitForChild("FireEvent")

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

tool.Activated:Connect(function()
	print("Activated: Gun Button")
	local origin = game.Workspace.CurrentCamera.CFrame.Position
	local direction = (mouse.Hit.Position - origin).Unit * 500
	
	fireEvent:FireServer(origin, direction)
end)
