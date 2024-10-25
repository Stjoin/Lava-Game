--> Variables

local library = require(game:GetService("ReplicatedStorage").Library) 
local functions = library.Functions
local settingsConfig = library.Configurations.settings

local ardonees = script.Parent.adornees

--> Gamepass Signs

for _, sign in workspace.GamepassSigns:GetChildren() do
	local gamepassId = settingsConfig.GamePassId[sign.Name]
	
	if not gamepassId then
		warn("no gamepass found for sign")
		return
	end
	
	local gamepassInfo = library.Functions.productInfo(gamepassId, "GamePass")
	local guiClone = script.gamepassSign:Clone()
	local labels = guiClone.main.labels

	guiClone.main.gamepassImage.Image = "rbxassetid://"..gamepassInfo.IconImageAssetId
	
	labels.gamepassDescription.Text = gamepassInfo.Description
	labels.gamepassName.Text = gamepassInfo.Name
	labels.purchase.Text = `\u{E002}{gamepassInfo.PriceInRobux}`
	
	labels.purchase.MouseButton1Click:Connect(function()
		library.MarketplaceService:PromptGamePassPurchase(library.LocalPlayer, gamepassId)
	end)
	
	guiClone.Parent = ardonees
	guiClone.Adornee = sign.PrimaryPart
	
	functions.gamePassPurchase(function(player, id)
		if id == gamepassId then
			local ConfettiVFX = library.Assets.Particles.ConfettiVFX.Attachment:Clone()
			ConfettiVFX.Parent = sign.PrimaryPart
			
			functions.emitAttachment(ConfettiVFX)
			
			task.delay(3, function()
				guiClone:Destroy()
				functions.invisible(sign)
			end)
			
		end
	end)	
end

--> Donation Board

functions.tagInstanceAdded("donation_board", function(instance)
	for _,sign in instance.Signs:GetChildren() do
		local productId = settingsConfig.DevProductId[sign.Name]

		if not productId then
			warn("no gamepass found for sign")
			return
		end

		local productInfo = library.Functions.productInfo(productId, "Product")
		
		if productInfo.PriceInRobux == "nil" then continue end
		
		local guiClone = script.donationSign:Clone()
		--	guiClone.main.price.Text = `\u{E002}{functions.commas(tonumber(productInfo.PriceInRobux))}`

		guiClone.main.price.Text = ` {functions.commas(tonumber(productInfo.PriceInRobux))}`

		guiClone.main.MouseButton1Click:Connect(function()
			library.MarketplaceService:PromptProductPurchase(library.LocalPlayer, productId)
		end)

		guiClone.Parent = ardonees
		guiClone.Adornee = sign

		functions.productPurchase(function(player, id)
			if id == productId then
				local ConfettiVFX = library.Assets.Particles.ConfettiVFX.Attachment:Clone()
				ConfettiVFX.Parent = sign

				functions.emitAttachment(ConfettiVFX)		
				library.Debris:AddItem(ConfettiVFX, 3)
			end
		end)
	end
end)
