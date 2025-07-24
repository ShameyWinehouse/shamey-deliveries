Config = {}

Config.ShameyDebug = false

Config.KeyID = {['key'] = 0xD9D0E1C0, ['name'] = 'SPACE'} -- Add the control and the text name
Config.AtMissionText = "Press ["..Config.KeyID['name'].."] to start a delivery" --says 'Press U to start' default. Change KeyID['name'] to change the control name

Config.Labels = {
	giveUp = {
		text  = "Press ["..Config.KeyID['name'].."] to give up on your delivery mission.",
	},
	timeRemaining = {
		text = "Time Left:",
		duration = 3 -- in seconds
	},
}

Config.Webhook = "https://discord.com/api/webhooks/..."

Config.CountdownNotifyInterval = 60 -- in seconds

Config.Vehicles = {
	oilWagon = {
		id = "oilWagon",
		hash = "oilWagon01x",
	},
	bakeryWagon = {
		id = "bakeryWagon",
		hash = "wagonwork01x",
	},
	dairyWagon = {
		id = "dairyWagon",
		hash = "wagondairy01x",
		propset = "pg_delivery_dairy01x",
	},
	bountyWagon = {
		id = "bountyWagon",
		hash = "bountywagon01x",
	},
	wagonArmoured = {
		id = "wagonArmoured",
		hash = "wagonarmoured01x",
	},
	logWagon = {
		id = "logWagon",
		hash = "logwagon",
		propset = "pg_veh_logwagon_1",
	},
	tntWagon = {
		id = "tntWagon",
		hash = "chuckwagon000x",
		propset = "pg_teamster_chuckwagon000x_tnt",
	},
	coalWagon = {
		id = "coalWagon",
		hash = "coal_wagon",
		propset = "pg_delivery_Coal01x",
	},
	
}

Config.Targets = {

	-- -- DEBUG - ST DENIS
	-- DEBUGSTDENIS = {
	-- 	label = "DEBUG - ST DENIS",
	-- 	coords = {x = 2726.23, y = -1417.56, z = 46.31}
	-- },
	
	-- Rhodes
	rhodes = {
		label = "Rhodes",
		coords = {x = 1233.9, y = -1274.58, z = 75.81}, --Delivery position
	},
	-- Van Horn
	vanHorn = {
		label = "Van Horn",
		coords = {x = 2937.06, y = 573.92, z = 44.62},
	},
	-- Annesburg
	annesburg = {
		label = "Annesburg Mines",
		coords = {x = 2808.34, y = 1351.91, z = 71.43},
	},
	-- Wallace Station
	wallace = {
		label = "Wallace Station",
		coords = {x = -1310.99, y = 383.32, z = 95.5},
	},
	-- Sisika Docks
	stDenisSisikaDocks = {
		label = "Sisika Docks",
		coords = {x = 2904.05, y = -1231.52, z = 45.99}
	},
	-- Valentine Bank
	valentineBank = {
		label = "Valentine Bank",
		coords = {x = -301.67, y = 750.97, z = 118.0}
	},
	-- Strawberry
	strawberry = {
		label = "Strawberry",
		coords = {x = -1791.81, y = -433.77, z = 155.47}
	},
	-- Armadillo
	armadillo = {
		label = "Armadillo",
		coords = {x = -3635.84, y = -2626.05, z = -13.67}
	},
	-- Colter
	colter = {
		label = "Colter",
		coords = {x = -1340.1, y = 2432.81, z = 307.89}
	},
}

Config.TargetBlip = {
	sprite = -984192463, --Blip Sprite for drop position's blip on map
	label = "Deliver here!", --Drop' Blip Name on Map
}

