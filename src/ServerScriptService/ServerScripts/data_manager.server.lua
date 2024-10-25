--> Variables

local library = require(game:GetService("ReplicatedStorage").Library) 
local Players = game:GetService("Players")

local serverModules = library.ServerScriptService.ServerModules
local configurations = library.Configurations

local rewardsConfig = configurations.rewards
local gameplayConfig = configurations.gameplay
local settingsConfig = configurations.settings
local dataTemplatesConfig = configurations.data_templates
local decorationConfig = configurations.decoration
local tycoonConfig = configurations.tycoon
local petsConfig = configurations.pets
local upgradesConfig = library.Configurations.upgrades
local timedObjectsConfig = library.Configurations.timed_objects
local rebirthConfig = configurations.rebirth

local functions = library.Functions
local DataService = library.DataService

local ProfileService = require(library.ServerPackages.profile_service)
local ReplicaService = require(library.ServerPackages.replica_service)
local BadgeAPI = require(serverModules.badge_service)
local ChatAPI = require(serverModules.chat_service)

--> Config
dataTemplatesConfig.setConfig({
	MaxStorage = petsConfig.Storage,
	MaxEquipped = petsConfig.Equipped
})

--> Automate

--Decoration
for Index,_ in rewardsConfig.DailyRewards do
	dataTemplatesConfig.playerProfile.DailyRewards[tostring(Index)] = false
end

for Name,Information in dataTemplatesConfig.mirroring do
	Information.Parent[Name] = 0
	if not Information.Reset then continue end
	Information.Parent[Name.."Version"] = 0
end

for _,GamePass in settingsConfig.GamePasses do
	dataTemplatesConfig.playerProfile.GamePasses[GamePass] = false
end

for _,Subscription in settingsConfig.Subscriptions do
	dataTemplatesConfig.playerProfile.Subscriptions[Subscription] = false
end

for Badge,_ in BadgeAPI.Badges do
	dataTemplatesConfig.playerProfile.Badges[Badge] = false
end

for Potion,_ in settingsConfig.PotionDurations do
	dataTemplatesConfig.playerProfile.Potions[Potion] = {Uses = 0, Time = 0}
end

--> Profile Store

local ProfileStore = ProfileService.GetProfileStore(
	"PlayerData1",
	library.Configurations.data_templates.playerProfile
)

local Profiles = {}

--> Starter Gui
local StarterGuis = {}

library.StarterGui.ScreenOrientation = settingsConfig.ScreenOrientation

for _,Gui in pairs(library.StarterGui:GetChildren()) do
	if Gui.Name == "loading_screen" then
		Gui.Enabled = true
		Gui.Progress.TextTransparency = 1
		Gui.Skip.Label.TextTransparency = 1
		Gui.Skip.BackgroundTransparency = 1
		Gui.Icon.ImageTransparency = 1
	end
	Gui:SetAttribute("StarterGui", true)
	table.insert(StarterGuis, Gui:Clone())
	Gui.Parent = script
end

--> Collision Groups
library.PhysicsService:RegisterCollisionGroup("Players")
library.PhysicsService:CollisionGroupSetCollidable("Players", "Players", settingsConfig.PlayersCanCollide)

--> Functions
	
function CharacterAdded(Character)
	
	local Player = Players:GetPlayerFromCharacter(Character)
	
	if not Player:HasAppearanceLoaded() then
		Player.CharacterAppearanceLoaded:Wait()
	end
	
	for _,Descendant in pairs(Character:GetDescendants()) do
		if not Descendant:IsA("BasePart") then continue end
		Descendant.CollisionGroup = "Players"
	end
end

--> Datastore

