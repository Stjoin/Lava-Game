--> Variables
local library = require(game:GetService("ReplicatedStorage").Library) 
local dataService = library.DataService

local functions = library.Functions
local uiFunctions = library.UIFunctions
local player = library.LocalPlayer
local gifting = player:WaitForChild("Gifting")

local settingsConfig = library.Configurations.settings

local main = library.Main

local Store = library.Frames.Shop
local shop = Store.ScrollingFrame
local playerList = library.Frames.PlayerList.ScrollingFrame

--> GamePasses/Product prompts and prices
dataService:GetDataAsync():await()

for _, categorie in shop:GetChildren() do
	if not categorie:IsA("Frame") then
		continue 
	end

	for _, child in categorie:GetChildren() do
		if not child:IsA("Frame") then
			continue
		end

		for _, purchasable in child:GetChildren() do	
			if not purchasable:IsA("GuiObject") then continue end
			local GamePass = settingsConfig.GamePassId[purchasable.Name]
			local Product = settingsConfig.DevProductId["Gift"..purchasable.Name] or settingsConfig.DevProductId[purchasable.Name]

			if GamePass or Product then
				local buyButton = purchasable:IsA("ImageButton") and purchasable or purchasable.transFrame.purchase

				buyButton.MouseButton1Down:Connect(function()
					local Recipient = gifting.Value or player

					local owned = GamePass and functions.hasPass(purchasable.Name, Recipient)

					if owned then uiFunctions.Notify("Already owned", "Red", 2) return end

					local GiftID = Recipient == player and GamePass or Product
					uiFunctions.PromptPurchase(GiftID, (GamePass and GiftID == GamePass) and "GamePass" or "Product")
				end)

				local Potion = settingsConfig.Potions[purchasable.Name]
				if Potion then
					purchasable.transFrame.use.MouseButton1Down:Connect(function()
						library.Remotes.UsePotion:FireServer(Potion)
					end)

					task.spawn(function()

						dataService:ConnectToSignal(player, `Potions.{Potion}.Uses`, function(new_value)
							purchasable.transFrame.use.Visible = new_value > 0
							purchasable.transFrame.use.amount.Text = `Use ({new_value})`						
						end)	
					end)							
				end

				task.spawn(function()
					local Info = functions.productInfo(GamePass or Product, GamePass and "GamePass" or "Product")
					local priceLabel = purchasable.transFrame:FindFirstChild("purchase") and purchasable.transFrame.purchase.price or purchasable.transFrame.price


					priceLabel.Text = " "..Info.PriceInRobux
				end)
			end

		end
	end

end


function UpdateStore()
	local Recipient = gifting.Value or player

	for _, categorie in shop:GetChildren() do
		for _, child in categorie:GetChildren() do	
			if not child:IsA("Frame") then continue end

			for _, purchasable in child:GetChildren() do
				if not purchasable:IsA("GuiObject") then continue end

				local gamePass = settingsConfig.GamePassId[purchasable.Name]

				if not gamePass then continue end

				local priceLabel = purchasable.transFrame:FindFirstChild("purchase") and purchasable.transFrame.purchase.price or purchasable.transFrame.price
				local found = functions.hasPass(purchasable.Name, Recipient)

				if found then
					priceLabel.Text = "Owned"
				else
					task.spawn(function()
						local Info = functions.productInfo(gamePass,"GamePass")
						priceLabel.Text = " "..Info.PriceInRobux
					end)				
				end
			end
		end
	end
end

--> Scroll buttons

local Tween

function ScrollTo(Target)
	local Target = shop[Target].AbsolutePosition + shop.CanvasPosition - shop.AbsolutePosition
	Tween = library.TweenService:Create(shop, TweenInfo.new(0.4, Enum.EasingStyle.Back), {CanvasPosition = Vector2.new(0,Target.Y)})
	Tween:Play()
end

