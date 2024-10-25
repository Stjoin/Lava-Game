--> Variables

local library = require(game:GetService("ReplicatedStorage").Library) 
local Players = game:GetService("Players")

local settingsConfig = library.Configurations.settings
local leaderboardsConfig = library.Configurations.leaderboards
local dataTemplateConfig = library.Configurations.data_templates
local functions = library.Functions
local DataService = library.DataService

local ChatAPI = require(library.ServerScriptService.ServerModules.chat_service)

--> Create gift

functions.playerAddedFunction(function(Player)
	functions.create("ObjectValue", Player, "Gifting")
end)

--> Change gift

library.Remotes.Gift.OnServerEvent:Connect(function(Player, Gifting)
	if Gifting then
		library.Remotes.Notify:FireClient(Player, `You are gifting now to {Gifting}!`)
	else
		library.Remotes.Notify:FireClient(Player, `You stopped gifting.`)
	end
	
	Player.Gifting.Value = Gifting
end)

--> Robux Spent

function robuxSpent(player, amount : number)
	DataService:Set(player,"RobuxSpent", "+",amount or 0)
	
	local maxValue = leaderboardsConfig.Leaderboards:WaitForChild("Robux").Value
	local difference = maxValue - DataService:GetData(player,"RobuxSpent")
	
	if difference > 0 then
		library.Remotes.Notify:FireClient(player, `Spend {functions.abbreviate(difference)} more Robux to be on the leaderobard`, "Blue")
	else	
		library.Remotes.Notify:FireClient(player, `You are now #{leaderboardsConfig.GetRank("Robux", player)} on the leaderboard!`, "Green")
	end	
end

--> Bought gamepass

function BoughtGamePass(player, gamePass)
	DataService:Set(player,`GamePasses.{gamePass}`, "=", true)

	if settingsConfig.Bundles[gamePass] then
		for _, bundleGamePass in pairs(settingsConfig.Bundles[gamePass]) do
			DataService:Set(player,`GamePasses.{bundleGamePass}`, "=", true)
		end
	end

	if gamePass:sub(1, 3) == "TO_" then
		local instanceName = gamePass:match("^TO_([^_]+)") 
		if instanceName then
			DataService:Set(player, `TimedObjects.{instanceName}.Time`, "+", -1)
		end
	end
	
	ChatAPI.updateChatTags(player)
	ChatAPI.updateChatColor(player)
end

--> Subscriptions

function UpdateSubscription(player,subscription, subscriptionsFolder)
	local Success, Result = pcall(function()
		return library.MarketplaceService:GetUserSubscriptionStatusAsync(player, settingsConfig.SubscriptionId[subscription])
	end)

	subscriptionsFolder[subscription].Value = Success and Result.IsSubscribed or false

	ChatAPI.updateChatTags(player)
	ChatAPI.updateChatColor(player)
end

Players.UserSubscriptionStatusChanged:Connect(function(Player, SubscriptionId)
	for Id,Subscription in pairs(settingsConfig.Subscriptions) do
		if Id ~= SubscriptionId then continue end
		UpdateSubscription(Player, settingsConfig.Subscriptions[SubscriptionId])
	end
end)

--> Website purchases

functions.playerAddedFunction(function(Player)
	local gamePassesFolder = functions.create("Folder", Player, "GamePasses")

	--[[for id,gamePassName in settingsConfig.GamePasses do
		functions.create("BoolValue", gamePassesFolder, gamePassName)

		local Success, Owned = pcall(function()
			return library.MarketplaceService:UserOwnsGamePassAsync(Player.UserId, id)
		end)
		if Success and Owned then
			--BoughtGamePass(Player, gamePassName,gamePassesFolder)
		end
	end--]]

	local subscriptionsFolder = functions.create("Folder", Player, "Subscriptions")	
	for _,Subscription in settingsConfig.Subscriptions do
		functions.create("BoolValue", subscriptionsFolder, Subscription)

		UpdateSubscription(Player,Subscription.Name,subscriptionsFolder)
	end
end)

--> GamePasses

functions.gamePassPurchase(function(Player, Id)
	local GamePass = settingsConfig.GamePasses[Id]

	if GamePass then
		robuxSpent(Player,tonumber(functions.productInfo(Id,"GamePass").PriceInRobux))

		BoughtGamePass(Player, GamePass)	
		
		ChatAPI.systemMessage("A player bought "..GamePass.."!", "rgb(0,255,0)")
	end
end)

--> Products

functions.productPurchase(function(Player, Id, From)
	local Product = settingsConfig.DevProducts[Id]
	if not Product then return end
	local GamePass = settingsConfig.DevProducts[Id]:match("^Gift(.+)")

	local chatAnnouncement = true
	
 	if GamePass then
		BoughtGamePass(Player, GamePass)
	elseif settingsConfig.Currency[Product] then
		chatAnnouncement = false
		
		local currencyConfig = settingsConfig.Currency[Product]
		DataService:Set(Player, currencyConfig.path, "+", currencyConfig.amount)
	elseif settingsConfig.Potions[Product] then
		DataService:Set(Player, `Potions.{settingsConfig.Potions[Product]}.Uses`, "+", 1)
	elseif settingsConfig.PotionBundles[Product] then
		for Potion, Amount in pairs(settingsConfig.PotionBundles[Product]) do
			DataService:Set(Player, `Potions.{Potion}.Uses`, "+", Amount)
		end
		
		if Product == "StarterPack" then
			DataService:Set(Player, "Cash", "+", 1000)
		end
	end
	
	if chatAnnouncement then
		if From ~= Player then
			ChatAPI.systemMessage(From.Name.." bought "..(GamePass or Product).." for "..Player.Name.."!", "rgb(0,255,0)")
		else
			ChatAPI.systemMessage("A player bought "..(GamePass or Product).."!", "rgb(0,255,0)")
		end
	end


	robuxSpent(Player,tonumber(functions.productInfo(Id,"Product").PriceInRobux))
end)

--> Potions

library.Remotes.UsePotion.OnServerEvent:Connect(function(Player, Potion)
	if DataService:GetData(Player, `Potions.{Potion}.Uses`) < 1 then return end
	DataService:Set(Player, `Potions.{Potion}.Uses`, "-", 1)
	DataService:Set(Player, `Potions.{Potion}.Time`, "+", settingsConfig.PotionDurations[Potion])
end)

--> 
