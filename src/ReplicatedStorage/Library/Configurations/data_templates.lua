local module = {}

module.playerProfile = {
	-- Gameplay
	Coins = 0,
	Wins = 0,
	
	--Rewards
	DailyRewards = {},
	
	--Pets
	ExtraPets = 0,
	Hatched = 0,
	MaxStorage = 0,
	MaxEquipped = 0,
	
	--Tutorial
	TutorialStage = 0,
	TutorialSubStage = 1,

	-- Stjoin Framework    
	Settings = {
		SFX = 0.6,
		Music = 0.6,
	},
	Tutorial = true,
	Codes = {},
	Badges = {},
	Potions = {},
	GamePasses = {},
	Subscriptions = {},
	RobuxSpent = 0,
	Joins = 0,
	FirstJoin = 0,
	LastLeft = 0,
	PlayTime = 0,
	LoginStreak = 1,
	SessionPlayTime = 0,
	LastJoined = 0,
	LastPlaceVersion = game.PlaceVersion,    
}

module.leaderstatsTemplate = {
	{dataName = "Coins", displayName = "Coins"},
	{dataName = "Wins", displayName = "Wins"},
}

module.mirroring = {
	["TotalCoins"] = {Mirror = "Coins", Parent = module.playerProfile}
}

-- Function to set configuration values
function module.setConfig(config)
	for key, value in pairs(config) do
		if module.playerProfile[key] ~= nil then
			module.playerProfile[key] = value
		else
			warn("Attempted to set unknown configuration key: " .. key)
		end
	end
end

return module