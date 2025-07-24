local VORPutils = {}
TriggerEvent("getUtils", function(utils)
    VORPutils = utils
    print = VORPutils.Print:initialize(print) --Initial setup 
end)
local VORPcore = {}
TriggerEvent("getCore", function(core)
    VORPcore = core
end)
MenuData = {}
TriggerEvent("menuapi:getData",function(call)
    MenuData = call
end)

local isMission = false
local missionCoords
local rewardMoney = 0
local currentMission
local deliveryTarget
local missionBlip
local playerCoords 
local allBlip = {}
local missionVehicle
local inMissionMenu = false
local countdownTimer = -1


-------- THREADS

-- Initial setup of blips
Citizen.CreateThread(function()
    for i,v in pairs(Config.DeliveryMissions) do
        allBlip[i] = N_0x554d9d53f696d002(1664425300, v.blip.coords.x, v.blip.coords.y, v.blip.coords.z)
        SetBlipSprite(allBlip[i], v.blip.sprite, 1)
        SetBlipScale(allBlip[i], 0.2)
        Citizen.InvokeNative(0x9CB1A1623062F402, allBlip[i], v.blip.name)
        Citizen.Wait(1)
    end
end)

-- Only occassionally get the player's coords (for performance)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        playerCoords = GetEntityCoords(PlayerPedId())
    end
end)

-- Check if they're nearby a mission origin spot
Citizen.CreateThread(function()
    while true do
        local sleep = 500
        if playerCoords then
            
			for k,v in pairs(Config.DeliveryMissions) do
				local originBlipCoords = vector3(v.blip.coords.x, v.blip.coords.y, v.blip.coords.z)
				if #(playerCoords.xy - originBlipCoords.xy) < 2.0 then

					sleep = 4

					if not isMission then
						if inMissionMenu then
							-- If they're trying to close out of the mission menu
							if IsControlJustPressed(0, Config.KeyID['key']) then
								MenuData.CloseAll()
								inMissionMenu = false
								Citizen.Wait(3 * 1000)
							end
						else
							if not IsPedOnMount(PlayerPedId()) then
								-- Prompt them to start a mission
								SetTextScale(1.5, 1.5)
								local msg = Config.AtMissionText
								local str = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING", msg, Citizen.ResultAsLong())
								Citizen.InvokeNative(0xFA233F8FE190514C, str)
								Citizen.InvokeNative(0xE9990552DEC71600)
								if IsControlJustPressed(0, Config.KeyID['key']) then
									OpenStartMissionMenu(v)
									Citizen.Wait(10 * 1000)
								end
							end
						end
					else
						-- Prompt to give up the current mission at its origin spot
						SetTextScale(1.5, 1.5)
						local msg = Config.Labels.giveUp.text
						local str = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING", msg, Citizen.ResultAsLong())
						Citizen.InvokeNative(0xFA233F8FE190514C, str)
						Citizen.InvokeNative(0xE9990552DEC71600)
						if IsControlJustPressed(0, Config.KeyID['key']) then
							CleanupMission()
							Citizen.Wait(3 * 1000)
						end
					end

				end
			end
            
        end

		Citizen.Wait(sleep)
    end
end)

-- Debug info
if Config.ShameyDebug then
	Citizen.CreateThread(function()
		while true do
			Wait(4000)
			if isMission and missionVehicle then
				-- print("GetVehicleWheelSpeed", GetVehicleWheelSpeed(missionVehicle, 0))
				-- print("GetVehicleWheelRotationSpeed", GetVehicleWheelRotationSpeed(missionVehicle, 0))

				print("GetEntitySpeed", GetEntitySpeed(missionVehicle))
				print("GetDraftVehicleDesiredSpeed", Citizen.InvokeNative(0xC6D7DDC843176701, missionVehicle))
				-- print("GetVehicleEstimatedMaxSpeed", Citizen.InvokeNative(0xFE52F34491529F0B, missionVehicle))
			end
		end
	end)
