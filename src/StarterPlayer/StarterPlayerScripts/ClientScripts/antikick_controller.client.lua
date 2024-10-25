--> Variables
local library = require(game:GetService("ReplicatedStorage").Library) 

local MinimumTimeForKick = 1100
local LastInput = os.time()

--> Live
library.UserInputService.InputBegan:Connect(function()
	LastInput = os.time()
end)

task.spawn(function()
	while wait(1) do
		if os.time() - LastInput > MinimumTimeForKick then
			library.TeleportService:Teleport(game.GameId)
		end
	end
end)

-->