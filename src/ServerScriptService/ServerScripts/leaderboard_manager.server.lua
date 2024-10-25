-----< Variables

local library = require(game:GetService("ReplicatedStorage").Library) 
local runService= library.RunService
local players = library.Players

local leaderboardConfig = library.Configurations.leaderboards

local functions = library.Functions
local dataService = library.DataService
local chatAPI = require(library.ServerModules.chat_service)

local UsernameCache = {}
local CACHE_EXPIRY_TIME = 3600  -- 1 hour

-----< Functions

function Format(Leaderboard, number)
	return Leaderboard.Format(number)
end

function GetUsernameFromUserId(userId)
	local currentTime = os.time()
	local cacheEntry = UsernameCache[userId]

	if cacheEntry and (currentTime - cacheEntry.timestamp) < CACHE_EXPIRY_TIME then
		return cacheEntry.username
	else
		local success, username = pcall(function()
			return players:GetNameFromUserIdAsync(userId)
		end)
		if success then
			UsernameCache[userId] = {
				username = username,
				timestamp = currentTime
			}
			return username
		else
			return "Unknown"
		end
	end
end

function SaveStats(Player, playerData)
	local Key = Player.UserId
	for _, Data in pairs(leaderboardConfig.DataStores) do
		local path = Data.path
		local number = playerData and playerData[path] or dataService:GetData(Player, path)

		if not number then 
			continue
		end

		functions.attemptPcall(3, 5, function()
			Data.DataStore:SetAsync(Key, math.round(number))
		end)
	end
end

-----< Leaderboards

local Podiums = workspace:FindFirstChild("LeaderboardPodiums")

if Podiums then
	for _, Podium in pairs(Podiums:GetChildren()) do
		for _, Rig in pairs(Podium:GetChildren()) do
			local Animation = Rig:FindFirstChildOfClass("Animation")
			if Animation then
				Rig:WaitForChild("Humanoid"):WaitForChild("Animator"):LoadAnimation(Animation):Play()
			end
		end
	end
end

for Leaderboard, Information in pairs(leaderboardConfig.DataStores) do
	Leaderboard = functions.create("NumberValue", leaderboardConfig.Leaderboards, Leaderboard)
	for Rank = 1, leaderboardConfig.Max do
		local RankString = functions.create("StringValue", Leaderboard, Rank, leaderboardConfig.EmptyCell)
		functions.create("StringValue", RankString, "Text", Format(Information, 0))
	end
end

function UpdateLeaderboard(Leaderboard, Board, Page, Max)
	local Podium = Podiums and Podiums:FindFirstChild(Board.Name)

	for Rank = 1, Max do
		local Data = Page[Rank]
		local UserId = Data and Data.key
		local number = Data and Data.value or 0

		local Username = "Loading..."
		if UserId then
			Username = GetUsernameFromUserId(UserId)
		end

		Board[Rank].Value = Username
		Board[Rank].Text.Value = Format(Leaderboard, number)

		local Rig = Podium and Podium:FindFirstChild(Rank)
		if Rig and UserId then
			local success, description = pcall(function()
				return players:GetHumanoidDescriptionFromUserId(UserId)
			end)
			if success then
				Rig:WaitForChild("Humanoid"):ApplyDescription(description)
			end
		end

		if Rank == Max then
			return number
		end
	end
end

task.spawn(function()
	while true do
		for _, Player in pairs(players:GetPlayers()) do
			SaveStats(Player)
		end
		for Leaderboard, Information in pairs(leaderboardConfig.DataStores) do
			local Pages = Information.DataStore:GetSortedAsync(Information.Ascending, leaderboardConfig.Max)
			local Page = Pages:GetCurrentPage()
			leaderboardConfig.Leaderboards[Leaderboard].Value = UpdateLeaderboard(Information, leaderboardConfig.Leaderboards[Leaderboard], Page, leaderboardConfig.Max)
		end
		for _, Player in pairs(players:GetPlayers()) do
			chatAPI.updateChatTags(Player)
			chatAPI.updateChatColor(Player)
		end
		task.wait(leaderboardConfig.Refresh)
	end
end)

