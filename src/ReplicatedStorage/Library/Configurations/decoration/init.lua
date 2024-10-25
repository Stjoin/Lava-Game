local module = {}

local floors = require(script.floors)
local wallpapers = require(script.wallpapers)

module.defaultDecorations = {
	["MainRestaurant"] = {
		["floors"] = "Woody",
		["wallpapers"] = "Bluy",	
	},
	["SideRestaurant"] = {
		["floors"] = "Woody",
		["wallpapers"] = "Bluy",	
	},
	["PinkRestaurant"] = {
		["floors"] = "Woody",
		["wallpapers"] = "Bluy",	
	},
}

module.categories = {	
	["floors"] = {
		textures = floors,
		faces = {"Top"}
	},
	["wallpapers"] = {
		textures = wallpapers,
		faces = {"Back", "Front", "Left", "Right"}
	},
}

function module.getItemInfo(categorieName, item)
	return module.categories[categorieName].textures[item]
end

return module