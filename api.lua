local AdminAPI = {
    ["Debug"] = false,
    ["Commands"] = {},
    ["Prefix"] = ";",
}

local Players = game:GetService("Players")
local wait, spawn = wait, spawn

local isNumber = function(str)
	if tonumber(str) ~= nil or str == "inf" then
		return true
	end
end

local FindInTable = function(tbl, val)
	if not tbl then return false end
	for _, v in pairs(tbl) do
		if v == val then return true end
	end 
	return false
end

local getCharacter = function(player)
    player = player or Players.LocalPlayer
    return player.Character
end

local getHum = function(character)
	character = character or getCharacter()
	return character:FindFirstChildOfClass("Humanoid")
end

local getBp = function(character)
	character = character or getCharacter()
	return character:FindFirstChildOfClass("Backpack")
end

local getRoot = function(character)
	character = character or getCharacter()
	return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
end

local findCmd = function(cmd_name)
	for i,v in pairs(AdminAPI.Commands) do
		if string.lower(v.NAME) == string.lower(cmd_name) or FindInTable(v.ALIAS, string.lower(cmd_name)) then
			return v
		end
	end
end

local splitString = function(str, delim)
	local broken = {}
	if not delim then delim = "," end
	for w in string.gmatch(str, "[^" .. delim .. "]+") do
		table.insert(broken, w)
	end
	return broken
end

