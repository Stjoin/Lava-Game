--> Variables

local library = require(game:GetService("ReplicatedStorage").Library) 

--> Chat tags

library.TextChatService.OnIncomingMessage = function(Message)
	if not Message.TextSource then return end
	
	local Player = library.Players:GetPlayerByUserId(Message.TextSource.UserId)
	local Properties = Instance.new("TextChatMessageProperties")
	local Text = ""
	
	local ChatColor = Player:FindFirstChild("ChatColor")
	Text = ChatColor and ChatColor.Value:format(Message.PrefixText) or ""
	
	local ChatTags = Player:FindFirstChild("ChatTags")
	Text = (ChatTags and ChatTags.Value or "")..Text
	
	Properties.PrefixText = Text
	return Properties
end

--> System messages

library.Remotes.Chat.OnClientEvent:Connect(function(Message)
	library.TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(Message)
end)

--> 