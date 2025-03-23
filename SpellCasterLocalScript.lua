local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local tool = script.Parent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local fireballTemplate = ReplicatedStorage:WaitForChild("FireBall")
local remote = tool:WaitForChild("FireSpellEvent")

tool.Activated:Connect(function()
	print("Activated: Spell Caster Button")
	local origin = workspace.CurrentCamera.CFrame.Position
	local direction = (mouse.Hit.Position - origin).Unit * 500

	-- Send this info to the server 
	remote:FireServer(origin, direction)
end)
