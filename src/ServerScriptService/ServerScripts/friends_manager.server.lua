--> Variables

local library = require(game:GetService("ReplicatedStorage").Library) 
local functions = library.Functions

--> Join

functions.playerAddedFunction(function(Player)
	local Friends = functions.create("Folder", Player, "Friends")

	for _,Other in pairs(library.Players:GetPlayers()) do
		if not Player.Parent then return end
		local Success, Result = pcall(function()
			return Player:IsFriendsWith(Other.UserId)
		end)

		if Success and Result then
			functions.create("StringValue", Other:WaitForChild("Friends"), Player.Name)
			functions.create("StringValue", Friends, Other.Name)
		end
	end
end)

--> Leave

functions.playerRemovingFunction(function(Player)
	for _,Other in pairs(library.Players:GetPlayers()) do
		if Other:WaitForChild("Friends"):FindFirstChild(Player.Name) then
			Other.Friends[Player.Name]:Destroy()
		end
	end
end)

--> Live

library.Remotes.FriendsUpdated.OnServerEvent:Connect(function(Player, Other)
	functions.attemptPcall(5, 2, function()
		local IsFriends = Player:IsFriendsWith(Other.UserId)
		if Player:FindFirstChild("Friends") then
			local Friended = Player.Friends:FindFirstChild(Other.Name)
			if Friended and not IsFriends then
				Friended:Destroy()
			elseif not Friended and IsFriends then
				functions.create("StringValue", Player.Friends, Other.Name)
			end
		end
		if Other:FindFirstChild("Friends") then
			local Friended = Other.Friends:FindFirstChild(Player.Name)
			if Friended and not IsFriends then
				Friended:Destroy()
			elseif not Friended and IsFriends then
				functions.create("StringValue", Other.Friends, Player.Name)
			end
		end
	end)
end)

--> 