--> variables
local replicatedStorage = game.ReplicatedStorage

local bindables = replicatedStorage.Networking.Bindables
local dataService = require(script.Parent.Parent.Shared.data_service)

local module = {}

--> module variables

module.GroupId = 34099005
module.PlayersCanCollide = false
module.ScreenOrientation = Enum.ScreenOrientation.LandscapeSensor

module.BoostPerFriend = 10
module.PremiumBoost = 15

module.Subscriptions = {
}

module.GamePasses = {
	[794509600] = "OctupleHatch",
	[2] = "DoubleChest",
	[919277781] = "2xCash",
	[928505226] = "AutoCollect",
	[3] = "2xVip",
	[915804095] = "TO_VipTerrace_Forever",
	
	--Packs
	[928255967] = "StarterPack"
}

module.DevProducts = {
	
	[1937796016] = "UnlockGoose",

	--Potions
	[1941102762] = "MegaPotionsPack",
	[1941066175] = "X2CashPotion",
	[1941066561] = "VipRushPotion",
	
	--Upgrades
	[1902623965] = "upgrade_pick_up_capacity",
	[1929515068] = "upgrade_walk_speed",
	[1929515465] = "upgrade_cash_magnet",
	[1929515736] = "upgrade_pick_up_speed",
	
	[1929513710] = "upgrade_waiter_speed",
	[1929514752] = "upgrade_waiter_money_collect",
	
	[1929511036] = "purchase_staff",
	
	--Wheel Spin
	[1902917757] = "FirstOfDay_1Spin",
	[1902911356] = "1Spin",
	[1902911673] = "10Spin",
	[1902912184] = "100Spin",
	
	--Pet Slots
	[1925627292] = "UnlockPetSlot2",
	[1925627338] = "UnlockPetSlot3",

	--Timed Objects
	[1927622001] = "TO_VipTerrace_ExtraTime",
	
	-- Donations
	[2008548944] = "1",
	[2008554829] = "2",
	[2008574509] = "3",
	[2008567285] = "4",
	[2008562289] = "5",
	[2008584745] = "6",
	
	-- Currency
	[1941068258] = "Set1",
	[1941073378] = "Set2",
	[1941075108] = "Set3",
	[1941077400] = "Set4",
	[1941077867] = "Set5",
}

module.Bundles = {

}

module.GamePassId = {}
module.DevProductId = {}
module.SubscriptionId = {}

for Id,GamePass in pairs(module.GamePasses) do
	module.GamePassId[GamePass] = Id
end

for Id,DevProduct in pairs(module.DevProducts) do
	module.DevProductId[DevProduct] = Id
end

for Id,Subscription in pairs(module.Subscriptions) do
	module.SubscriptionId[Subscription] = Id
end

module.Potions = {
	["X2CashPotion"] = "x2Cash",
	["VipRushPotion"] = "VipRush",
}

module.PotionBundles = {
	["MegaPotionsPack"] = {
		["x2Cash"] = 4,
		["VipRush"] = 4,
	},
	["StarterPack"] = {
		["x2Cash"] = 1,
	},
}

module.Currency = {
	["Set1"] = {path = "Cash", amount = 1500},
	["Set2"] = {path = "Cash", amount = 5000},
	["Set3"] = {path = "Cash", amount = 15000},
	["Set4"] = {path = "Cash", amount = 50000},
	["Set5"] = {path = "Cash", amount = 1000000},
}

module.PotionDurations = {
	["x2Cash"] = 10*60,
	["VipRush"] = 8*60,
}

module.CurrencyMultipliers = {
	["Cash"] = 1,
}

--> module functions

