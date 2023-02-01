ESX = nil

ESX = exports["es_extended"]:getSharedObject()

RegisterServerEvent('angelicxs_softcuff:startArrest')
AddEventHandler('angelicxs_softcuff:startArrest', function(target)
	local targetPlayer = ESX.GetPlayerFromId(target)
	TriggerClientEvent('angelicxs_softcuff:arrested', targetPlayer.source, source)
	TriggerClientEvent('angelicxs_softcuff:arrest', source)
end)

RegisterNetEvent('angelicxs_softcuff:handcuff')
AddEventHandler('angelicxs_softcuff:handcuff', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)
	TriggerClientEvent('angelicxs_softcuff:handcuff', target)
end)

ESX.RegisterServerCallback('angelicxs_softcuff:itemcheck', function(source,cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getInventoryItem(Config.ItemName).count >= 1 then
		xPlayer.removeInventoryItem(Config.ItemName,1)
		cb(true)
	else
		cb(false)
	end
end)

ESX.RegisterServerCallback('angelicxs_softcuff:releaseitemcheck', function(source,cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getInventoryItem(Config.ReleaseItemName).count >= 1 then
		xPlayer.removeInventoryItem(Config.ReleaseItemName,1)
		cb(true)
	else
		cb(false)
	end
end)

RegisterNetEvent('angelicxs_softcuff:release')
AddEventHandler('angelicxs_softcuff:release', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)
	TriggerClientEvent('angelicxs_softcuff:unrestrain', target)
end)

ESX.RegisterUsableItem(Config.ItemName, function(source)
        
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem(Config.ItemName, 1)
	TriggerClientEvent('angelicxs_softcuff:arrestTarget')

end)

ESX.RegisterUsableItem(Config.ReleaseItemName, function(source)
        
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem(Config.ReleaseItemName, 1)
	TriggerClientEvent('angelicxs_softcuff:releaseTarget')

end)
