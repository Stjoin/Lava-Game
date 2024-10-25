local library = require(game:GetService("ReplicatedStorage").Library) 

local module = {}

local DataService = library.DataService
local ChatAPI = require(script.Parent.chat_service)

module.Badges = {
	["Welcome"] = 1044829127650435,
	["SavedGoose"] = 526424862010325,
	["UsedFreeVipTerrace"] = 3350255807152303,
	["FirstRebirth"] = 2262699297320039,
	["ThirdRebirth"] = 1392933464450400,
	["Stjoin1"] = 1384565252866012,
}

module.Meet = {
	["Stjoin1"] = {1384565252866012},
}

function module.AwardBadge(Player, Badge)
	local hasBadge = DataService:GetData(Player,{"Badges", Badge})
	
	if hasBadge == false then
		local _,Error = pcall(function()
			local Success, Result = pcall(function()
				library.BadgeService:AwardBadge(Player.UserId, module.Badges[Badge])
			end)
			local Info = library.BadgeService:GetBadgeInfoAsync(module.Badges[Badge])
			if Success then
				ChatAPI.localSystemMessage(Player, "You have earned the '"..Info.Name.."' badge", "rgb(70,255,70)")
				DataService:Set(Player, {"Badges", Badge}, "=", true)
			end
		end)
		if Error then
			warn(Error)
		end
	end
end

return module
