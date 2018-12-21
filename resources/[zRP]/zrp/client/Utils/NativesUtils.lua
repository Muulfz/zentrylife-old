---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Muulfz.
--- DateTime: 12/1/2018 5:43 AM
---

function tzRP.getArmour()
    return GetPedArmour(GetPlayerPed(-1))
end

function tzRP.isPlayerInVehicleModel(model)
    if (IsVehicleModel(GetVehiclePedIsUsing(GetPlayerPed(-1)), GetHashKey(model))) then -- just a function you can use to see if your player is in a taxi or any other car model (use the tunnel)
        return true
    else
        return false
    end
end

function tzRP.isInAnyVehicle()
    if IsPedInAnyVehicle(GetPlayerPed(-1)) then
        return true
    else
        return false
    end
end

function tzRP.getVehicleInDirection( coordFrom, coordTo )
    local rayHandle = CastRayPointToPoint( coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, GetPlayerPed( -1 ), 0 )
    local _, _, _, _, vehicle = GetRaycastResult( rayHandle )
    return vehicle
end


function tzRP.deleteVehicleByOffset(offset, notify)
    local ped = GetPlayerPed(-1)
    local veh = tzRP.getVehicleInDirection(GetEntityCoords(ped, 1), GetOffsetFromEntityInWorldCoords(ped, 0.0, offset, 0.0))

    if IsEntityAVehicle(veh) then
        SetVehicleHasBeenOwnedByPlayer(veh,false)
        Citizen.InvokeNative(0xAD738C3085FE7E11, veh, false, true) -- set not as mission entity
        SetVehicleAsNoLongerNeeded(Citizen.PointerValueIntInitialized(veh))
        Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(veh))
        if notify then
            tzRP.notify("~g~Vehicle deleted.")
        end
    else
        if notify then
            tzRP.notify("~r~Too far away from vehicle.")
        end
    end
end

-- Ped Types: Any ped = -1 | Player = 1 | Male = 4 | Female = 5 | Cop = 6 | Human = 26 | SWAT = 27 | Animal = 28 | Army = 29
function tzRP.isClosestPedType(radius, pedType)
    local outPed = {}
    local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1),true))
    local found = GetClosestPed(x+0.0001, y+0.0001, z+0.0001,radius+0.0001, 1, 0, outPed, 1, 1, pedType)
    if found then
        return true
    end
    return false
end


function tzRP.deleteVehicleModelByOffset(model,offset)
    local ped = GetPlayerPed(-1)
    local veh = tzRP.getVehicleInDirection(GetEntityCoords(ped, 1), GetOffsetFromEntityInWorldCoords(ped, 0.0, offset, 0.0))

    if IsEntityAVehicle(veh) and IsVehicleModel(veh, GetHashKey(model)) then
        SetVehicleHasBeenOwnedByPlayer(veh,false)
        Citizen.InvokeNative(0xAD738C3085FE7E11, veh, false, true) -- set not as mission entity
        SetVehicleAsNoLongerNeeded(Citizen.PointerValueIntInitialized(veh))
        Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(veh))
        tzRP.notify("~g~Vehicle deleted.")
    else
        tzRP.notify("~r~Too far away from vehicle.")
    end
end


function tzRP.isClosestPedModel(radius, model)
    local outPed = {}
    local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1),true))
    local found = GetClosestPed(x+0.0001, y+0.0001, z+0.0001,radius+0.0001, 1, 0, outPed, 1, 1, -1)
    if found then
        if IsPedModel(outPed, GetHashKey(model)) then
            return true
        end
    end
    return false
end

function tzRP.getPlayerName(player)
    return GetPlayerName(player)
end

function tzRP.freezePed(flag)
    FreezeEntityPosition(GetPlayerPed(-1),flag)
end


function tzRP.freezePedVehicle(flag)
    FreezeEntityPosition(GetVehiclePedIsIn(GetPlayerPed(-1),false),flag)
end


function tzRP.deleteVehiclePedIsIn()
    local v = GetVehiclePedIsIn(GetPlayerPed(-1),false)
    SetVehicleHasBeenOwnedByPlayer(v,false)
    Citizen.InvokeNative(0xAD738C3085FE7E11, v, false, true) -- set not as mission entity
    SetVehicleAsNoLongerNeeded(Citizen.PointerValueIntInitialized(v))
    Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(v))
end


