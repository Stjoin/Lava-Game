local module = {}

-- Table of synonyms for "cool"
module.coolSynonyms = {
	"cool", "awesome", "amazing", "fantastic", "great", 
	"excellent", "superb", "wonderful", "impressive", "neat"
}
module.purchasedSynonyms = {
	"purchased", "bought", "acquired", "obtained", "secured", 
	"procured", "boughten", "picked up", "gotten", "received"
}
module.notEnoughMoneySynonyms = {
	"not enough money", "short on cash", "financially strapped", 
	"low on funds", "cash-strapped", "broke", "penniless", 
	"money is tight", "insolvent", "bankrupt"
}

function module.getRandomSynonym(synonymsTable)
	local randomIndex = math.random(1, #synonymsTable)
	return synonymsTable[randomIndex]
end

return module