functions.playerAddedFunction(function(Player)
	local PlayerGui = Player:WaitForChild("PlayerGui")

	for _,Gui in pairs(StarterGuis) do
		Gui:Clone().Parent = PlayerGui
	end
	
	ChatAPI.systemMessage(Player.Name.." has joined the game!", "rgb(180,180,180)")	
	local Profile = ProfileStore:LoadProfileAsync("Player_" .. Player.UserId)
	
	if Profile ~= nil then
		Profile:AddUserId(Player.UserId)
		Profile:Reconcile()
		Profile:ListenToRelease(function()
			DataService:DeleteProfile(Player)
			Profiles[Player] = nil
			Player:Kick()
		end)
		if Player:IsDescendantOf(Players) then
			Profiles[Player] = Profile
				
			DataService:NewRepliProfile(Player,Profile)
			local Data = Profile.Data
			Data.Joins += 1
			
			if Data.Joins == 1 then
				Data.FirstJoin = os.time()
			end
			
			Data.LastPlaceVersion = game.PlaceVersion
		else
			Profile:Release()
			Player:Kick()
			return
		end
	else
		Player:Kick()
		return
	end
	
	task.spawn(function()
		while task.wait(2) do
			print(DataService.dataSets[Player].Profile.Data)
			DataService:Set(Player,"Coins","+", 1)
		end
	end)
	
	functions.characterAddedFunction(Player, CharacterAdded)
	
	task.spawn(function()
		local Success, InGroup = pcall(function()
			return Player:IsInGroup(settingsConfig.GroupId)
		end)
		local Success, GroupRank = pcall(function()
			return Player:GetRankInGroup(settingsConfig.GroupId)
		end)
		functions.create("BoolValue", Player, "Group", InGroup)
		functions.create("IntValue", Player, "GroupRank", GroupRank)
	end)
	
	functions.create("BoolValue", Player, "Premium", Player.MembershipType == Enum.MembershipType.Premium)
	
	local Leaderstats = functions.create("Folder", Player, "leaderstats")
	
	for _,Info in pairs(dataTemplatesConfig.leaderstatsTemplate) do
		DataService:CreateSignal(Player, Info.dataName)

		local NewValue = functions.create("NumberValue", Leaderstats, Info.displayName)

		NewValue.Value = DataService:GetData(Player, Info.dataName)
		DataService:ConnectToSignal(Player, Info.dataName, function(Returned)
			NewValue.Value = Returned
		end)
	end

	
	
	for Name,Information in pairs(dataTemplatesConfig.mirroring) do
		DataService:CreateSignal(Player, Information.Mirror)

		local LastValue = DataService:GetData(Player,"Cash")

		DataService:ConnectToSignal(Player, Information.Mirror, function(Returned)
			if Returned > LastValue then
				DataService:Set(Player,Name, "+",Returned - LastValue)
			end
			LastValue = Returned
		end)
	end
	
	task.spawn(function()	
		BadgeAPI.AwardBadge(Player, "Welcome")
		
		for Badge,UserIds in pairs(BadgeAPI.Meet) do
			for _,UserId in pairs(UserIds) do
				local Found = false
				if Player.UserId == UserId then
					Found = true
					for _,Player in pairs(Players:GetPlayers()) do
						BadgeAPI.AwardBadge(Player, Badge)
					end
				else
					for _,Player in pairs(Players:GetPlayers()) do
						if Player.UserId ~= UserId then continue end
						Found = true
					end
				end

				if Found then
					BadgeAPI.AwardBadge(Player, Badge)
					break
				end
			end
		end
	end)
	
	task.spawn(function()
		while Player.Parent do
			DataService:Set(Player, "SessionPlayTime", "+", 1)
			DataService:Set(Player, "PlayTime", "+", 1)
			
			for Name, Information in pairs(dataTemplatesConfig.mirroring) do
				if not Information.Reset then continue end
				if DataService:GetData(Player, Name.."Version") == math.floor(os.time() / Information.Reset) then continue end
				DataService:Set(Player, Name.."Version", "=", math.floor(os.time() / Information.Reset))
				DataService:Set(Player, Name, "=", 0)
			end

			for name, Potion in pairs(DataService:GetData(Player,"Potions")) do
				if Potion.Time < 1 then continue end
				DataService:Set(Player, "Potions."..name..".Time", "-", 1)
			end

			local Date = math.floor(functions.timePassed(DataService:GetData(Player, "FirstJoin")) / 86400)
			local LastJoined = DataService:GetData(Player, "LastJoined")
			
			if LastJoined ~= Date then
				DataService:Set(Player, "LoginStreak", "=", ((Date - 1) == LastJoined and DataService:GetData(Player, "LoginStreak") + 1) or 1)
				DataService:Set(Player, "LastJoined", "=", Date)
				if (Date - 1) ~= LastJoined then
					for DailyReward, _ in pairs(DataService:GetData(Player,"DailyRewards")) do
						DataService:Set(Player, "DailyRewards."..DailyReward, "=", false)
					end
				end
			end
			
			task.wait(1)
		end
	end)
	
	ChatAPI.updateChatTags(Player)
	ChatAPI.updateChatColor(Player)
	ChatAPI.chatted(Player)
end)

functions.playerRemovingFunction(function(Player)
	local Profile = Profiles[Player]
	
	if Profile ~= nil then
		DataService:Set(Player, "LastLeft", "=",os.time())

		Profile:Release()
	end
end)

--> 