local isDead, isSoftcuffed = false, false

ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end


end)

AddEventHandler('esx:onPlayerDeath', function(data)
	isDead = true
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		TriggerEvent('angelicxs_softcuff:unrestrain')
	end
end)


RegisterCommand('softcuff', function()
	if not isDead then
		if Config.RequireItem then
			ESX.TriggerServerCallback('angelicxs_softcuff:itemcheck', function(hasItem)
				if hasItem then
					TriggerEvent('angelicxs_softcuff:arrestTarget', GetPlayerServerId(closestPlayer))

				else
					ESX.ShowNotification("You do not have a " ..Config.ItemName.. "!")
				end
			end)
		else
			TriggerEvent('angelicxs_softcuff:arrestTarget', GetPlayerServerId(closestPlayer))
		end
	end
end)

RegisterCommand('releasesoftcuff', function()
	if not isDead and not isSoftcuffed then
		if Config.RequireRleaseItem then
			ESX.TriggerServerCallback('angelicxs_softcuff:releaseitemcheck', function(hasItem)
				if hasItem then
					TriggerEvent('angelicxs_softcuff:releaseTarget', GetPlayerServerId(closestPlayer))
				else
					ESX.ShowNotification("You do not have a " ..Config.ReleaseItemName.. "!")
				end
			end)
		else
			TriggerEvent('angelicxs_softcuff:releaseTarget', GetPlayerServerId(closestPlayer))
		end
	else
		ESX.ShowNotification("You can no take this action right now!")
	end
end)

RegisterNetEvent('angelicxs_softcuff:releaseTarget')
AddEventHandler('angelicxs_softcuff:releaseTarget', function()
	local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
	local playerPed = PlayerPedId()
	if closestPlayer ~= -1 and closestDistance <= 1.5 then
		RequestAnimDict('veh@break_in@0h@p_m_one@')

		while not HasAnimDictLoaded('veh@break_in@0h@p_m_one@') do
			Wait(10)
		end
	
		TaskPlayAnim(playerPed, 'veh@break_in@0h@p_m_one@', 'low_force_entry_ds', 8.0, -8.0, 2000, 33, 0, false, false, false)
		Wait(2000)
		TriggerServerEvent('angelicxs_softcuff:release', GetPlayerServerId(closestPlayer))
	else
		ESX.ShowNotification("There is no one to release!")
	end
end)

RegisterNetEvent('angelicxs_softcuff:arrestTarget')
AddEventHandler('angelicxs_softcuff:arrestTarget', function()
	local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
	if closestPlayer ~= -1 and closestDistance <= 1.5 then
		TriggerServerEvent('angelicxs_softcuff:startArrest', GetPlayerServerId(closestPlayer))
		Citizen.Wait(3100)
		TriggerServerEvent('angelicxs_softcuff:handcuff', GetPlayerServerId(closestPlayer))
	else
		ESX.ShowNotification("There is no one to handcuff!")
	end
end)

RegisterNetEvent('angelicxs_softcuff:arrested')
AddEventHandler('angelicxs_softcuff:arrested', function(target)
	arrested = true
	local playerPed = PlayerPedId()
	local targetPed = GetPlayerPed(GetPlayerFromServerId(target))

	RequestAnimDict('mp_arrest_paired')

	while not HasAnimDictLoaded('mp_arrest_paired') do
		Wait(10)
	end

	AttachEntityToEntity(PlayerPedId(), targetPed, 11816, -0.1, 0.45, 0.0, 0.0, 0.0, 20.0, false, false, false, false, 20, false)
	TaskPlayAnim(playerPed, 'mp_arrest_paired', 'crook_p2_back_left', 8.0, -8.0, 5500, 33, 0, false, false, false)
	FreezeEntityPosition(targetrPed, true) --- freeze ped while cuffing

	Wait(950)
	DetachEntity(PlayerPedId(), true, false)
	FreezeEntityPosition(targetPed, false) --unfreeze ped after done

	arrested = false
end)

RegisterNetEvent('angelicxs_softcuff:arrest')
AddEventHandler('angelicxs_softcuff:arrest', function()
	local playerPed = PlayerPedId()

	RequestAnimDict('mp_arrest_paired')

	while not HasAnimDictLoaded('mp_arrest_paired') do
		Wait(10)
	end

	TaskPlayAnim(playerPed, 'mp_arrest_paired', 'cop_p2_back_left', 8.0, -8.0, 3400, 33, 0, false, false, false)

	Wait(3000)

	arreste = false

end)