end

Citizen.CreateThread(function()
    while true do
        Wait(4)
        if isMission then
			
			--Fail if the player is dying
            if IsPedDeadOrDying(PlayerPedId(), true) then
				isMission = false
				FailedMission("You died!")
            end
			
			-- Check if they're at the delivery target spot
            if playerCoords and missionCoords then
				if #(playerCoords.xy - missionCoords.xy) < 4.0 then
				
					-- Make sure they're still near the vehicle
					local missionVehicleCoords = GetEntityCoords(missionVehicle)
					if #(playerCoords.xy - missionVehicleCoords.xy) < 2.0 then

						-- Show the "Finish Delivery" prompt
						local msg = "~o~Finish delivery with ["..Config.KeyID['name'].."]"
						SetTextScale(1.5, 1.5)
						local str = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING", msg, Citizen.ResultAsLong())
						Citizen.InvokeNative(0xFA233F8FE190514C, str)
						Citizen.InvokeNative(0xE9990552DEC71600)
						-- Check if they chose to finish
						if IsControlJustPressed(0, Config.KeyID['key']) then
							
							if Config.ShameyDebug then print("pressed key to finish mission") end
							isMission = false

							if Config.ShameyDebug then print("calling reward for: ", rewardMoney) end
							TriggerServerEvent("rainbow_deliveries:Reward", rewardMoney)

							VORPcore.NotifyLeft(currentMission.name, 'Job Done! Your payment: ~o~~h~$'..rewardMoney, 'generic_textures', 'tick', 6000)
							
							-- Citizen.Wait(1000)
							TaskLeaveVehicle(PlayerPedId(), missionVehicle, 8, 0)
							Citizen.Wait(2000)
							Citizen.InvokeNative(0x55CD5FDDD4335C1E, missionVehicle, 1.0, 1.0, 0.0, 8.0, 1148979587) -- TaskVehicleFleeOnCleanup
							Citizen.Wait(500)

							-- Log for recordkeeping
							LogOnDiscord(currentMission, true)

							CleanupMission()
							
							Citizen.Wait(30 * 1000)

						end
					end
                end
            end


			-- If they went into cinematic camera (autopilot; bad gals!)
			if Citizen.InvokeNative(0xBF7C780731AADBF8) then -- IsCinematicCamRendering
				-- Halt the vehicle
				Citizen.InvokeNative(0x260BE8F09E326A20, missionVehicle, 10.0, 1000, false) -- BringVehicleToHalt
			else
				-- If it's been halted before but now they got out of cinematic 
				if Citizen.InvokeNative(0x404527BC03DA0E6C, missionVehicle) then
					-- Let it drive again
					Citizen.InvokeNative(0x7C06330BFDDA182E, missionVehicle) -- StopBringingVehicleToHalt
				end
			end
        end
    end
end)


-------- EVENTS