Config.DeliveryMissions = {
	{
		id = "stDenis",
		name = "St. Denis Mission",--Name to display for notification
		blip = {
			name = "Mission: Delivery", --Blip Name on Map
			sprite = -426139257, -- Blip Sprite
			coords = { --Mission Start and Map Blip Coords
				x = 2783.34, y = -1345.51, z = 46.24
			},
			
		},
		
		availableTargets = {
			-- DEBUGSTDENIS = {
			-- 	id = "DEBUGSTDENIS",
			-- 	targetId = "DEBUGSTDENIS",
			-- 	label = "DEBUGSTDENIS",
			-- 	time = 1, -- in minutes
			-- 	reward = 1,
			-- 	vehicleId = "bakeryWagon",
			-- },
			rhodesNormal = {
				id = "rhodesNormal",
				targetId = "rhodes",
				label = "Rhodes",
				time = 25, -- in minutes
				reward = 10,
				vehicleId = "dairyWagon",
			},
			rhodesUrgent = {
				id = "rhodesUrgent",
				targetId = "rhodes",
				label = "Rhodes (URGENT)",
				time = 7, -- in minutes
				reward = 25,
				vehicleId = "dairyWagon",
			},
			vanHornNormal = {
				id = "vanHornNormal",
				targetId = "vanHorn",
				label = "Van Horn",
				time = 25,
				reward = 10,
				vehicleId = "bakeryWagon",
			},
			annesburgNormal = {
				id = "annesburgNormal",
				targetId = "annesburg",
				label = "Annesburg",
				time = 30,
				reward = 10,
				vehicleId = "bakeryWagon",
			},
		},
	},

	{
		id = "oilRefinery",
		name = "Oil Refinery Mission",--Name to display for notification
		blip = {
			name = "Mission: Delivery", --Blip Name on Map
			sprite = -426139257, -- Blip Sprite
			coords = { --Mission Start and Map Blip Coords
				x = 508.85,
				y = 690.01, 
				z = 115.51
			},
			
		},
		
		availableTargets = {
			wallaceNormal = {
				id = "wallaceNormal",
				targetId = "wallace",
				label = "Wallace Station",
				time = 40, -- in minutes
				reward = 15,
				vehicleId = "oilWagon",
			},
			wallaceUrgent = {
				id = "wallaceUrgent",
				targetId = "wallace",
				label = "Wallace Station (URGENT)",
				time = 10, -- in minutes
				reward = 35,
				vehicleId = "oilWagon",
			},
			vanHornNormal = {
				id = "vanHornNormal",
				targetId = "vanHorn",
				label = "Van Horn",
				time = 30,
				reward = 10,
				vehicleId = "oilWagon",
			},
		},
	},

	{
		id = "annesburg",
		name = "Annesburg Mission",--Name to display for notification
		blip = {
			name = "Mission: Delivery", --Blip Name on Map
			sprite = -426139257, -- Blip Sprite
			coords = { --Mission Start and Map Blip Coords
				x = 2926.6, y = 1338.96, z = 44.04
			},
			
		},
		
		availableTargets = {
			stDenisUrgent = {
				id = "stDenisUrgent",
				targetId = "stDenisSisikaDocks",
				label = "Sisika Docks (URGENT)",
				time = 10, -- in minutes
				reward = 25,
				vehicleId = "bountyWagon",
			},
			rhodesNormal = {
				id = "rhodesNormal",
				targetId = "rhodes",
				label = "Rhodes",
				time = 30, -- in minutes
				reward = 10,
				vehicleId = "coalWagon",
			},
		},
	},

	{
		id = "rhodes",
		name = "Rhodes Mission",--Name to display for notification
		blip = {
			name = "Mission: Delivery", --Blip Name on Map
			sprite = -426139257, -- Blip Sprite
			coords = { --Mission Start and Map Blip Coords
				x = 1278.9, y = -1316.15, z = 76.71
			},
			
		},
		
		availableTargets = {
			valentineBankUrgent = {
				id = "valentineBankUrgent",
				targetId = "valentineBank",
				label = "Valentine Bank (URGENT)",
				time = 8, -- in minutes
				reward = 35,
				vehicleId = "wagonArmoured",
			},
		},
	},

	{
		id = "blackwater",
		name = "Blackwater Mission",--Name to display for notification
		blip = {
			name = "Mission: Delivery", --Blip Name on Map
			sprite = -426139257, -- Blip Sprite
			coords = { --Mission Start and Map Blip Coords
				x = -744.52, y = -1336.69, z = 43.34
			},
			
		},
		
		availableTargets = {
			strawberryNormal = {
				id = "strawberryNormal",
				targetId = "strawberry",
				label = "Strawberry",
				time = 30, -- in minutes
				reward = 20,
				vehicleId = "logWagon",
			},
			armadilloNormal = {
				id = "armadilloNormal",
				targetId = "armadillo",
				label = "Armadillo",
				time = 60, -- in minutes
				reward = 50,
				vehicleId = "logWagon",
			},
		},
	},

	{
		id = "bacchus",
		name = "Bacchus Mission",--Name to display for notification
		blip = {
			name = "Mission: Delivery", --Blip Name on Map
			sprite = -426139257, -- Blip Sprite
			coords = { --Mission Start and Map Blip Coords
				x = 590.41, y = 1678.8, z = 187.67
			},
			
		},
		
		availableTargets = {
			colterNormal = {
				id = "colterNormal",
				targetId = "colter",
				label = "Colter (HAZARD)",
				time = 30, -- in minutes
				reward = 100,
				vehicleId = "tntWagon",
			},
		},
	},

}

Config.Alerts = {
	startText = 'Mission Started!~n~~o~~h~Deliver the package in time. Check your map!', --Help text after the job started
	startTextDuration = 6, -- seconds
	alreadyInJobText = '~e~You have to finish the current~h~~t6~delivery~e~!',--Help text when the player wants to start again the mission after started
	alreadyTextDuration = 3, -- seconds
	hasWeaponText = '~h~~e~Please put your weapon away.',--When the player is not unarmed at starting the job
	hasWeaponTextDuration = 3, -- seconds
	failedText = '~h~~e~You lost the package!',--Help Text when the player is dead/swimming/climbing/falling
	failedTextDuration = 3, -- seconds
}
