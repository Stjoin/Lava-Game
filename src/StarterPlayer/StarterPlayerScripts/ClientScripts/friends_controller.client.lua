--> Variables

local library = require(game:GetService("ReplicatedStorage").Library) 
local functions = library.Functions
local settingsConfig = library.Configurations.settings

--> Live

library.StarterGui:GetCore("PlayerFriendedEvent").Event:Connect(function(Player)
	library.Remotes.FriendsUpdated:FireServer(Player)
end)

library.StarterGui:GetCore("PlayerUnfriendedEvent").Event:Connect(function(Player)
	library.Remotes.FriendsUpdated:FireServer(Player)
end)


--> Friend Boost
local friendsFolder = functions.findFirstChildWithTimeout(library.LocalPlayer, "Friends")

functions.childAdded(friendsFolder, function()
	library.PlayerGui.main.Boosts.Friends.Boost.Text = `+{#friendsFolder:GetChildren()*settingsConfig.BoostPerFriend}%`
end)

--> Premium Boost
local premiumValue = functions.findFirstChildWithTimeout(library.LocalPlayer, "Premium")

functions.changed(premiumValue, function(value)
	library.PlayerGui.main.Boosts.Premium.Boost.Text = `+{value and settingsConfig.PremiumBoost or 0}%`
end)

--> 