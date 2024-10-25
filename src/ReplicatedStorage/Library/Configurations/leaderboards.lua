local module = {}
local RunService = game:GetService("RunService")
local functions = require(script.Parent.Parent.Packages.Functions)
local dataService = require(script.Parent.Parent.Shared.data_service)

module.Max = 99
module.Refresh = 20
module.ServerRefresh = 30
module.EmptyCell = "Loading..."
module.Leaderboards = script.Leaderboards

if RunService:IsServer() then
	local DataStoreService = game:GetService("DataStoreService")
	
	module.DataStores = {
		["Coins"] = {
			Version = "V2",
			Ascending = false,
			Format = function(Number)
				return "🟡 "..functions.abbreviate(Number)
			end,
			path = "Cash"
		},
		["Wins"] = {
			Version = "V2",
			Ascending = false,
			Format = function(Number)
				return "🏆 "..functions.abbreviate(Number)
			end,
			path = "Wins"
		},
		["Robux"] = {
			Version = "V2",
			Ascending = false,
			Format = function(Number)
				return "\u{E002}" .. functions.abbreviate(Number)
			end,
			path = "RobuxSpent"
		},
	}

	module.ServerLeaderboards = {
		
	}
	
	for DataStore,Information in pairs(module.DataStores) do
		local Version = Information.Version..(Information.Reset and math.floor(os.time()/Information.Reset) or "")
		Information.DataStore = DataStoreService:GetOrderedDataStore(DataStore..Version)
	end
	
	task.spawn(function()
		while true do
			task.wait(1)
			for DataStore,Information in pairs(module.DataStores) do
				if not Information.Reset then continue end
				local Version = Information.Version..math.floor(os.time()/Information.Reset)
				Information.DataStore = DataStoreService:GetOrderedDataStore(DataStore..Version)
			end
		end
	end)
end

function module.GetRank(Leaderboard, Player)
	local LeaderboardInfo = module.DataStores[Leaderboard]
	if not LeaderboardInfo then
		return math.huge
	end

	local dataStore = LeaderboardInfo.DataStore
	local userId = Player.UserId
	local playerValue =	dataService:GetData(Player, LeaderboardInfo.path)

	-- Get the sorted data from the DataStore
	local pages = dataStore:GetSortedAsync(LeaderboardInfo.Ascending, module.Max)
	local currentPage = pages:GetCurrentPage()

	for rank, data in ipairs(currentPage) do
		if data.key == tostring(userId) then
			return tostring(rank)
		elseif (LeaderboardInfo.Ascending and data.value > playerValue) or
			(not LeaderboardInfo.Ascending and data.value < playerValue) then
			-- If we've passed where the player would be, return the current rank
			return tostring(rank)
		end
	end

	-- If the player isn't in the top 'module.Max' players, return a rank just beyond that
	return tostring(`{module.Max}+`)
end


return module