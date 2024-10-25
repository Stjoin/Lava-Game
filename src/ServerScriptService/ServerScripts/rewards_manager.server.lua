--> Variables

local library = require(game:GetService("ReplicatedStorage").Library)
local functions = library.Functions
local dataService = library.DataService
local rewardsConfig = library.Configurations.rewards
local settingsConfig = library.Configurations.settings

--> Daily rewards

library.Remotes.ClaimDailyReward.OnServerInvoke = function(Player, Reward)
	if dataService:GetData(Player, "LoginStreak") < Reward then return end
	if dataService:GetData(Player, `DailyRewards.{Reward}`) then return end
	
	dataService:Set(Player, `DailyRewards.{Reward}`, "=", true)
	
	local Missing = false
	for _,Reward in pairs(dataService:GetData(Player, "DailyRewards")) do
		Missing = Missing or Reward
	end
	if not Missing then
		dataService:Set(Player, `LoginStreak`, "=", 1)
	end
	return settingsConfig.RewardPlayer(Player, rewardsConfig.DailyRewards[Reward].Rewards, true)
end


--> 