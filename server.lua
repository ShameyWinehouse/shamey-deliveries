local VORPutils = {}
TriggerEvent("getUtils", function(utils)
    VORPutils = utils
    print = VORPutils.Print:initialize(print) --Initial setup 
end)
local VORPcore = {}
TriggerEvent("getCore", function(core)
    VORPcore = core
end)


-------- EVENTS

RegisterServerEvent("rainbow_deliveries:Reward")
AddEventHandler("rainbow_deliveries:Reward", function(rewardMoney)
    local _source = source
	if Config.ShameyDebug then print("Reward", _source, rewardMoney) end

    local _reward = tonumber(rewardMoney)

	local User = VORPcore.getUser(_source)
	local Character = User.getUsedCharacter

	Character.addCurrency(0, _reward)
	if Config.ShameyDebug then print("delivery reward sent: ", _source, _reward) end

end)

RegisterServerEvent("rainbow_deliveries:LogOnDiscord")
AddEventHandler("rainbow_deliveries:LogOnDiscord", function(mission, deliveryTarget, completed, reasonString)
    local _source = source
	
	local User = VORPcore.getUser(_source)
	local Character = User.getUsedCharacter
	local stringTitle = "Delivery Mission "
	if completed == true then
		stringTitle = stringTitle.."Completed"
	else
		stringTitle = stringTitle.."Failed"
	end
	
	local messageString = string.format(
			"**Mission:** %s\n**Target:** %s\n**Character:** %s %s", 
			mission.name, deliveryTarget.label, Character.firstname, Character.lastname)
	if (not completed) and (reasonString and reasonString ~= '') then
		messageString = messageString .. string.format("\n**Failure Reason:** %s", reasonString)
	end
	
	VORPcore.AddWebhook(stringTitle, Config.Webhook, messageString)
end)


-------- FUNCTIONS



--------

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	  return
	end

end)