RegisterNetEvent("rainbow_deliveries:StartMissionClient")
AddEventHandler("rainbow_deliveries:StartMissionClient", function(deliveryMission, availableTargetId)
	if Config.ShameyDebug then print("StartMissionClient") end
	if Config.ShameyDebug then print("StartMissionClient - deliveryMission: ", deliveryMission) end
	if Config.ShameyDebug then print("StartMissionClient - availableTargetId: ", availableTargetId) end
    local playerPed = PlayerPedId()
    local hasw, playerw = GetCurrentPedWeapon(playerPed, 1)
    if playerw == `WEAPON_UNARMED` then
        if not IsPedOnMount(playerPed) then
			if isMission == false then
				isMission = true
				currentMission = deliveryMission
				
				-- Choose a route and setup GPS
				deliveryTarget = deliveryMission.availableTargets[availableTargetId]
				if Config.ShameyDebug then print("StartMissionClient - deliveryTarget: ", deliveryTarget) end
				local deliveryTargetObject = Config.Targets[deliveryTarget.targetId]
				StartGpsMultiRoute(GetHashKey("COLOR_YELLOW"), true, true)
				missionCoords = vector3(deliveryTargetObject.coords.x, deliveryTargetObject.coords.y, deliveryTargetObject.coords.z)
				AddPointToGpsMultiRoute(missionCoords.x, missionCoords.y, missionCoords.z)
				rewardMoney = deliveryTarget.reward,
				SetGpsMultiRouteRender(true)
				
				-- Set the blip for the target spot
				missionBlip = N_0x554d9d53f696d002(1664425300, missionCoords.x, missionCoords.y, missionCoords.z)
				SetBlipCoords(missionBlip, missionCoords.x, missionCoords.y, missionCoords.z)
				SetBlipSprite(missionBlip, Config.TargetBlip.sprite, 1)
				SetBlipScale(missionBlip, 0.2)
				Citizen.InvokeNative(0x9CB1A1623062F402, missionBlip, Config.TargetBlip.label)
				
				
				local playerCoords = GetEntityCoords(PlayerPedId())
				if Config.ShameyDebug then print("playerCoords", playerCoords) end

				local node, vec, head = GetClosestVehicleNodeWithHeading(playerCoords.x, playerCoords.y, playerCoords.z, 1, true, true, true)
				if Config.ShameyDebug then print("node, vec, head - ", node, vec, head) end
				if not node or vec.x == 0.0 then
					print("ERROR: failed to find node")
					return
				end


				StartMission(deliveryTarget, vec, head, deliveryTarget.vehicleId)
				
				-- Notify
				VORPcore.NotifyLeft(deliveryMission.name, Config.Alerts.startText, 'menu_textures', 'log_gang_bag', Config.Alerts.startTextDuration*1000)
				
            else
				VORPcore.NotifyLeft(deliveryMission.name, Config.Alerts.alreadyInJobText, 'menu_textures', 'menu_icon_alert', Config.Alerts.alreadyTextDuration*1000)
            end
        end
    else
		VORPcore.NotifyLeft(deliveryMission.name, Config.Alerts.hasWeaponText, 'menu_textures', 'menu_icon_holster', Config.Alerts.hasWeaponTextDuration*1000)
    end
end)


-------- FUNCTIONS

function LogOnDiscord(mission, completed, reasonString)
	print("LogOnDiscord", completed, reasonString)
	TriggerServerEvent("rainbow_deliveries:LogOnDiscord", mission, deliveryTarget, completed, reasonString)
end

function StartMission(deliveryTarget, vec, head, vehicleId)
	if Config.ShameyDebug then print("StartMission - ", vec, head, vehicleId) end


	-- Create the vehicle at the nearest road
	local vehicleModelHash = GetHashKey(Config.Vehicles[vehicleId].hash)

	if Config.ShameyDebug then print("vehicleModelHash", vehicleModelHash) end

    RequestModel(vehicleModelHash)
    while not Citizen.InvokeNative(0x1283B8B89DD5D1B6, vehicleModelHash, Citizen.ResultAsBoolean) do
        Wait(1)
    end

	-- Create the vehicle
	missionVehicle = Citizen.InvokeNative(0xAF35D0D2583051B0, vehicleModelHash, vec.x, vec.y, vec.z + 1.0, head, true, false, 0, 1)

	while not DoesEntityExist(missionVehicle) do
        Citizen.Wait(1)
    end

	Citizen.InvokeNative(0x7263332501E07F52, missionVehicle, true) -- SetVehicleOnGroundProperly
	
	if Config.ShameyDebug then print("missionVehicle", missionVehicle) end

	if Config.Vehicles[vehicleId].propset then
		Citizen.InvokeNative(0x75F90E4051CC084C, missionVehicle, GetHashKey(Config.Vehicles[vehicleId].propset)) -- _ADD_VEHICLE_PROPSETS
	end

	-- Get the player's character in the vehicle
	Citizen.Wait(10)
	TaskEnterVehicle(PlayerPedId(), missionVehicle, 3000, -1, 2.0, 8, 0)

	-- Try to prevent them from using autopiloting
	Citizen.InvokeNative(0xC84E138448507567, missionVehicle, true) -- SetVehicleStopInstantlyWhenPlayerInactive
	Citizen.InvokeNative(0x1240E8596A8308B9, missionVehicle, false) -- SetVehicleAllowHomingMissleLockon

	Citizen.CreateThread(function()
		StartCountdownTimer(deliveryTarget)
	end)

	Citizen.CreateThread(function()
		StartLookForWreck()
	end)