function tzRP.deleteNearestVehicle(radius, notify)
    local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1),true))
    local veh = GetClosestVehicle( x+0.0001, y+0.0001, z+0.0001,radius+0.0001,0,70)
    if IsEntityAVehicle(veh) then
        SetVehicleHasBeenOwnedByPlayer(veh,false)
        Citizen.InvokeNative(0xAD738C3085FE7E11, veh, false, true) -- set not as mission entity
        SetVehicleAsNoLongerNeeded(Citizen.PointerValueIntInitialized(veh))
        Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(veh))
        if notify then
            tzRP.notify("Deletado com sucesso") -- lang.deleteveh.success()
        end
    else
        if notify then
            tzRP.notify("Nao foi possivel deletar") -- lang.deleteveh.toofar()
        end
    end
end


function tzRP.deleteNearestVehicleModel(radius, model)
    local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1),true))
    local v = GetClosestVehicle( x+0.0001, y+0.0001, z+0.0001,radius+0.0001,GetHashKey(model),70)
    if IsVehicleModel(v, GetHashKey(model)) then
        SetVehicleHasBeenOwnedByPlayer(v,false)
        Citizen.InvokeNative(0xAD738C3085FE7E11, v, false, true) -- set not as mission entity
        SetVehicleAsNoLongerNeeded(Citizen.PointerValueIntInitialized(v))
        Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(v))
        return true
    else
        return false
    end
end

function tzRP.deleteTowedVehicleModel(offset,model)
    local player = GetPlayerPed( -1 )
    local pos = GetEntityCoords(player)
    local entityWorld = GetOffsetFromEntityInWorldCoords(player, 0.0, -offset, 0.0)
    local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, player, 0)
    local a, b, c, d, vehicleHandle = GetRaycastResult(rayHandle)
    if vehicleHandle ~= nil then
        if IsVehicleModel(vehicleHandle, GetHashKey(model)) then
            SetVehicleHasBeenOwnedByPlayer(vehicleHandle,false)
            Citizen.InvokeNative(0xAD738C3085FE7E11, vehicleHandle, false, true) -- set not as mission entity
            SetVehicleAsNoLongerNeeded(Citizen.PointerValueIntInitialized(vehicleHandle))
            Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(vehicleHandle))
            return true
        else
            return false
        end
    else
        return false
    end
end


function tzRP.deleteTowedVehicle(offset)
    local player = GetPlayerPed( -1 )
    local pos = GetEntityCoords(player)
    local entityWorld = GetOffsetFromEntityInWorldCoords(player, 0.0, -offset, 0.0)
    local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, player, 0)
    local a, b, c, d, vehicleHandle = GetRaycastResult(rayHandle)
    if vehicleHandle ~= nil then
        SetVehicleHasBeenOwnedByPlayer(vehicleHandle,false)
        Citizen.InvokeNative(0xAD738C3085FE7E11, vehicleHandle, false, true) -- set not as mission entity
        SetVehicleAsNoLongerNeeded(Citizen.PointerValueIntInitialized(vehicleHandle))
        Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(vehicleHandle))
        return true
    else
        return false
    end
end

function tzRP.getVehiclePedIsInPlateText()
    local p = ""
    local v = GetVehiclePedIsIn(GetPlayerPed(-1),false)
    p = GetVehicleNumberPlateText(v)
    return p
end

function tzRP.isPedVehicleOwner()
    local r = true
    local v = GetVehiclePedIsIn(GetPlayerPed(-1),false)
    GetVehicleOwner(v,function(o)
        if IsEntityAVehicle(o) then
            r = false
        end
    end)
    return r
end

function tzRP.getNearestVehiclePlateText(radius)
    local p = ""
    local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1),true))
    local v = GetClosestVehicle( x+0.0001, y+0.0001, z+0.0001,radius+0.0001,0,70)
    p = GetVehicleNumberPlateText(v)
    return p
end

function tzRP.lockpickVehicle(wait,any,notify)
    local pos = GetEntityCoords(GetPlayerPed(-1))
    local entityWorld = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, 20.0, 0.0)

    local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, GetPlayerPed(-1), 0)
    local _, _, _, _, vehicleHandle = GetRaycastResult(rayHandle)
    if DoesEntityExist(vehicleHandle) then
        if GetVehicleDoorsLockedForPlayer(vehicleHandle,PlayerId()) or any then
            local prevObj = GetClosestObjectOfType(pos.x, pos.y, pos.z, 10.0, GetHashKey("prop_weld_torch"), false, true, true)
            if(IsEntityAnObject(prevObj)) then
                SetEntityAsMissionEntity(prevObj)
                DeleteObject(prevObj)
            end
            StartVehicleAlarm(vehicleHandle)
            TaskStartScenarioInPlace(GetPlayerPed(-1), "WORLD_HUMAN_WELDING", 0, true)
            Citizen.Wait(wait*1000)
            SetVehicleDoorsLocked(vehicleHandle, 1)
            for i = 1,64 do
                SetVehicleDoorsLockedForPlayer(vehicleHandle, GetPlayerFromServerId(i), false)
            end
            ClearPedTasksImmediately(GetPlayerPed(-1))

            tzRP.notify("sucesso") -- lang.lockpick.success()

            -- ties to the hotkey lock system
            local plate = GetVehicleNumberPlateText(vehicleHandle)
            zRPserver.lockSystemUpdate(1, plate)
            zRPserver.playSoundWithinDistanceOfEntityForEveryone(vehicleHandle, 10, "unlock", 1.0)
        else
            if notify then
                tzRP.notify("fechado") -- lang.lockpick.unlocked()
            end
        end
    else
        if notify then
            tzRP.notify("muito longe") -- lang.lockpick.toofar()
        end
    end
