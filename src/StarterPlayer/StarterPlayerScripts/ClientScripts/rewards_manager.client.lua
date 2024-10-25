--> Variables

local library = require(game:GetService("ReplicatedStorage").Library)
local functions = library.Functions
local uiFunctions = library.UIFunctions
local dataService = library.DataService
local rewardsConfig = library.Configurations.rewards

local player = library.LocalPlayer

--> Daily rewards
local DailyRewards = library.Frames.DailyRewards.Rewards

function UpdateDailyRewards()
	local dailyRewardsData = dataService:GetData(player, "DailyRewards")
	local firstJoin = dataService:GetData(player, "FirstJoin")
	local loginStreak = dataService:GetData(player, "LoginStreak")
	
	local Ready = 0
	
	for Day,Reward in pairs(rewardsConfig.DailyRewards) do
		local Frame = DailyRewards:FindFirstChild(Day, true)
		if not Frame then continue end

		local Claimed = dailyRewardsData[tostring(Day)]
		local Today = math.floor(functions.timePassed(firstJoin) / 86400)
		local TimeLeft = (Today + (Day -loginStreak)) * 86400 - functions.timePassed(firstJoin)
		Ready += (not Claimed and TimeLeft < 1) and 1 or 0
		
		if Claimed or TimeLeft < 1 then
			Frame.claim.Visible = true
			Frame.timer.Visible = false
			
			Frame.UIStroke.Color = Color3.fromRGB(252, 0, 206)
		else
			Frame.claim.Visible = false
			Frame.timer.Visible = true
			Frame.BackgroundColor3 = Color3.fromRGB(255, 224, 253)
		end
		
		if Claimed then
			Frame.claim.Text = "CLAIMED!"
			Frame.claim.TextColor3 = Color3.fromRGB(223, 148, 255)
			Frame.BackgroundColor3 = Color3.fromRGB(255, 151, 232)
		elseif  TimeLeft < 1 then
			Frame.claim.Text = "CLAIM!"
			Frame.claim.TextColor3 = Color3.fromRGB(255, 184, 238)
			Frame.BackgroundColor3 = Color3.fromRGB(255, 224, 253)
		elseif TimeLeft < 86400 then
			Frame.timer.Text = functions.timer(TimeLeft)
		else
			--Frame.timer.Visible = false
			Frame.timer.Text =  ((Day-loginStreak).." days")
		end
	end
	--Main.Left.C.Daily.Notification.Visible = Ready > 0
end

dataService:GetDataAsync(player):await()

for Day,Reward in pairs(rewardsConfig.DailyRewards) do
	local Frame = DailyRewards:FindFirstChild(Day, true)
	if not Frame then continue end
	Frame.MouseButton1Down:Connect(function()
		if not dataService:GetData(player, `DailyRewards.{Frame.Name}`) then
			local claimReward = library.Remotes.ClaimDailyReward:InvokeServer(Day)

			if claimReward then
				uiFunctions.Audio("Reward")
				uiFunctions.Notify(claimReward)	
			end
		end
	end)
	
	dataService:ConnectToSignal(player, `DailyRewards.{Day}`, UpdateDailyRewards)
end

dataService:ConnectToSignal(player, `PlayTime`, UpdateDailyRewards)

--> 