end

function FailedMission(reasonString)
	isMission = false
	print("failed", reasonString)
	VORPcore.NotifyLeft(currentMission.name, reasonString.." Mission failed!", 'menu_textures', 'cross', 10*1000)
	LogOnDiscord(currentMission, false, reasonString)
	CleanupMission()
end

function StartLookForWreck()
	Wait(5000)
	while isMission do
		local _IsVehicleDriveable = Citizen.InvokeNative(0xB86D29B10F627379, missionVehicle) -- IsVehicleDriveable
		local _IsVehicleWrecked = Citizen.InvokeNative(0xDDBEA5506C848227, missionVehicle) -- IsVehicleWrecked
		if (_IsVehicleWrecked or not _IsVehicleDriveable) and isMission then
			print("wrecked")

			-- Explode if they were carrying TNT, for the drama
			if deliveryTarget.vehicleId == "tntWagon" then

				Citizen.Wait(2000)
				
				-- Get coords slightly behind the vehicle
				-- local explosionCoords = Citizen.InvokeNative(0x1899F328B0E12848, PlayerPedId(), 0.0, -1.0, 0.0)
				local explosionCoords = GetEntityCoords(missionVehicle)
				if Config.ShameyDebug then print("tnt", explosionCoords) end
				Citizen.InvokeNative(0x7D6F58F69DA92530, explosionCoords.x, explosionCoords.y, explosionCoords.z, 27, 0.5, true, true, 1) -- AddExplosion
				-- Fire
				Citizen.InvokeNative(0x6B83617E04503888, explosionCoords.x, explosionCoords.y, explosionCoords.z, 1, true) -- StartScriptFire
				-- Shake the cam
				Citizen.InvokeNative(0xD9B31B4650520529, 'LARGE_EXPLOSION_SHAKE', 1.0) -- ShakeGameplayCam
				Citizen.Wait(500)
				-- Moar explosionz
				Citizen.InvokeNative(0x7D6F58F69DA92530, explosionCoords.x, explosionCoords.y, explosionCoords.z, 26, 1.0, true, true, 1) -- AddExplosion
				Citizen.Wait(50)
				Citizen.InvokeNative(0x7D6F58F69DA92530, explosionCoords.x, explosionCoords.y, explosionCoords.z, 29, 1.0, true, true, 1) -- AddExplosion
				Citizen.Wait(5000)
			end

			-- Since there are Waits, make sure the mission hasn't been cleaned up already
			if isMission then
				-- Fail the mission
				isMission = false
				FailedMission("You wrecked their wagon!")
			end

		end
		Wait(500)
	end
end

