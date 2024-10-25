--> Variables

local library = require(game:GetService("ReplicatedStorage").Library) 

local remotes = library.Remotes

local settingsConfig = library.Configurations.settings
local functions = library.Functions

local tags = require(script.tags)
local colors = require(script.colors)
local commands = require(script.commands)

local owns = settingsConfig.Owns
local format = "<font color='%s'>%s</font>"
local prefix = "/"

local module = {}

for command,_ in pairs(commands) do
	if library.TextChatService:FindFirstChild(command) then continue end
	functions.create("TextChatCommand", library.TextChatService, command).PrimaryAlias = prefix..command
end

--> Functions

function module.updateChatTags(player)
	functions.attemptPcall(5, 1, function()
		local ownedTags = {}
		local columns = {}
		
		for index,tag in pairs(tags) do
			local columnTag = ownedTags[tag.Column]
			if columnTag and tag.Priority < tags[columnTag].Priority then continue end
			if owns(player, tag) then
				if not table.find(columns, tag.Column) then
					table.insert(columns, tag.Column)
				end
				ownedTags[tag.Column] = index
			end
		end
		
		table.sort(columns, function(A,B) return A < B end)
		local tagString = ""
		
		for _,column in pairs(columns) do
			local tag = ownedTags[column]
			tagString = tagString..format:format(tags[tag].TagColor, tags[tag].TagText).." "
		end
		
		local chatTags = player:FindFirstChild("ChatTags") or functions.create("StringValue", player, "ChatTags")
		chatTags.Value = tagString
	end)
end

function module.updateChatColor(player)
	functions.attemptPcall(5, 1, function()
		local color, priority
		
		for _,tag in pairs(colors) do
			if priority and tag.Priority < priority then continue end
			
			if owns(player, tag) then
				color, priority = tag.Color, tag.Priority
			end
		end
		
		local chatColor = player:FindFirstChild("ChatColor") or functions.create("StringValue", player, "ChatColor")
		chatColor.Value = color and format:format(color, "%s") or "%s"
	end)
end

function module.systemMessage(message, color)
	
	color = color or "#ffffff"
	remotes.Chat:FireAllClients(format:format(color, message))
end

function module.localSystemMessage(player, message, color)
	color = color or "#ffffff"
	remotes.Chat:FireClient(player, format:format(color, message))
end

function module.chatted(player)
	player.Chatted:Connect(function(message)
		message = message:match("^"..prefix.."(.+)") or ""
		message = message:gsub("%s+", " "):split(" ")
		
		local command = commands[message[1]]
		if not command then return end
		if not owns(player, command) then
			module.localSystemMessage(player, "You do not have permission to run this command.", "#ff0000")
			return
		end
		local responseType, response, color = command.Function(player, message)

		if response then
			if responseType == "Local" then
				module.localSystemMessage(player, response, color)
			else
				module.systemMessage(response, color)
			end
		end
	end)
end

return module