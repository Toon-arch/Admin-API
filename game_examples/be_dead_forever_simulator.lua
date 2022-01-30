local Players = game:GetService("Players")
local AdminAPI = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Toon-arch/Admin-API/main/api.lua"))();

AdminAPI.Prefix = "."
AdminAPI.CreateChatHook()
AdminAPI.Notify = function(str)
	game:GetService("StarterGui"):SetCore("SendNotification", {
		["Title"] = "bdfs admin",
		["Text"] = tostring(str)
	})
end

AdminAPI.CreateCommand("deadcoins", {"deadcoin"}, function(args, speaker)
    local CMP = nil
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name == "Computer" and v:FindFirstChild("Monitor") then
			CMP = v.Monitor
		end
	end
	while CMP == nil do wait() end
	for i,v in pairs(CMP:GetDescendants()) do
		if v:IsA("ClickDetector") and v.Name == "ClickDetector" then
			spawn(function()
				while wait(0.5) do
        			fireclickdetector(v, 0)
				end
			end)
		end
	end
	AdminAPI.Notify("firing pc")
end)

AdminAPI.CreateCommand("givemedkits", {"givemedkit", "medkits", "medkits", "med"}, function(args, speaker)
    if workspace:FindFirstChild("Meshes/Medkit") then
		for i,v in pairs(workspace["Meshes/Medkit"]:GetDescendants()) do
			if v:IsA("ClickDetector") and v.Name == "ClickDetector" then
				fireclickdetector(v, 0)
			end
		end
	end
end)

AdminAPI.CreateCommand("injureself", {"injure"}, function(args, speaker)
    if AdminAPI.GetCharacter() and AdminAPI.GetHumanoid() then
		AdminAPI.GetHumanoid().Health = 0.1
	end
end)

AdminAPI.CreateCommand("ctrllock", {}, function(args, speaker)
	local LocalPlayer = Players.LocalPlayer
	if not LocalPlayer then return end
	local NewLockKey = "LeftControl"
	local MouseLockController = LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("CameraModule"):WaitForChild("MouseLockController")
	local Object = MouseLockController:FindFirstChild("BoundKeys")
	if Object then
		Object.Value = NewLockKey
	else
		Object = Instance.new("StringValue")
		Object.Name = "BoundKeys"
		Object.Value = NewLockKey
		Object.Parent = MouseLockController
	end
	AdminAPI.Notify("binded shift to ctrl")
end)

AdminAPI.CreateCommand("rejoin", {"rj"}, function(args, speaker)
	local TeleportService = game:GetService("TeleportService")
	if #Players:GetPlayers() <= 1 then
		speaker:Kick("\nRejoining...")
		wait()
		TeleportService:Teleport(game.PlaceId, speaker)
	else
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, speaker)
	end
end)

AdminAPI.Notify("loaded")
