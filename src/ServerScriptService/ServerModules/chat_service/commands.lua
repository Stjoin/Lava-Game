local library = require(game:GetService("ReplicatedStorage").Library) 

local DataService = library.DataService

function GetPlayer(Name)
	if not Name or Name == "" then return end
	for _, Player in pairs(game.Players:GetPlayers()) do
		if Player.Name:lower():match("^"..Name:lower()) then return Player end
	end
end

local module = {
	["set"] = {
		UserIds = {
			1398400189,
		},
		Function = function(Player, Arguments)
			local Target = GetPlayer(Arguments[2])
			if not Target then
				return "Local", "Invalid player", "rgb(255,0,0)"
			else
				local Data = DataService:GetData(Target, Arguments[3])
				if Data == nil then
					return "Local", "No value named "..Arguments[3], "rgb(255,0,0)"
				else
					local Msg = string.format("%s value for %s changed from %s to %s successfully", Arguments[3], Target.Name, tostring(Data), tostring(Arguments[4]))
					DataService:Set(Target, Arguments[3], "=", tonumber(Arguments[4]))
					return "Local", Msg, "rgb(0,255,0)"
				end
			end
		end,
	},

	["get"] = {
		UserIds = {
			1398400189,
		},
		Function = function(Player, Arguments)
			local Target = GetPlayer(Arguments[2])
			if not Target then
				return "Local", "Invalid player", "rgb(255,0,0)"
			else
				local Data = DataService:GetData(Target, Arguments[3])
				if Data == nil then
					return "Local", "No value named "..Arguments[3], "rgb(255,0,0)"
				else
					return "Local", string.format("%s value for %s: %s", Arguments[3], Target.Name, tostring(Data)), "rgb(0,200,255)"
				end
			end
		end,
	},

	["robloxmessage"] = {
		UserIds = {
			1,
		},
		Function = function(Player, Arguments)
			return "Global", "This is a roblox message: "..table.concat(Arguments, " ", 2, #Arguments), "rgb(0,0,0)"
		end,
	},
}

return module
