```lua
local AdminAPI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Toon-arch/Admin-API/main/api.lua"))()
```

some trash example:
```lua
local AdminAPI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Toon-arch/Admin-API/main/api.lua"))()
AdminAPI.Prefix = "." -- Default is ;
AdminAPI.CreateChatHook() -- Automatically handle chat commands
AdminAPI.CreateCommand("reset", {}, function(args, speaker)
    if AdminAPI.GetCharacter() and AdminAPI.GetHumanoid() then -- Check if the player Character and Humanoid exists
		AdminAPI.GetHumanoid().Health = 0 -- Set Humanoid health to 0
	end
end)
```