RegisterNetEvent('angelicxs_softcuff:handcuff')
AddEventHandler('angelicxs_softcuff:handcuff', function()
	isSoftcuffed = not isSoftcuffed
	local playerPed = PlayerPedId()

	if isSoftcuffed then
		RequestAnimDict('mp_arresting')
		while not HasAnimDictLoaded('mp_arresting') do
			Citizen.Wait(100)
		end

		ClearPedSecondaryTask(playerPed) -- Fix untarget issue maybe?
		TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)

		SetEnableHandcuffs(playerPed, true)
		DisablePlayerFiring(playerPed, true)
		SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true) -- unarm player
		SetPedCanPlayGestureAnims(playerPed, false)
		FreezeEntityPosition(playerPed, false)
		DisplayRadar(false)

	else

		ClearPedSecondaryTask(playerPed)
		SetEnableHandcuffs(playerPed, false)
		DisablePlayerFiring(playerPed, false)
		SetPedCanPlayGestureAnims(playerPed, true)
		FreezeEntityPosition(playerPed, false)
		DisplayRadar(true)
	end
end)


RegisterNetEvent('angelicxs_softcuff:unrestrain')
AddEventHandler('angelicxs_softcuff:unrestrain', function()
	if isSoftcuffed then
		local playerPed = PlayerPedId()
		isSoftcuffed = false

		ClearPedSecondaryTask(playerPed)
		SetEnableHandcuffs(playerPed, false)
		DisablePlayerFiring(playerPed, false)
		SetPedCanPlayGestureAnims(playerPed, true)
		FreezeEntityPosition(playerPed, false)
		DisplayRadar(true)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()

		if isSoftcuffed then
		--	DisableControlAction(0, 1, true) -- Disable pan
		--	DisableControlAction(0, 2, true) -- Disable tilt
			DisableControlAction(0, 24, true) -- Attack
			DisableControlAction(0, 257, true) -- Attack 2
			DisableControlAction(0, 25, true) -- Aim
			DisableControlAction(0, 263, true) -- Melee Attack 1
		--	DisableControlAction(0, 32, true) -- W
		--	DisableControlAction(0, 34, true) -- A
		--	DisableControlAction(0, 31, true) -- S
		--	DisableControlAction(0, 30, true) -- D

			DisableControlAction(0, 45, true) -- Reload
		--	DisableControlAction(0, 22, true) -- Jump
			DisableControlAction(0, 44, true) -- Cover
		--	DisableControlAction(0, 37, true) -- Select Weapon
			DisableControlAction(0, 23, true) -- Also 'enter'?

			DisableControlAction(0, 288,  true) -- Disable phone
			DisableControlAction(0, 289, true) -- Inventory
			DisableControlAction(0, 170, true) -- Animations
			DisableControlAction(0, 167, true) -- Job

		--	DisableControlAction(0, 0, true) -- Disable changing view
		--	DisableControlAction(0, 26, true) -- Disable looking behind
			DisableControlAction(0, 73, true) -- Disable clearing animation
			DisableControlAction(2, 199, true) -- Disable pause screen

		--	DisableControlAction(0, 59, true) -- Disable steering in vehicle
			DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
			DisableControlAction(0, 72, true) -- Disable reversing in vehicle

			DisableControlAction(2, 36, true) -- Disable going stealth

		--	DisableControlAction(0, 47, true)  -- Disable weapon
		--	DisableControlAction(0, 264, true) -- Disable melee
		--	DisableControlAction(0, 257, true) -- Disable melee
		--	DisableControlAction(0, 140, true) -- Disable melee
		--	DisableControlAction(0, 141, true) -- Disable melee
		--	DisableControlAction(0, 142, true) -- Disable melee
		--	DisableControlAction(0, 143, true) -- Disable melee
			DisableControlAction(0, 75, true)  -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle
			EnableControlAction(0, 51, true)
			EnableControlAction(0, 54, true)
			EnableControlAction(0, 86, true)

			if IsEntityPlayingAnim(playerPed, 'mp_arresting', 'idle', 3) ~= 1 then
				ESX.Streaming.RequestAnimDict('mp_arresting', function()
					TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
				end)
			end
		else
			Citizen.Wait(500)
		end
	end
end)