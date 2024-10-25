local rebirth = {}

rebirth.startersCash = 5000

rebirth.categories = {
	["Income"] = {"ExtraVipChange", "IncreaseIncome", "StaffDiscount", "3xVipMoney"},
	["Decor"] = {"floors", "wallpapers"},
}

rebirth.config = {
	["ExtraVipChange"] = { 
		image = "rbxassetid://18861769756",
		description = "+40% Vip Change",
		points_required = 1,
	},
	["IncreaseIncome"] = { 
		image = "rbxassetid://123075587307100",
		description = "Increase Income by 50%",
		points_required = 1,
	},
	["StaffDiscount"] = { 
		image = "rbxassetid://97237660717461",
		description = "-50% discount on Staff",
		points_required = 1,
	},
	["3xVipMoney"] = { 
		image = "rbxassetid://87730370059504",
		description = "3x Vip Money",
		points_required = 2,
	},
	
	["floors"] = { 
		image = "rbxassetid://138120187863598",
		description = "Able to decorate floors",
		points_required = 1,
	},
	["wallpapers"] = { 
		image = "rbxassetid://86942164877287",
		description = "Choose new wallpapers",
		points_required = 2,
	},
}

return rebirth