end

function tzRP.getArmour()
    return GetPedArmour(GetPlayerPed(-1))
end

function tzRP.setArmour(armour,vest)
    local player = GetPlayerPed(-1)
    if vest then
        if(GetEntityModel(player) == GetHashKey("mp_m_freemode_01")) then
            SetPedComponentVariation(player, 9, 4, 1, 2)  --Bulletproof Vest
        else
            if(GetEntityModel(player) == GetHashKey("mp_f_freemode_01")) then
                SetPedComponentVariation(player, 9, 6, 1, 2)
            end
        end
    end
    local n = math.floor(armour)
    SetPedArmour(player,n)
end

function tzRP.setSpikesOnGround()
    local ped = GetPlayerPed(-1)
    local x, y, z = table.unpack(GetEntityCoords(ped, true))
    local h = GetEntityHeading(ped)
    local ox, oy, oz = table.unpack(GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.0, -2.0))
    local spike = GetHashKey("P_ld_stinger_s")

    RequestModel(spike)
    while not HasModelLoaded(spike) do
        Citizen.Wait(1)
    end

    local object = CreateObject(spike, ox, oy, oz, true, true, false)
    PlaceObjectOnGroundProperly(object)
    SetEntityHeading(object, h+90)
end

function tzRP.isCloseToSpikes()
    local ped = GetPlayerPed(-1)
    local x, y, z = table.unpack(GetEntityCoords(ped, true))
    local ox, oy, oz = table.unpack(GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.0, -2.0))
    if DoesObjectOfTypeExistAtCoords(ox, oy, oz, 0.9, GetHashKey("P_ld_stinger_s"), true) then
        return true
    else
        return false
    end
end

function tzRP.removeSpikes()
    local ped = GetPlayerPed(-1)
    local x, y, z = table.unpack(GetEntityCoords(ped, true))
    local ox, oy, oz = table.unpack(GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.0, -2.0))
    if DoesObjectOfTypeExistAtCoords(ox, oy, oz, 0.9, GetHashKey("P_ld_stinger_s"), true) then
        local spike = GetClosestObjectOfType(ox, oy, oz, 0.9, GetHashKey("P_ld_stinger_s"), false, false, false)
        SetEntityAsMissionEntity(spike, true, true)
        DeleteObject(spike)
    end
end

function tzRP.playMovement(clipset,blur,drunk,fade,clear)
    --request anim
    RequestAnimSet(clipset)
    while not HasAnimSetLoaded(clipset) do
        Citizen.Wait(0)
    end
    -- fade out
    if fade then
        DoScreenFadeOut(1000)
        Citizen.Wait(1000)
    end
    -- clear tasks
    if clear then
        ClearPedTasksImmediately(GetPlayerPed(-1))
    end
    -- set timecycle
    SetTimecycleModifier("spectator5")
    -- set blur
    if blur then
        SetPedMotionBlur(GetPlayerPed(-1), true)
    end
    -- set movement
    SetPedMovementClipset(GetPlayerPed(-1), clipset, true)
    -- set drunk
    if drunk then
        SetPedIsDrunk(GetPlayerPed(-1), true)
    end
    -- fade in
    if fade then
        DoScreenFadeIn(1000)
    end

end

function tzRP.resetMovement(fade)
    -- fade
    if fade then
        DoScreenFadeOut(1000)
        Citizen.Wait(1000)
        DoScreenFadeIn(1000)
    end
    -- reset all
    ClearTimecycleModifier()
    ResetScenarioTypesEnabled()
    ResetPedMovementClipset(GetPlayerPed(-1), 0)
    SetPedIsDrunk(GetPlayerPed(-1), false)
    SetPedMotionBlur(GetPlayerPed(-1), false)
end






