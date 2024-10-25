local rewards = {}

rewards.DailyRewards = {
	[1] = {
		Rewards = {
			{Type = "Cash", Amount = 100},
		}
	},
	[2] = {
		Rewards = {
			{Type = "Cash", Amount = 0},
		}
	},
	[3] = {
		Rewards = {
			{Type = "Cash", Amount = 750},
		}
	},
	[4] = {
		Rewards = {
			{Potion = "2xCash", Amount = 1},
		}
	},
	[5] = {
		Rewards = {
			{Type = "Cash", Amount = 1500},
		}
	},
	[6] = {
		Rewards = {
			{Type = "Cash", Amount = 3000},
		}
	},
	[7] = {
		Rewards = {
			{ExtraPetSlot = 1},
			{Pet = "Koala"},
		}
	},
}

rewards.SpinWheel = {
	[1] = {
		Chance = 3,
		Orientation = {0, -145, -30},
		Rewards = {
			{Pet = "Koala"},
		}
	},
	[2] = {
		Chance = 40,
		Orientation = {0, -145, -90},
		Rewards = {
			{Type = "Cash", Amount = 100},
		}
	},
	[3] = {
		Chance = 25,
		Orientation = {0, -145, -150},
		Rewards = {
			{SpinAmount = 1},
		}
	},
	[4] = {
		Chance = 20,
		Orientation = {0, -145, 150},
		Rewards = {
			{Type = "Cash", Amount = 500},
		}
	},
	[5] = {
		Chance = 5,
		Orientation = {0, -145, 90},
		Rewards = {
			{Potion = "VipRush", Amount = 1},
		}
	},
	[6] = {
		Chance = 7,
		Orientation = {0, -145, 30},
		Rewards = {
			{Type = "Cash", Amount = 1250},
		}
	},
}

return rewards