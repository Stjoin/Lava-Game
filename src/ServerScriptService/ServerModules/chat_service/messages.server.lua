--> Variables

local ChatAPI = require(script.Parent)
local Delay = 15*60
local Messages = {
	{
		Message = "[SERVER] Don't forget to 👍 Like and ⭐ Favorite the game for more updates!",
		Color = "rgb(255,170,0)",
	},
}

--> System messages

while true do
	for _,Information in pairs(Messages) do
		task.wait(Delay)
		ChatAPI.systemMessage(Information.Message, Information.Color)
	end
end

--> 