function CancelTween(Input)
	if not Tween or (Input and Input.UserInputType ~= Enum.UserInputType.MouseWheel and Input.UserInputType ~= Enum.UserInputType.Touch) then return end
	Tween:Cancel()
	Tween = nil
end

for _,Button in pairs(Store.Buttons:GetChildren()) do
	if not Button:IsA("GuiObject") then continue end
	Button.MouseButton1Down:Connect(function()
		CancelTween()
		ScrollTo(Button.Name)
	end)
end

library.UserInputService.InputChanged:Connect(CancelTween)

functions.setCanvasSize(shop, Vector2.new(0,shop.UIListLayout.AbsoluteContentSize.Y))
shop.CanvasPosition = Vector2.new(0,0)

--> gifting

PlayerSample = playerList.Sample:Clone()
playerList.Sample:Destroy()

functions.playerAddedFunction(function(Recipient)
	if Recipient == player then return end
	local NewSample = PlayerSample:Clone()
	NewSample.Headshot.Image = functions.headshotAsync(Recipient.UserId)
	NewSample.DisplayName.Text = Recipient.DisplayName
	NewSample.PlayerName.Text = "@"..Recipient.Name
	NewSample.Parent = playerList

	functions.setCanvasSize(playerList, Vector2.new(0,playerList.UIListLayout.AbsoluteContentSize.Y))

	functions.onDestroy(Recipient, function()
		NewSample:Destroy()
		functions.setCanvasSize(playerList, Vector2.new(0,playerList.UIListLayout.AbsoluteContentSize.Y))
	end)

	uiFunctions.ConnectButtonToFrame(NewSample, Store)
	NewSample.MouseButton1Down:Connect(function()
		library.Remotes.Gift:FireServer(Recipient)
	end)
end)

functions.setCanvasSize(playerList, Vector2.new(0,playerList.UIListLayout.AbsoluteContentSize.Y))
--]]
local Connections = {}

functions.changed(gifting, function()
	local Recipient = gifting.Value
	Store.Gift.Visible = not Recipient
	Store.Gifting.Frame.TextLabel.Text = "Currently gifting to: "..(Recipient and Recipient.Name or "")
	Store.Gifting.Visible = Recipient
	Store.Cancel.Visible = Recipient

	for _, Connection in pairs(Connections) do
		Connection:Disconnect()
	end
	table.clear(Connections)

	local target = Recipient or player
	dataService:GetDataAsync(target)
		:andThen(function(profileData)
			if not profileData then
				error("Profile data is nil")
			end
			return profileData.GamePasses
		end)
		:andThen(function(GamePasses)
			for GamePassName, _ in pairs(GamePasses) do
				table.insert(Connections, dataService.clientReplica:ListenToChange("GamePasses." .. GamePassName, UpdateStore))
			end
			UpdateStore()
		end)
		:catch(function(err)
			warn("Error in gifting process: " .. tostring(err))
		end)
end)

uiFunctions.ConnectButtonToFrame(main.Top.CashIndicator.Purchase, Store)
functions.onTrigger(main.Top.CashIndicator.Purchase, "PressDown", function()
	ScrollTo("Cash")
end)

uiFunctions.ConnectButtonToFrame(Store.Gift, library.Frames.PlayerList)
uiFunctions.ConnectButtonToFrame(library.Frames.PlayerList.Back, Store)

Store.Cancel.MouseButton1Down:Connect(function()
	library.Remotes.Gift:FireServer()
end)

--> Potions

for _,Potion in pairs(settingsConfig.Potions) do

	local Frame = library.Main.Potions:FindFirstChild(Potion)
	if not Frame then continue end
	uiFunctions.CreateTooltip(Frame, Potion.." Potion")
end

task.spawn(function()
	while true do
		task.wait(1)
		for Potion,info in dataService:GetData(player, `Potions`) do
			local Frame = library.Main.Potions:FindFirstChild(Potion)
			if not Frame then continue end
			Frame.Visible = info.Time > 0
			Frame.Timer.Text = functions.timer(info.Time)
		end
	end
end)

--> --]]