local module = {
	["Default"] = {
		Color = "#bbbbbb",
		Priority = 0,
		Everyone = true,
	},

	["Creator"] = {
		Color = "rgb(255,150,0)",
		Priority = 6,
		GroupInfo = {
			Id = 34338987,
			Rank = 255,
		},
	},
	
	["[VIP 👑]"] = {
		Color = "rgb(255,225,50)",
		Priority = 4,
		GamePass = "VIP",
	},

	["[PREMIUM ]"] = {
		Color = "#ff0263",
		Priority = 3,
		GamePass = "VIP",
	},
	
	["[#10 🌎]"] = {
		Color = "rgb(70,255,70)",
		Priority = 1,
		LeaderboardInfo = {
			Leaderboard = "Wins",
			Placement = 10,
			Higher = true,
			Equal = true,
		},
	},

	["[#3 🌎]"] = {
		Color = "rgb(70,255,70)",
		Priority = 2,
		LeaderboardInfo = {
			Leaderboard = "Wins",
			Placement = 3,
			Higher = true,
			Equal = true,
		},
	},
}

return module