-----< Saving

library.Bindables.PlayerLeaving.Event:Connect(function(player, playerData)
	SaveStats(player, playerData)
end)

game:BindToClose(function()
	for _, Player in pairs(players:GetPlayers()) do
		SaveStats(Player)
	end
end)

-----< Server leaderboards

for Leaderboard, Information in pairs(leaderboardConfig.ServerLeaderboards) do
	Leaderboard = functions.create("NumberValue", leaderboardConfig.Leaderboards, Leaderboard)
	for Rank = 1, players.MaxPlayers do
		local RankString = functions.create("StringValue", Leaderboard, Rank, leaderboardConfig.EmptyCell)
		functions.create("StringValue", RankString, "Text", Format(Information, 0))
	end
end

task.spawn(function()
	while true do
		for DataStore, Information in pairs(leaderboardConfig.ServerLeaderboards) do
			local Leaderboard = leaderboardConfig.Leaderboards[DataStore]
			local Sorted = {}

			for _, Player in pairs(players:GetPlayers()) do
				if not Player:FindFirstChild("Data") then continue end
				local Number = Information.Function(Player)
				table.insert(Sorted, {key = Player.UserId, value = Number})
			end

			table.sort(Sorted, function(A, B)
				return Information.Ascending and A.value < B.value or A.value > B.value
			end)

			Leaderboard.Value = os.time() + leaderboardConfig.ServerRefresh
			UpdateLeaderboard(Information, Leaderboard, Sorted, players.MaxPlayers)
		end
		for _, Player in pairs(players:GetPlayers()) do
			chatAPI.updateChatTags(Player)
			chatAPI.updateChatColor(Player)
		end
		task.wait(leaderboardConfig.ServerRefresh)
	end
end)

task.spawn(function()
	while true do
		task.wait(600)
		local currentTime = os.time()
		for userId, cacheEntry in pairs(UsernameCache) do
			if (currentTime - cacheEntry.timestamp) >= CACHE_EXPIRY_TIME then
				UsernameCache[userId] = nil
			end
		end
	end
end)

-----< Physical leaderboards
for _, Leaderboard in pairs(library.CollectionService:GetTagged("Leaderboard")) do
	local Sample = Leaderboard:FindFirstChild("Sample", true)
	local Parent = Sample.Parent
	Sample = Sample:Clone()
	Leaderboard:FindFirstChild("Sample", true):Destroy()

	local childAddedConnection 
	
	local function childAdded(Rank)
		if not Leaderboard.Parent then
			childAddedConnection:Disconnect()
			return
		end
		local NewSample = Sample:Clone()
		NewSample.Rank.Text = "#" .. Rank.Name
		NewSample.Parent = Parent
		functions.setCanvasSize(Parent, Vector2.new(0, Parent.UIListLayout.AbsoluteContentSize.Y + 20))

		local function UpdateUI()
			local Success, UserId = pcall(function() return players:GetUserIdFromNameAsync(Rank.Value) end)
			NewSample.Headshot.Image = functions.headshotAsync(Success and UserId or 1)
			NewSample.Value.Text = Rank.Text.Value
			NewSample.Username.Text = Rank.Value
		end

		functions.changed(Rank, UpdateUI)
		functions.changed(Rank.Text, UpdateUI)
	end
	
	childAddedConnection = leaderboardConfig.Leaderboards[Leaderboard.Name].ChildAdded:Connect(function(Rank)
		childAdded(Rank)
	end)
	
	for _, rank in leaderboardConfig.Leaderboards[Leaderboard.Name]:GetChildren() do
		childAdded(rank)
		library.RunService.Heartbeat:Wait()
	end
end

-----<