function StartCountdownTimer(deliveryTarget)
	countdownTimer = deliveryTarget.time * 60 * 1000

	-- Show very frequently if they have less than 1 min left
	local updateFrequency
	if countdownTimer > (45 * 60 * 1000) then
		updateFrequency = Config.CountdownNotifyInterval * 1000 * 2
 	elseif countdownTimer > (60 * 1000) then
		updateFrequency = Config.CountdownNotifyInterval * 1000
	else
		updateFrequency = 4000
	end

	while isMission do

		Citizen.Wait(1000)
		countdownTimer = countdownTimer - 1000

		if countdownTimer <= 0 then
			-- Fail the mission
			isMission = false
			FailedMission("You ran out of time!")
			return
		end

		if countdownTimer % updateFrequency == 0 then
			print("time remaining in ms: ", countdownTimer)
			local timeString = convertSeconds(countdownTimer / 1000)
			VORPcore.NotifyLeft(currentMission.name, string.format("%s %s", Config.Labels.timeRemaining.text, timeString), 'menu_textures', 'menu_icon_alert', Config.Labels.timeRemaining.duration*1000)
		end
	end
end

function OpenStartMissionMenu(deliveryMission)
	if Config.ShameyDebug then print("OpenStartMissionMenu") end
	MenuData.CloseAll()
    inMissionMenu = true
	
	local playerPedId = PlayerPedId()
	
	TaskStandStill(playerPedId, -1)

    local elements = {}
	for k,v in pairs(deliveryMission.availableTargets) do
		elements[#elements+1] = { label = v.label, value = v.id, desc = string.format("Money: $%s | Time: %s mins", v.reward, v.time) }
	end
	
	elements[#elements+1] = { label = "Exit", value = "exit", desc = "Exit" }

    MenuData.Open('default', GetCurrentResourceName(), 'delivery'..deliveryMission.id, {
        title    = deliveryMission.name,
        subtext  = "Select a mission",
        align    = 'top-right',
        elements = elements,
    },
    function(data, menu)
		if data.current.value then
		
			if data.current.value ~= "exit" then
				if Config.ShameyDebug then print("OpenStartMissionMenu", deliveryMission, data.current.value) end
				TriggerEvent("rainbow_deliveries:StartMissionClient", deliveryMission, data.current.value)
			end

			menu.close()
			ClearPedTasks(playerPedId)
        	inMissionMenu = false
		end
    end,
    function(data, menu)
        menu.close()
		ClearPedTasks(playerPedId)
        inMissionMenu = false
    end)
end

function CleanupMission()
	if Config.ShameyDebug then print("CleanupMission") end
	isMission = false
	
    currentMission = nil
	deliveryTarget = nil
    missionCoords = nil
    rewardMoney = nil
    SetGpsMultiRouteRender(false)
	
	ClearPedTasksImmediately(PlayerPedId())
    if missionBlip then
        -- print("Blip Deleted: "..missionBlip)
        RemoveBlip(missionBlip)
    end
	missionBlip = nil

	DeleteEntity(missionVehicle)

end

-- function convertMillisecondsToReadable(time)
-- 	-- local days = floor(time/86400)
-- 	-- local hours = floor(mod(time, 86400)/3600)
-- 	local minutes = math.floor((time % 3600)/60)
-- 	local seconds = math.floor((time % 60))
-- 	return string.format("%2dm %2ds", minutes, seconds)
--   end
  
function convertSeconds(time)
    local days = math.floor(time / 86400)
    local hours = math.floor(math.fmod(time, 86400) / 3600)
    local minutes = math.floor(math.fmod(time, 3600) / 60)
    local seconds = math.floor(math.fmod(time, 60))
    
    local s = tostring(days > 0 and days .. (days == 1 and " day " or " days ") or "")
    s = s .. tostring(hours > 0 and hours .. (hours == 1 and "hr " or "hr ") or "")
    s = s .. tostring(minutes > 0 and minutes .. (minutes == 1 and "m " or "m ") or "")
    s = s .. tostring(seconds > 0 and seconds .. (seconds == 1 and "s " or "s ") or "")
    
    return string.gsub(s, ",[^,]*$", "")
end

--------

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	  return
	end

	MenuData.CloseAll()

    CleanupMission()

    for i, v in pairs(allBlip) do
        print("Blip deleted: "..allBlip[i])
        RemoveBlip(allBlip[i])
    end
end)