local SpecialPlayerCases = {
	["all"] = function(speaker) return Players:GetPlayers() end,
	["others"] = function(speaker)
		local plrs = {}
		for i,v in pairs(Players:GetPlayers()) do
			if v ~= speaker then
				table.insert(plrs, v)
			end
		end
		return plrs
	end,
	["me"] = function(speaker) return {speaker} end,
	["#(%d+)"] = function(speaker, args, currentList)
		local returns = {}
		local randAmount = tonumber(args[1])
		local players = {unpack(currentList)}
		for i = 1,randAmount do
			if #players == 0 then break end
			local randIndex = math.random(1, #players)
			table.insert(returns, players[randIndex])
			table.remove(players, randIndex)
		end
		return returns
	end,
	["random"] = function(speaker, args, currentList)
		local players = currentList
		return {players[math.random(1, #players)]}
	end,
	["%%(.+)"] = function(speaker, args)
		local returns = {}
		local team = args[1]
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team and string.sub(string.lower(plr.Team.Name), 1, #team) == string.lower(team) then
				table.insert(returns, plr)
			end
		end
		return returns
	end,
	["allies"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team == team then
				table.insert(returns, plr)
			end
		end
		return returns
	end,
	["enemies"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team ~= team then
				table.insert(returns, plr)
			end
		end
		return returns
	end,
	["team"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team == team then
				table.insert(returns, plr)
			end
		end
		return returns
	end,
	["nonteam"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team ~= team then
				table.insert(returns, plr)
			end
		end
		return returns
	end,
	["friends"] = function(speaker, args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr:IsFriendsWith(speaker.UserId) and plr ~= speaker then
				table.insert(returns, plr)
			end
		end
		return returns
	end,
	["nonfriends"] = function(speaker, args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if not plr:IsFriendsWith(speaker.UserId) and plr ~= speaker then
				table.insert(returns, plr)
			end
		end
		return returns
	end,
	["guests"] = function(speaker, args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Guest then
				table.insert(returns, plr)
			end
		end
		return returns
	end,
	["bacons"] = function(speaker, args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Character:FindFirstChild("Pal Hair") or plr.Character:FindFirstChild("Kate Hair") then
				table.insert(returns, plr)
			end
		end
		return returns
	end,
	["age(%d+)"] = function(speaker, args)
		local returns = {}
		local age = tonumber(args[1])
		if not age then return end
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.AccountAge <= age then
				table.insert(returns, plr)
			end
		end
		return returns
	end,
	["nearest"] = function(speaker, args, currentList)
		local speakerChar = speaker.Character
		if not speakerChar or not getRoot(speakerChar) then return end
		local lowest = math.huge
		local NearestPlayer = nil
		for _,plr in pairs(currentList) do
			if plr ~= speaker and plr.Character then
				local distance = plr:DistanceFromCharacter(getRoot(speakerChar).Position)
				if distance < lowest then
					lowest = distance
					NearestPlayer = {plr}
				end
			end
		end
		return NearestPlayer
	end,
	["farthest"] = function(speaker, args, currentList)
		local speakerChar = speaker.Character
		if not speakerChar or not getRoot(speakerChar) then return end
		local highest = 0
		local Farthest = nil
		for _,plr in pairs(currentList) do
			if plr ~= speaker and plr.Character then
				local distance = plr:DistanceFromCharacter(getRoot(speakerChar).Position)
				if distance > highest then
					highest = distance
					Farthest = {plr}
				end
			end
		end
		return Farthest
	end,
	["group(%d+)"] = function(speaker, args)
		local returns = {}
		local groupID = tonumber(args[1])
		for _,plr in pairs(Players:GetPlayers()) do
			if plr:IsInGroup(groupID) then
				table.insert(returns, plr)
			end
		end
		return returns
	end,
	["alive"] = function(speaker, args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") and plr.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
				table.insert(returns, plr)
			end
		end
		return returns
	end,
	["dead"] = function(speaker, args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if (not plr.Character or not plr.Character:FindFirstChildOfClass("Humanoid")) or plr.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
				table.insert(returns, plr)
			end
		end
		return returns
	end,
	["rad(%d+)"] = function(speaker, args)
		local returns = {}
		local radius = tonumber(args[1])
		local speakerChar = speaker.Character
		if not speakerChar or not getRoot(speakerChar) then return end
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Character and getRoot(plr.Character) then
				local magnitude = (getRoot(plr.Character).Position-getRoot(speakerChar).Position).magnitude
				if magnitude <= radius then table.insert(returns, plr) end
			end
		end
		return returns
	end
}

local addspecialplayerCase = function(str, func)
	SpecialPlayerCases[tostring(str)] = func
end

local removespecialplayerCase = function(str)
	SpecialPlayerCases[tostring(str)] = nil
end

local toTokens = function(str)
	local tokens = {}
	for op,name in string.gmatch(str, "([+-])([^+-]+)") do table.insert(tokens, {["Operator"] = op, ["Name"] = name}) end
	return tokens
end

local onlyIncludeInTable = function(tab, matches)
	local matchTable = {}
	local resultTable = {}
	for i,v in pairs(matches) do matchTable[v.Name] = true end
	for i,v in pairs(tab) do if matchTable[v.Name] then table.insert(resultTable, v) end end
	return resultTable
end

local removeTableMatches = function(tab, matches)
	local matchTable = {}
	local resultTable = {}
	for i,v in pairs(matches) do matchTable[v.Name] = true end
	for i,v in pairs(tab) do if not matchTable[v.Name] then table.insert(resultTable, v) end end
	return resultTable
end

local getPlayersByName = function(Name)
	local Name, Len, Found = string.lower(Name), #Name, {}
	for _,v in pairs(Players:GetPlayers()) do
		if string.sub(Name, 0, 1) == "@" then
			if string.sub(string.lower(v.Name), 1, Len - 1) == string.sub(Name, 2) then
				table.insert(Found, v)
			end
		else
			if string.sub(string.lower(v.Name), 1, Len) == Name or string.sub(string.lower(v.DisplayName), 1, Len) == Name then
				table.insert(Found, v)
			end
		end
	end
	return Found
end

local getPlayer = function(list, speaker)
	if not list then return {speaker.Name} end
	local nameList = splitString(list, ",")

	local foundList = {}

	for _,name in pairs(nameList) do
		if string.sub(name, 1, 1) ~= "+" and string.sub(name, 1, 1) ~= "-" then name = "+" .. name end
		local tokens = toTokens(name)
		local initialPlayers = Players:GetPlayers()

		for i,v in pairs(tokens) do
			if v.Operator == "+" then
				local tokenContent = v.Name
				local foundCase = false
				for regex,case in pairs(SpecialPlayerCases) do
					local matches = {string.match(tokenContent, "^" .. regex .. "$")}
					if #matches > 0 then
						foundCase = true
						initialPlayers = onlyIncludeInTable(initialPlayers, case(speaker, matches, initialPlayers))
					end
				end
				if not foundCase then
					initialPlayers = onlyIncludeInTable(initialPlayers, getPlayersByName(tokenContent))
				end
			else
				local tokenContent = v.Name
				local foundCase = false
				for regex,case in pairs(SpecialPlayerCases) do
					local matches = {string.match(tokenContent, "^" .. regex .. "$")}
					if #matches > 0 then
						foundCase = true
						initialPlayers = removeTableMatches(initialPlayers, case(speaker, matches, initialPlayers))
					end
				end
				if not foundCase then
					initialPlayers = removeTableMatches(initialPlayers, getPlayersByName(tokenContent))
				end
			end
		end

		for i,v in pairs(initialPlayers) do table.insert(foundList, v) end
	end

	local foundNames = {}
	for i,v in pairs(foundList) do table.insert(foundNames, v.Name) end

	return foundNames
end

local cmdHistory = {}
local lastCmds = {}
local split = " "
local lastBreakTime = 0
local cargs = {}
local execCmd = function(cmdStr, speaker, store)
	cmdStr = string.gsub(cmdStr, "%s+$", "")
	spawn(function()
		local rawCmdStr = cmdStr
		cmdStr = string.gsub(cmdStr, "\\\\", "%%BackSlash%%")
		local commandsToRun = splitString(cmdStr, "\\")
		for i,v in pairs(commandsToRun) do
			v = string.gsub(v, "%%BackSlash%%", "\\")
			local x, y, num = string.find(v, "^(%d+)%^")
			local cmdDelay = 0
			local infTimes = false
			if num then
				v = string.sub(v, y + 1)
				local x, y, del = string.find(v, "^([%d%.]+)%^")
				if del then
					v = string.sub(v, y + 1)
					cmdDelay = tonumber(del) or 0
				end
			else
				local x,y = string.find(v, "^inf%^")
				if x then
					infTimes = true
					v = string.sub(v, y + 1)
					local x, y, del = string.find(v, "^([%d%.]+)%^")
					if del then
						v = string.sub(v, y + 1)
						del = tonumber(del) or 1
						cmdDelay = (del > 0 and del or 1)
					else
						cmdDelay = 1
					end
				end
			end
			num = tonumber(num or 1)
			if string.sub(v, 1, 1) == "!" then
				local chunks = splitString(string.sub(v, 2), split)
				if chunks[1] and lastCmds[chunks[1]] then v = lastCmds[chunks[1]] end
			end
			local args = splitString(v, split)
			local cmdName = args[1]
			local cmd = findCmd(cmdName)
			if cmd then
				table.remove(args, 1)
				cargs = args
				if not speaker then speaker = Players.LocalPlayer end
				if store then
					if speaker == Players.LocalPlayer then
						if cmdHistory[1] ~= rawCmdStr and string.sub(rawCmdStr, 1, 11) ~= "lastcommand" and string.sub(rawCmdStr, 1, 7) ~= "lastcmd" then
							table.insert(cmdHistory, 1, rawCmdStr)
						end
					end
					if #cmdHistory > 30 then table.remove(cmdHistory) end
					lastCmds[cmdName] = v
				end
				local cmdStartTime = tick()
				if infTimes then
					while lastBreakTime < cmdStartTime do
						local success, err = pcall(cmd.FUNC, args, speaker)
						if not success and AdminAPI.Debug then
							warn("Command Error:", cmdName, err)
						end
						wait(cmdDelay)
					end
				else
					for rep = 1,num do
						if lastBreakTime > cmdStartTime then break end
						local success, err = pcall(function()
							cmd.FUNC(args, speaker)
						end)
						if not success and AdminAPI.Debug then
							warn("Command Error:", cmdName, err)
						end
						if cmdDelay ~= 0 then wait(cmdDelay) end
					end
				end
			end
		end
	end)
end

local getstring = function(begin)
	local start = begin - 1
	local AA = "" for i,v in pairs(cargs) do
		if i > start then
			if AA ~= "" then
				AA = AA .. " " .. v
			else
				AA = AA .. v
			end
		end
	end
	return AA
end

local createChatHook = function()
    local getprfx = function(strn)
        if string.sub(strn, 1, string.len(AdminAPI.Prefix)) == AdminAPI.Prefix then return {"cmd", string.len(AdminAPI.Prefix) + 1} end return
    end
    local do_exec = function(str, plr)
        str = string.gsub(str, "/e ", "")
        local t = getprfx(str)
        if not t then return end
        str = string.sub(str, t[2])
        if t[1] == "cmd" then
            execCmd(str, plr, true)
        end
    end
    Players.LocalPlayer.Chatted:Connect(function(message)
        spawn(function()
            wait()
            do_exec(string.lower(tostring(message)), Players.LocalPlayer)
        end)
    end)
end

local addcmdtotable = function(name, alias, func)
    local Tag = #AdminAPI.Commands + 1
    AdminAPI.Commands[Tag] = {
        ["NAME"] = name,
        ["ALIAS"] = alias or {},
        ["FUNC"] = func
    }
    local DestroyFunc = function()
        AdminAPI.Commands[Tag] = nil
    end
    return {["Destroy"]=DestroyFunc,["Remove"]=DestroyFunc,["Delete"]=DestroyFunc}
end

local makeNotification = function(...)
	local arguments = {...}
	if arguments[1] and arguments[2] then
		game:GetService("StarterGui"):SetCore("SendNotification", {
			["Title"] = tostring(arguments[1]),
			["Text"] = tostring(arguments[2])
		})
	end
	if arguments[1] and not arguments[2] then
		game:GetService("StarterGui"):SetCore("SendNotification", {
			["Title"] = "admin",
			["Text"] = tostring(arguments[1])
		})
	end
end

AdminAPI.GetPlayer = getPlayer
AdminAPI.ExecuteCommand = execCmd
AdminAPI.GetString = getstring
AdminAPI.FindCommand = findCmd
AdminAPI.IsNumber = isNumber
AdminAPI.CreateChatHook = createChatHook
AdminAPI.CreateCommand = addcmdtotable
AdminAPI.NewCommand = addcmdtotable
AdminAPI.AddCommand = addcmdtotable
AdminAPI.GetCharacter = getCharacter
AdminAPI.GetHumanoid = getHum
AdminAPI.GetBackpack = getBp
AdminAPI.GetRoot = getRoot
AdminAPI.Notify = makeNotification
AdminAPI.AddSpecialPlayerCase = addspecialplayerCase
AdminAPI.RemoveSpecialPlayerCase = removespecialplayerCase
return AdminAPI
