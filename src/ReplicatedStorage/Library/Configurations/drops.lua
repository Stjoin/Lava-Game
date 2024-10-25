local module = {}

module.DropAmount = 2

module.MinimumSpawnTime = 0.01
module.MaximumSpawnTime = 0.05
module.PickUpMagnitude = 11
module.PickUpRadius = 40
module.MaxDrops = 80

module.DropSFX = script.DropSFX
module.Pickup = script.Pickup

module.Drops = {
	["Cash"] = {
		Drop = script.Drop,
		Chance = 100,
		Currency = "Cash",
		Height = 0,
		Color = Color3.fromRGB(21,255,48)
	},
	["Gold"] = {
		Drop = script.Gold,
		Chance = 0,
		Currency = "Cash",
		Height = 0,
		Color = Color3.fromRGB(21,255,48)
	},
}

local itemList = require(script.Parent.items)
local settingsConfig = require(script.Parent.settings)

function module.DropValue(Player, Drop, Item)
	local dropInfo = module.Drops[Drop]
	local itemValue = itemList.Items[Item].Value

	local cashMultiplier = settingsConfig.Multiplier(Player, "Cash")

	local totalMultiplier = Drop == "Gold" and 4 * cashMultiplier or cashMultiplier

	return itemValue * totalMultiplier
end

return module