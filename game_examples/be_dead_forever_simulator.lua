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

spawn(function()
	local PlayerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
	local Chatbox = nil
	local success, result = pcall(function() Chatbox = game.WaitForChild(PlayerGui, "Chat").Frame.ChatBarParentFrame.Frame.BoxFrame.Frame.ChatBar end)
	if success then
		local UserInputService = game:GetService("UserInputService")
		UserInputService.InputBegan:Connect(function(Input, GameProcessed)
			if not GameProcessed and Input.KeyCode == Enum.KeyCode.Period then
				Chatbox:CaptureFocus()
				game:GetService("RunService").RenderStepped:Wait()
				Chatbox.Text = "/e ."
				Chatbox.CursorPosition = Chatbox.CursorPosition + 3
			end
		end)
	end
end)

AdminAPI.CreateCommand("deadcoins", {"deadcoin", "coin", "dc"}, function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name == "Computer" and v:FindFirstChild("Monitor") then
			for i2,v2 in pairs(v.Monitor:GetDescendants()) do
				if v2:IsA("ClickDetector") and v2.Name == "ClickDetector" then
					spawn(function()
						fireclickdetector(v2, 0)
						while wait(0.5) do
							fireclickdetector(v2, 0)
						end
					end)
				end
			end
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

AdminAPI.CreateCommand("ctrllock", {"ctrl", "lock", "cl"}, function(args, speaker)
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

AdminAPI.CreateCommand("chat", {}, function(args, speaker)
	game:GetService("StarterGui"):SetCoreGuiEnabled("Chat", true)
end)

AdminAPI.CreateCommand("antiafk", {"antiidle"}, function(args, speaker)
	local getcons = getconnections or get_signal_cons
	if getcons then
		for i,v in pairs(getcons(Players.LocalPlayer.Idled)) do
			if v["Disable"] then
				v["Disable"](v)
			elseif v["Disconnect"] then
				v["Disconnect"](v)
			end
		end
		AdminAPI.Notify("anti afk enabled")
	end
end)

AdminAPI.CreateCommand("cleancars", {}, function(args, speaker)
	local match = function(str1, str2)
		return string.find(string.lower(tostring(str1)), string.lower(tostring(str2)))
	end
	while wait(1) do
		for i,v in pairs(workspace:GetChildren()) do
			if match(v.Name, "goodcar") then
				v:Remove()
			end
			if match(v.Name, "bestmovingcar") then
				v:Remove()
			end
		end
	end
	AdminAPI.Notify("cleaning cars")
end)

AdminAPI.CreateCommand("autofarm", {"farm", "af"}, function(args, speaker)
	AdminAPI.ExecuteCommand("deadcoins")
	AdminAPI.ExecuteCommand("ctrllock")
	AdminAPI.ExecuteCommand("antiafk")
end)

AdminAPI.CreateCommand("giveburgers", {"giveburger", "burgers", "burger", "food"}, function(args, speaker)
    if workspace:FindFirstChild("burgre") then
		for i,v in pairs(workspace.burgre:GetDescendants()) do
			if v:IsA("ClickDetector") then
				fireclickdetector(v, 0)
			end
		end
	end
end)

AdminAPI.CreateCommand("givebloxycola", {"givecola", "givesoda", "soda", "drink"}, function(args, speaker)
    local VendingMachine = nil
	for i,v in pairs(workspace:GetChildren()) do
		if string.lower(tostring(v.Name)) == "vending machine" then
			for i2,v2 in pairs(v:GetDescendants()) do
				if v2:IsA("ClickDetector") then
					VendingMachine = v2
				end
			end
		end
	end
	if VendingMachine ~= nil then
		fireclickdetector(VendingMachine, 0)
	end
end)

AdminAPI.CreateCommand("autosprint", {"mobilesprint", "asprint", "msprint", "sprint"}, function(args, speaker)
    local PlayerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
	if not PlayerGui and not PlayerGui:FindFirstChild("RunButton") then return end
	local RunButton = PlayerGui.RunButton
	if RunButton:FindFirstChild("Button") then
		RunButton.Button.ImageTransparency = 0
		if RunButton.Button:FindFirstChild("LocalScript") then
			RunButton.Button.LocalScript.Disabled = false
		end
	end
	RunButton.Enabled = true
	AdminAPI.Notify("mobile sprint visible")
end)

AdminAPI.Notify(string.format("loaded (prefix is %s)", tostring(AdminAPI.Prefix)))
