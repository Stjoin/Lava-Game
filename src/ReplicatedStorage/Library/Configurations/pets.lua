local replicatedStorage = game.ReplicatedStorage

local bindables = replicatedStorage.Networking.Bindables

local module = {}

local functions = require(script.Parent.Parent.Packages.Functions)
local dataService = require(script.Parent.Parent.Shared.data_service)

module.StatMargin = 0
module.Equipped = 2
module.Storage = 30

module.MaxExtraPets = 16
module.MaxNameCharacters = 15
module.ExtraPetsPerPurchase = 2

module.Rarities = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Omega"}

module.PetWalkingAnimationId = "101803400328641"
module.PetFlyingAnimationId = "138552008596365"

module.RarityGradients = script.Rarities
module.HatchSFX = script.HatchSFX
module.CrackSFX = script.Crack
module.Header = script.Header

module.Eggs = {

}

module.RobuxPets = {
	
}

module.Pets = {
	--Forest
	["Hippo"] = {Rarity = "Rare", Icon = "2831540231", Egg = "Forest Egg", Cash = 0.25, DamageMultiplier = 0.5, WalkSpeed = 4},
	["Gorilla"] = {Rarity = "Epic", Icon = "2831540152", Egg = "Forest Egg", Cash = 0.5, DamageMultiplier = 0.5},
	["Panda"] = {Rarity = "Common", Icon = "2831538414", Egg = "Forest Egg", Cash = 0.5, DamageMultiplier = 0.5},
	
	--Winter
	["Polar Bear"] = {Rarity = "Common", Icon = "2831540361", Egg = "Winter Egg", Cash = 0.5, DamageMultiplier = 0.5},
	["Colibry"] = {Rarity = "Rare", Icon = "2831682341", Egg = "Winter Egg", Cash = 0.5, DamageMultiplier = 0.5},
	["Swan"] = {Rarity = "Epic", Icon = "2831682743", Egg = "Winter Egg", Cash = 1, DamageMultiplier = 0.5 },
	
	--Desert
	["Camel"] = {Rarity = "Common", Icon = "2831539960", Egg = "Desert Egg", Cash = 0.5, DamageMultiplier = 0.5},
	["Fox"] = {Rarity = "Rare", Icon = "2831538222", Egg = "Desert Egg", Cash = 0.5, DamageMultiplier = 0.5},
	["Lion"] = {Rarity = "Epic", Icon = "2831538319", Egg = "Desert Egg", Cash = 1, DamageMultiplier = 0.5 },
	
	--Lava
	["Owl"] = {Rarity = "Common", Icon = "2831538378", Egg = "Lava Egg", Cash = 0.5, DamageMultiplier = 0.5},
	["Turkey"] = {Rarity = "Rare", Icon = "2831682818", Egg = "Lava Egg", Cash = 0.5, DamageMultiplier = 0.5},
	["Rooster"] = {Rarity = "Epic", Icon = "2831682685", Egg = "Lava Egg", Cash = 0.5, DamageMultiplier = 0.5},
	
	--Candy
	["Pig"] = {Rarity = "Common", Icon = "2831538442", Egg = "Candy Egg", Cash = 0.5, DamageMultiplier = 0.5},
	["Lizard"] = {Rarity = "Rare", Icon = "2831538358", Egg = "Candy Egg", Cash = 0.5, DamageMultiplier = 0.5},
	["Flamingo"] = {Rarity = "Epic", Icon = "2831682490", Egg = "Candy Egg", Cash = 1, DamageMultiplier = 0.5 },
	
	--Underwater
	["Penguin"] = {Rarity = "Common", Icon = "2831540329", Egg = "Underwater Egg", Cash = 0.5, DamageMultiplier = 0.5},
	["Crane"] = {Rarity = "Rare", Icon = "2831682374", Egg = "Underwater Egg", Cash = 0.5, DamageMultiplier = 0.5},
	["Turtle"] = {Rarity = "Epic", Icon = "2831538501", Egg = "Underwater Egg", Cash = 0.5, DamageMultiplier = 0.5},
	
	--Kawaii
	["Mouse"] = {Rarity = "Common", Icon = "2831540302", Egg = "Kawaii Egg", Cash = 0.5, DamageMultiplier = 0.5},
	["Cat"] = {Rarity = "Rare", Icon = "2831537995", Egg = "Kawaii Egg", Cash = 0.5, DamageMultiplier = 0.5},
	["Wolf"] = {Rarity = "Epic", Icon = "2831538532", Egg = "Kawaii Egg", Cash = 0.5, DamageMultiplier = 0.5},
	
	--Common
	
	["Bear"] = {Rarity = "Common", Icon = "2831537892", Egg = "Forest Egg", Cash = 0.5, DamageMultiplier = 0.5},
	["Bunny"] = {Rarity = "Common", Icon = "2831537959", Egg = "Forest Egg", Cash = 0.5, DamageMultiplier = 0.5},

	
	
	["Bird"] = {Rarity = "Common", Icon = "2831537932", Egg = "Forest Egg", Cash = 0.5, DamageMultiplier = 0.5},
	["Dog"] = {Rarity = "Common", Icon = "2831538149", Egg = "Forest Egg", Cash = 0.5, DamageMultiplier = 0.5},
	["Koala"] = {Rarity = "Common", Icon = "2831538286", Egg = "Forest Egg", Cash = 0.5, DamageMultiplier = 0.5},
	["Zebra"] = {Rarity = "Common", Icon = "2831538554", Egg = "Forest Egg", Cash = 0.5, DamageMultiplier = 0.5},
	["Chicken"] = {Rarity = "Common", Icon = "2831538065", Egg = "Forest Egg", Cash = 0.5, DamageMultiplier = 0.5},	
	
	["Chick"] = {Rarity = "Common", Icon = "2831538024", Egg = "Forest Egg", Cash = 0.5, DamageMultiplier = 0.5},
	
	["Donkey"] = {Rarity = "Common", Icon = "2831540037", Egg = "Forest Egg", Cash = 0.5, DamageMultiplier = 0.5},
	["Duck"] = {Rarity = "Common", Icon = "2831538177", Egg = "Forest Egg", Cash = 0.5, DamageMultiplier = 0.5},
	["White Fox"] = {Rarity = "Common", Icon = "2831540505", Egg = "Forest Egg", Cash = 0.5, DamageMultiplier = 0.5},
	["Racoon"] = {Rarity = "Common", Icon = "2831540387", Egg = "Forest Egg", Cash = 0.5, DamageMultiplier = 0.5},
	["Pigeon"] = {Rarity = "Common", Icon = "2831682646", Egg = "Forest Egg", Cash = 0.5, DamageMultiplier = 0.5},
	["Bat"] = {Rarity = "Common", Icon = "2831682297", Egg = "Forest Egg", Cash = 0.5, DamageMultiplier = 0.5},
	["Swallow"] = {Rarity = "Common", Icon = "2831682706", Egg = "Forest Egg", Cash = 0.5, DamageMultiplier = 0.5},	
	["Vulture"] = {Rarity = "Common", Icon = "2831682851", Egg = "Forest Egg", Cash = 0.5, DamageMultiplier = 0.5},
	["White Pigeon"] = {Rarity = "Common", Icon = "2831682887", Egg = "Forest Egg", Cash = 0.5, DamageMultiplier = 0.5},
	["Crow"] = {Rarity = "Common", Icon = "2831682416", Egg = "Forest Egg", Cash = 0.5, DamageMultiplier = 0.5},
	["Gull"] = {Rarity = "Common", Icon = "2831682519", Egg = "Forest Egg", Cash = 0.5, DamageMultiplier = 0.5},
	
	--Rare
	
	["Rhino"] = {Rarity = "Rare", Icon = "2831540416", Egg = "Forest Egg", Cash = 0.5, DamageMultiplier = 0.5},
	
	
	["Bison"] = {Rarity = "Rare", Icon = "2831539869", Egg = "Forest Egg", Cash = 0.5, DamageMultiplier = 0.5},
	
	
	["Eagle"] = {Rarity = "Rare", Icon = "2831682454", Egg = "Forest Egg", Cash = 0.5, DamageMultiplier = 0.5},
	["Boar"] = {Rarity = "Rare", Icon = "2831539899", Egg = "Forest Egg", Cash = 0.5, DamageMultiplier = 0.5},
	["Toucan"] = {Rarity = "Rare", Icon = "2831682779", Egg = "Forest Egg", Cash = 0.5, DamageMultiplier = 0.5},
	["Crocodile"] = {Rarity = "Rare", Icon = "2831540002", Egg = "Forest Egg", Cash = 0.5, DamageMultiplier = 0.5},
	["Goose"] = {Rarity = "Rare", Icon = "99912021907604", Egg = "Forest Egg", Cash = 0.5, DamageMultiplier = 0.5},
	["Buffalo"] = {Rarity = "Rare", Icon = "2831539932", Egg = "Forest Egg", Cash = 0.5, DamageMultiplier = 0.5},
	["Tiger"] = {Rarity = "Rare", Icon = "2831540447", Egg = "Forest Egg", Cash = 0.5, DamageMultiplier = 0.5},

	["Goat"] = {Rarity = "Rare", Icon = "2831538257", Egg = "Forest Egg", Cash = 0.5, DamageMultiplier = 0.5},
	["Papagei"] = {Rarity = "Rare", Icon = "2831682566", Egg = "Forest Egg", Cash = 0.5, DamageMultiplier = 0.5},
	["Elephant"] = {Rarity = "Rare", Icon = "2831540069", Egg = "Forest Egg", Cash = 0.5, DamageMultiplier = 0.5},
	
	
	-- Epic
	
	["Sheep"] = {Rarity = "Epic", Icon = "2831538470", Egg = "Forest Egg", Cash = 1, DamageMultiplier = 0.5 },
	["Cow"] = {Rarity = "Epic", Icon = "2831538085", Egg = "Forest Egg", Cash = 1, DamageMultiplier = 0.5 },
	["Giraffe"] = {Rarity = "Epic", Icon = "2831540117", Egg = "Forest Egg", Cash = 1, DamageMultiplier = 0.5 },
	["Peafowl"] = {Rarity = "Epic", Icon = "2831682607", Egg = "Forest Egg", Cash = 1, DamageMultiplier = 0.5 },
	["Unicorn"] = {Rarity = "Epic", Icon = "2831540475", Egg = "Forest Egg", Cash = 1, DamageMultiplier = 0.5 },

	["Hedgehog"] = {Rarity = "Epic", Icon = "2831540195", Egg = "Forest Egg", Cash = 1, DamageMultiplier = 0.5 },
	["Leopard"] = {Rarity = "Epic", Icon = "2831540267", Egg = "Forest Egg", Cash = 1, DamageMultiplier = 0.5 },
	
}

function module.MaxStorage(Player)
	local maxStorage = dataService:GetData(Player, "MaxStorage")
	
	return maxStorage or 50
end

function module.MaxEquipped(Player)
	local maxEquipped = dataService:GetData(Player, "MaxEquipped")
	return maxEquipped or 1
end

function module.PetMultipliers(player)
	local total = 0
	local pets = dataService:GetData(player, "Pets") or {}
	for _, pet in pairs(pets) do
		if pet.Equipped then
			total = total + pet.Multiplier
		end
	end
	return total
end


function module.EggPets(Player, Egg, Amount, DeletePets)
	local ChosenPets = {}
	
	dataService:Set(Player, "Hatched", "+", Amount)

	for _ = 1, Amount do
		local Chosen = functions.chance(module.Eggs[Egg].Pets)
		table.insert(ChosenPets, Chosen)
		if table.find(DeletePets, Chosen) then continue end
		bindables.CreatePet:Fire(Player, Chosen)
	end
	
	return ChosenPets
end

return module