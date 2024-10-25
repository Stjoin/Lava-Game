local ItemList = {}

ItemList.ItemsPerStore = {
	MainRestaurant = {
		"Donut",
		"IceTea",
	},
	DeckRestaurant = {
		"Macron",
		"BubbleTea",
	},
	SideRestaurant = {
		"ChocolateMilk",
		"Cupcake",
	},
	PinkRestaurant = {
		"Pancakes",
		"Coffee",

	},
}

ItemList.StoreType = {
	Cafe = "Restaurant",
	MainRestaurant = "Restaurant",
	Mexican = "Restaurant",
	Italian = "Restaurant",

	ToyStore = "Store",
	GroceryStore = "Store",
	ClothingStore = "Store",
	SportStore = "Store",
}

ItemList.Items = { -- these are the items that can be sold/picked up by the player
	["Burger"] = { Store = "MainRestaurant", Value = 15, ImageId = 10578661594 },
	["Fries"] = { Store = "MainRestaurant", Value = 15, ImageId = 10578657289 },
	
	["Donut"] = { Store = "MainRestaurant", Value = 10, ImageId = 110160483158527 },
	["IceTea"] = { Store = "MainRestaurant", Value = 10, ImageId = 119692751690673 },

	["Macron"] = { Store = "DeckRestaurant", Value = 15, ImageId = 100728134899508 },
	["BubbleTea"] = { Store = "DeckRestaurant", Value = 15, ImageId = 137423686770700 },
	
	["ChocolateMilk"] = { Store = "SideRestaurant", Value = 25, ImageId = 95167001944633 },
	["Cupcake"] = { Store = "SideRestaurant", Value = 25, ImageId = 139583744648431 },
	
	["Pancakes"] = { Store = "PinkRestaurant", Value = 30, ImageId = 75777481491061 },
	["Coffee"] = { Store = "PinkRestaurant", Value = 30, ImageId = 136776844650388 },
	
	["Burger2"] = { Store = "MainRestaurant2", Value = 15, ImageId = 10578661594 },
	["Fries2"] = { Store = "MainRestaurant2", Value = 15, ImageId = 10578657289 },
}

return ItemList
