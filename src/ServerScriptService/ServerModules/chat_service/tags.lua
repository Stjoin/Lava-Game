local module = {	
	{
		TagText = "Creator",
		TagColor = "rgb(255,150,0)",
		Column = 4,
		Priority = 1,
		GroupInfo = {
			Id = 34338987,
			Rank = 255,
		},
	},
	
	{
		TagText = "[VIP 👑]",
		TagColor = "rgb(255,225,50)",
		Column = 3,
		Priority = 1,
		GamePass = "VIP",
	},

	{
		TagText = "[PREMIUM ]",
		TagColor = "#ff0263",
		Column = 2,
		Priority = 1,
		Premium = true,
	},
	
	{
		TagText = "[#10 🌎]",
		TagColor = "rgb(70,255,70)",
		Column = 1,
		Priority = 1,
		LeaderboardInfo = {
			Leaderboard = "Wins",
			Placement = 10,
			Higher = true,
			Equal = true,
		},
	},

	{
		TagText = "[#3 🌎]",
		TagColor = "rgb(70,255,70)",
		Column = 1,
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