function module.Owns(Player, Info)
	local UserId = Player.UserId

	local Group, UserIds, GamePass, Leaderboard = Info.GroupInfo, Info.UserIds, Info.GamePass, Info.LeaderboardInfo or {}
	--local Rank = Info.LeaderboardInfo and LeaderboardAPI.GetRank(Leaderboard.Leaderboard, Player)
	local Placement, Higher, Equal = Leaderboard.Placement, Leaderboard.Higher, Leaderboard.Equal
	local Subscription = Info.Subscription
	local Premium = Info.Premium
	Subscription = Subscription and Player.Subscriptions:FindFirstChild(Subscription)
	GamePass = GamePass and dataService:GetData(Player, `GamePasses.{GamePass}`)
	
	return Info.Everyone
		or (UserIds and table.find(UserIds, UserId))
		or (Premium and Player:WaitForChild("Premium").Value)
		--or (Leaderboard and ((Higher and Rank < Placement) or (Equal and Rank == Placement)))
		or (Group and Player:GetRankInGroup(Group.Id) == Group.Rank)
		or (Subscription and Subscription.Value)
		or (GamePass and GamePass)
end

function module.Multiplier(Player, Type)
	local dataSet = dataService:GetProfileData(Player)
	local Multiplier = 1
	
	if Type == "Cash" then
		Multiplier *= 1 + (Player.Premium.Value and module.PremiumBoost/100 or 0)
		Multiplier *= 1 + (module.BoostPerFriend/100 * #Player.Friends:GetChildren())
		Multiplier *= 1 + ((dataSet.Potions["x2Cash"].Time > 0) and 1 or 0)
		Multiplier *= 1 + (dataSet.GamePasses["2xCash"] and 1 or 0)
		Multiplier *= 1 + (dataSet.RebirthUpgrades.Income.IncreaseIncome and 0.5 or 0)
		Multiplier *= 1 + (dataSet.Rebirths/10 or 0)
	end

	return Multiplier * (module.CurrencyMultipliers[Type] or 1)
end

function module.RewardString(Player, Rewards)
	local RewardString = "You recieved "

	for Index,Reward in pairs(Rewards) do
		local Prefix, String = (Index == 1 and "") or (Index == #Rewards and " and ") or ", ", nil

		if Reward.Type then
			String = Reward.Amount.." "..Reward.Type
		elseif Reward.Pet then
			String = Reward.Pet
		elseif Reward.Egg then
			String = "x"..Reward.Amount.." "..Reward.Egg
		elseif Reward.Potion then
			String = "x"..Reward.Amount.." "..Reward.Potion.." Potions"
		elseif Reward.GamePass then
			String = Reward.GamePass.." GamePass"
		elseif Reward.SpinAmount then
			String = Reward.SpinAmount.." Spins"
		elseif Reward.ExtraPetSlot then
			String = "Extra Pet Slot"
		end

		RewardString = RewardString..Prefix..String or ""
	end

	RewardString = RewardString.."!"
	return RewardString
end

function module.RewardPlayer(Player, Rewards, RewardString)
	for Index,Reward in pairs(Rewards) do
		if Reward.Type then
			dataService:Set(Player, `{Reward.Type}`, "+", Reward.Amount * module.Multiplier(Player, Reward.Type))	
		elseif Reward.Potion then
			dataService:Set(Player, `Potions.{Reward.Potion}.Uses`, "+", Reward.Amount)
		elseif Reward.GamePass then
			dataService:Set(Player, `GamePasses.{Reward.GamePass}`, "=", true)	
		elseif Reward.SpinAmount then      
            dataService:Set(Player, "Spins", "+", Reward.SpinAmount)
		elseif Reward.Pet then
			bindables.CreatePet:Fire(Player, Reward.Pet)
		elseif Reward.ExtraPetSlot then
			local currentSlots = dataService:GetData(Player, "PetSlots")
			
			for slotName,slotConfig in currentSlots do
				if slotConfig.Available == true then
					continue
				end
				
				dataService:Set(Player, `PetSlots.{slotName}.Available`, "=", true)
				break
			end

		--elseif Reward.Egg then
		--Remotes.Pets.HatchEgg:FireClient(Player, Reward.Egg, PetsAPI.EggPets(Player, Reward.Egg, Reward.Amount, {}))
		end
	end

	return RewardString and module.RewardString(Player, Rewards) or true
end

return module
