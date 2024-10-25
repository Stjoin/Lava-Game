local dataService = require(script.Parent.Parent.Shared.data_service)

local upgrades = {}

-- Player Upgrades
upgrades.PlayerUpgrades = {
	cash_magnet = {
		VisualName = "Cash Magnet",
		Icon = "rbxassetid://18575601457",
		DefaultValue = 1,
		Multiplier = 0.2,
		DefaultLevel = 1,
		MaxLevel = 6,
	},
	pick_up_capacity = {
		VisualName = "Pick Up Capacity",
		Icon = "rbxassetid://18575330210",
		DefaultValue = 6,
		Increment = 2,
		DefaultLevel = 1,
		MaxLevel = 9,
	},
	walk_speed = {
		VisualName = "Walk Speed",
		Icon = "rbxassetid://18575566130",
		DefaultValue = 16,
		Multiplier = 0.2,
		DefaultLevel = 1,
		MaxLevel = 6,
	},
	pick_up_speed = {
		VisualName = "Pick Up Speed",
		Icon = "rbxassetid://18575575754",
		DefaultValue = 0.75,
		Multiplier = -0.075,
		DefaultLevel = 1,
		MaxLevel = 6,
	},
}

-- Store Upgrades
upgrades.StoreUpgrades = {
	waiter_speed = {
		VisualName = "Waiter Speed",
		Icon = "rbxassetid://18575601457",
		LayoutOrder = 1,
		DefaultValue = 12,
		Increment = 3,
		DefaultLevel = 1,
		MaxLevel = 4,
	},
	waiter_money_collect = {
		VisualName = "Waiter Can Collect Money",
		Icon = "rbxassetid://18575330210",
		LayoutOrder = 2,
		DefaultValue = 0,
		Increment = 1,
		DefaultLevel = 1,
		MaxLevel = 2,
	},
}

-- Hire Staff
upgrades.HireStaff = {
	VisualName = "Waiter",
	Icon = "rbxassetid://12345678",
	Currency = "Cash",
	Stores = {
		MainRestaurant = {
			NotRobuxPurchasable = 1,
			MaxAmount = 5,
		},
		DeckRestaurant = {
			MaxAmount = 4,
		},
		SideRestaurant = {
			MaxAmount = 4,
		},
		PinkRestaurant = {
			MaxAmount = 4,
		},
	}
}

-- Prices per upgrade per restaurant
upgrades.PlayerUpgradePrices = {
	cash_magnet = {500, 1600, 4000, 8000, 12000},
	pick_up_capacity = {0, 500, 1200, 2000, 3200, 5800, 7000,10000},
	walk_speed = {800, 1800, 3000, 4600, 8000},
	pick_up_speed = {1000, 2400, 4700, 7000, 8000},
}

-- Prices per upgrade per restaurant (excluding player upgrades)
upgrades.Prices = {
	MainRestaurant = {
		StoreUpgrades = {
			waiter_speed = {300, 600, 1000, 1450},
			waiter_money_collect = {5500},
		},
		HireStaff = {50, 350, 800, 1500, 2200},
	},
	DeckRestaurant = {
		StoreUpgrades = {
			waiter_speed = {500, 800, 1200, 2250},
			waiter_money_collect = {5500},
		},
		HireStaff = {275, 750, 1450, 2500},
	},
	SideRestaurant = {
		StoreUpgrades = {
			waiter_speed = {500, 800, 1200, 2250},
			waiter_money_collect = {5500},
		},
		HireStaff = {275, 750, 1450, 2500},
	},
	PinkRestaurant = {
		StoreUpgrades = {
			waiter_speed = {500, 800, 1200, 2250},
			waiter_money_collect = {5500},
		},
		HireStaff = {275, 750, 1450, 2500},
	},
}

-- Helper functions
function upgrades.getUpgradePrice(player, upgradeType, name, level, restaurant)
	local discount = 1
	if upgradeType == "HireStaff" then
		-- Check if the player has the staff discount
		if dataService:GetData(player, "RebirthUpgrades.Income.StaffDiscount") then
			discount = 0.5  -- Apply 50% discount
		end
	end

	if upgradeType == "PlayerUpgrades" then
		local price = upgrades.PlayerUpgradePrices[name][level - 1] or upgrades.PlayerUpgradePrices[name][#upgrades.PlayerUpgradePrices[name]]
		return price
	elseif upgradeType == "HireStaff" then
		local prices = upgrades.Prices[restaurant][upgradeType]
		local price = prices[level] or prices[#prices]
		return price * discount
	else
		local prices = upgrades.Prices[restaurant][upgradeType]
		local price = prices[name][level] or prices[name][#prices[name]]
		return price
	end
end

function upgrades.getUpgradeInfo(upgradeType, name)
	return upgrades[upgradeType][name]
end

function upgrades.getMaxStaff(restaurant)
	return upgrades.HireStaff.Stores[restaurant].MaxAmount
end

return upgrades