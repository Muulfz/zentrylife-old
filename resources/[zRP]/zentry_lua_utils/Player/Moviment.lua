---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Muulfz.
--- DateTime: 12/21/2018 5:27 PM
---


local crouched = false
local proned = false
local crouchKey = 26
local proneKey = 36

Citizen.CreateThread( function()
    while true do
        Citizen.Wait( 1 )
        local ped = GetPlayerPed( -1 )
        if ( DoesEntityExist( ped ) and not IsEntityDead( ped ) ) then
            ProneMovement()
            DisableControlAction( 0, proneKey, true )
            DisableControlAction( 0, crouchKey, true )
            if ( not IsPauseMenuActive() ) then
                if ( IsDisabledControlJustPressed( 0, crouchKey ) and not proned ) then
                    RequestAnimSet( "move_ped_crouched" )
                    RequestAnimSet("MOVE_M@TOUGH_GUY@")

                    while ( not HasAnimSetLoaded( "move_ped_crouched" ) ) do
                        Citizen.Wait( 100 )
                    end
                    while ( not HasAnimSetLoaded( "MOVE_M@TOUGH_GUY@" ) ) do
                        Citizen.Wait( 100 )
                    end
                    if ( crouched and not proned ) then
                        ResetPedMovementClipset( ped )
                        ResetPedStrafeClipset(ped)
                        SetPedMovementClipset( ped,"MOVE_M@TOUGH_GUY@", 0.5)
                        crouched = false
                    elseif ( not crouched and not proned ) then
                        SetPedMovementClipset( ped, "move_ped_crouched", 0.55 )
                        SetPedStrafeClipset(ped, "move_ped_crouched_strafing")
                        crouched = true
                    end
                elseif ( IsDisabledControlJustPressed(0, proneKey) and not crouched and not IsPedInAnyVehicle(ped, true) and not IsPedFalling(ped) and not IsPedDiving(ped) and not IsPedInCover(ped, false) and not IsPedInParachuteFreeFall(ped) and (GetPedParachuteState(ped) == 0 or GetPedParachuteState(ped) == -1) ) then
                    if proned then
                        ClearPedTasksImmediately(ped)
                        proned = false
                    elseif not proned then
                        RequestAnimSet( "move_crawl" )
                        while ( not HasAnimSetLoaded( "move_crawl" ) ) do
                            Citizen.Wait( 100 )
                        end
                        ClearPedTasksImmediately(ped)
                        proned = true
                        if IsPedSprinting(ped) or IsPedRunning(ped) or GetEntitySpeed(ped) > 5 then
                            TaskPlayAnim(ped, "move_jump", "dive_start_run", 8.0, 1.0, -1, 0, 0.0, 0, 0, 0)
                            Citizen.Wait(1000)
                        end
                        SetProned()
                    end
                end
            end
        else
            proned = false
            crouched = false
        end
    end
end)

function SetProned()
    ped = PlayerPedId()
    ClearPedTasksImmediately(ped)
    TaskPlayAnimAdvanced(ped, "move_crawl", "onfront_fwd", GetEntityCoords(ped), 0.0, 0.0, GetEntityHeading(ped), 1.0, 1.0, 1.0, 46, 1.0, 0, 0)
end


function ProneMovement()
    if proned then
        ped = PlayerPedId()
        if IsControlPressed(0, 32) or IsControlPressed(0, 33) then
            DisablePlayerFiring(ped, true)
        elseif IsControlJustReleased(0, 32) or IsControlJustReleased(0, 33) then
            DisablePlayerFiring(ped, false)
        end
        if IsControlJustPressed(0, 32) and not movefwd then
            movefwd = true
            TaskPlayAnimAdvanced(ped, "move_crawl", "onfront_fwd", GetEntityCoords(ped), 1.0, 0.0, GetEntityHeading(ped), 1.0, 1.0, 1.0, 47, 1.0, 0, 0)
        elseif IsControlJustReleased(0, 32) and movefwd then
            TaskPlayAnimAdvanced(ped, "move_crawl", "onfront_fwd", GetEntityCoords(ped), 1.0, 0.0, GetEntityHeading(ped), 1.0, 1.0, 1.0, 46, 1.0, 0, 0)
            movefwd = false
        end
        if IsControlJustPressed(0, 33) and not movebwd then
            movebwd = true
            TaskPlayAnimAdvanced(ped, "move_crawl", "onfront_bwd", GetEntityCoords(ped), 1.0, 0.0, GetEntityHeading(ped), 1.0, 1.0, 1.0, 47, 1.0, 0, 0)
        elseif IsControlJustReleased(0, 33) and movebwd then
            TaskPlayAnimAdvanced(ped, "move_crawl", "onfront_bwd", GetEntityCoords(ped), 1.0, 0.0, GetEntityHeading(ped), 1.0, 1.0, 1.0, 46, 1.0, 0, 0)
            movebwd = false
        end
        if IsControlPressed(0, 34) then
            SetEntityHeading(ped, GetEntityHeading(ped)+2.0 )
        elseif IsControlPressed(0, 35) then
            SetEntityHeading(ped, GetEntityHeading(ped)-2.0 )
        end
    end
end

--infinite stamina
Citizen.CreateThread( function()
    while true do
        Citizen.Wait(0)
        RestorePlayerStamina(PlayerId(), 1.0)
    end
end)

-- DISPACHE
Citizen.CreateThread(function()
    for i = 1, 12 do
        Citizen.InvokeNative(0xDC0F817884CDD856, i, false)
    end
end)

--- VOZ
local playerNamesDist = 10

Citizen.CreateThread(function()
    while true do
        for id = 0, 31 do
            if  ((NetworkIsPlayerActive( id )) and GetPlayerPed( id ) ~= GetPlayerPed( -1 )) then
                ped = GetPlayerPed( id )

                x1, y1, z1 = table.unpack( GetEntityCoords( GetPlayerPed( -1 ), true ) )
                x2, y2, z2 = table.unpack( GetEntityCoords( GetPlayerPed( id ), true ) )
                distance = math.floor(GetDistanceBetweenCoords(x1,  y1,  z1,  x2,  y2,  z2,  true))
                local takeaway = 0.95

                if ((distance < playerNamesDist) and IsEntityVisible(GetPlayerPed(id))) ~= GetPlayerPed( -1 ) then
                    if NetworkIsPlayerTalking(id) then
                        DrawMarker(25,x2,y2,z2 - takeaway, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 10.3, 55, 160, 205, 105, 0, 0, 2, 0, 0, 0, 0)
                    else
                        DrawMarker(25, x2,y2,z2 - takeaway, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.5, 239, 239, 239, 50, 0, 0, 2, 0, 0, 0, 0)
                    end
                end
            end
        end
        Citizen.Wait(0)
    end
end)