local langt = module("cfg/lang/client/" .. cfg.lang)
local lang = langt.basic_menu

local noclip = false
local noclip_speed = 1.0

function tzRP.toggleNoclip()
    noclip = not noclip
    local ped = GetPlayerPed(-1)
    if noclip then
        -- set
        SetEntityInvincible(ped, true)
        SetEntityVisible(ped, false, false)
    else
        -- unset
        SetEntityInvincible(ped, false)
        SetEntityVisible(ped, true, false)
    end
end

function tzRP.isNoclip()
    return noclip
end

function tzRP.runStringLocally(stringToRun)
    if (stringToRun) then
        local resultsString = ""
        -- Try and see if it works with a return added to the string
        local stringFunction, errorMessage = load("return " .. stringToRun)
        if (errorMessage) then
            -- If it failed, try to execute it as-is
            stringFunction, errorMessage = load(stringToRun)
        end
        if (errorMessage) then
            -- Shit tier code entered, return the error to the player
            TriggerEvent("chatMessage", "[SS-RunCode]", { 187, 0, 0 }, "CRun Error: " .. tostring(errorMessage))
            return false
        end
        -- Try and execute the function
        local results = { pcall(stringFunction) }
        if (not results[1]) then
            -- Error, return it to the player
            TriggerEvent("chatMessage", "[SS-RunCode]", { 187, 0, 0 }, "CRun Error: " .. tostring(results[2]))
            return false
        end

        for i = 2, #results do
            resultsString = resultsString .. ", "
            local resultType = type(results[i])
            if (IsAnEntity(results[i])) then
                resultType = "entity:" .. tostring(GetEntityType(results[i]))
            end
            resultsString = resultsString .. tostring(results[i]) .. " [" .. resultType .. "]"
        end
        if (#results > 1) then
            TriggerEvent("chatMessage", "[SS-RunCode]", { 187, 0, 0 }, "CRun Command Result: " .. tostring(resultsString))
            return true
        end
    end
end

function tzRP.tpToWaypoint()
    local targetPed = GetPlayerPed(-1)
    local targetVeh = GetVehiclePedIsUsing(targetPed)
    if (IsPedInAnyVehicle(targetPed)) then
        targetPed = targetVeh
    end

    if (not IsWaypointActive()) then
        tzRP.notify(lang.tptowaypoint.notfound) --lang.tptowaypoint.notfound()
        return
    end

    local waypointBlip = GetFirstBlipInfoId(8) -- 8 = waypoint Id
    local x, y, z = table.unpack(Citizen.InvokeNative(0xFA7C7F0AADF25D09, waypointBlip, Citizen.ResultAsVector()))

    -- ensure entity teleports above the ground
    local ground
    local groundFound = false
    local groundCheckHeights = { 100.0, 150.0, 50.0, 0.0, 200.0, 250.0, 300.0, 350.0, 400.0, 450.0, 500.0, 550.0, 600.0, 650.0, 700.0, 750.0, 800.0 }

    for i, height in ipairs(groundCheckHeights) do
        SetEntityCoordsNoOffset(targetPed, x, y, height, 0, 0, 1)
        Wait(10)

        ground, z = GetGroundZFor_3dCoord(x, y, height)
        if (ground) then
            z = z + 3
            groundFound = true
            break ;
        end
    end

    if (not groundFound) then
        z = 1000
        GiveDelayedWeaponToPed(PlayerPedId(), 0xFBAB5776, 1, 0) -- parachute
    end

    SetEntityCoordsNoOffset(targetPed, x, y, z, 0, 0, 1)
    tzRP.notify(lang.tptowaypoint.success) -- lang.tptowaypoint.success()
end

function tzRP.spawnVehicle(model, notify)
    -- load vehicle model
    local i = 0
    local mhash = GetHashKey(model)
    while not HasModelLoaded(mhash) and i < 1000 do
        if math.fmod(i, 100) == 0 then
            if notify then
                tzRP.notify(lang.spawnveh.load) -- lang.spawnveh.load()
            end
        end
        RequestModel(mhash)
        Citizen.Wait(30)
        i = i + 1
    end

    -- spawn car if model is loaded
    if HasModelLoaded(mhash) then
        local x, y, z = tzRP.getPosition({})
        local nveh = CreateVehicle(mhash, x, y, z + 0.5, GetEntityHeading(GetPlayerPed(-1)), true, false) -- added player heading
        SetVehicleOnGroundProperly(nveh)
        SetEntityInvincible(nveh, false)
        SetPedIntoVehicle(GetPlayerPed(-1), nveh, -1) -- put player inside
        Citizen.InvokeNative(0xAD738C3085FE7E11, nveh, true, true) -- set as mission entity
        SetVehicleHasBeenOwnedByPlayer(nveh, true)
        SetModelAsNoLongerNeeded(mhash)
        if notify then
            tzRP.notify(lang.spawnveh.success) -- lang.spawnveh.success()
        end
    else
        if notify then
            tzRP.notify(lang.spawnveh.invalid) -- lang.spawnveh.invalid()
        end
    end
end

function tzRP.deleteVehicleInFrontOrInside(offset, notify)
    local ped = GetPlayerPed(-1)
    local veh = nil
    if (IsPedSittingInAnyVehicle(ped)) then
        veh = GetVehiclePedIsIn(ped, false)
    else
        veh = tzRP.getVehicleInDirection(GetEntityCoords(ped, 1), GetOffsetFromEntityInWorldCoords(ped, 0.0, offset, 0.0))
    end

    if IsEntityAVehicle(veh) then
        SetVehicleHasBeenOwnedByPlayer(veh, false)
        Citizen.InvokeNative(0xAD738C3085FE7E11, veh, false, true) -- set not as mission entity
        SetVehicleAsNoLongerNeeded(Citizen.PointerValueIntInitialized(veh))
        Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(veh))
        if notify then
            tzRP.notify(lang.deleteveh.success) -- lang.deleteveh.success()
        end
    else
        if notify then
            tzRP.notify(lang.deleteveh.toofar) -- lang.deleteveh.toofar()
        end
    end
end

local isRadarExtended = false
local showblip = false
local showsprite = false

function tzRP.showBlips()
    showblip = not showblip
    if showblip then
        showsprite = true
        tzRP.notify(lang.blips.on) -- lang.blips.on()
    else
        showsprite = false
        tzRP.notify(lang.blips.off) -- lang.blips.off()
    end
end

function tzRP.showSprites()
    showsprite = not showsprite
    if showsprite then
        tzRP.notify(lang.sprites.on) -- lang.sprites.on()
    else
        tzRP.notify(lang.sprites.off) -- lang.sprites.off()
    end
end

-- noclip/invisibility
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if noclip then
            local ped = GetPlayerPed(-1)
            local x, y, z = tzRP.getPosition()
            local dx, dy, dz = tzRP.getCamDirection()
            local speed = noclip_speed

            -- reset velocity
            SetEntityVelocity(ped, 0.0001, 0.0001, 0.0001)

            -- forward
            if IsControlPressed(0, 32) then
                -- MOVE UP
                x = x + speed * dx
                y = y + speed * dy
                z = z + speed * dz
            end

            -- backward
            if IsControlPressed(0, 269) then
                -- MOVE DOWN
                x = x - speed * dx
                y = y - speed * dy
                z = z - speed * dz
            end

            SetEntityCoordsNoOffset(ped, x, y, z, true, true, true)
        end
    end
end)

Citizen.CreateThread(function()

    while true do

        Wait(1)

        --[[ extend minimap on keypress
        if IsControlJustPressed( 0, 20 ) then

            if not isRadarExtended then

                SetRadarBigmapEnabled( true, false )
                isRadarExtended = true

                Citizen.CreateThread(function()

                    run = true

                    while run do

                        for i = 0, 500 do

                            Wait(1)

                            if not isRadarExtended then

                                run = false
                                break

                            end

                        end

                        SetRadarBigmapEnabled( false, false )
                        isRadarExtended = false

                    end

                end)

            else

                SetRadarBigmapEnabled( false, false )
                isRadarExtended = false

            end

        end]]

        -- show blips
        for id = 0, 64 do

            if NetworkIsPlayerActive(id) and GetPlayerPed(id) ~= GetPlayerPed(-1) then

                local ped = GetPlayerPed(id)
                local blip = GetBlipFromEntity(ped)

                -- HEAD DISPLAY STUFF --

                -- Create head display (this is safe to be spammed)
                local headId = Citizen.InvokeNative(0xBFEFE3321A3F5015, ped, GetPlayerName(id), false, false, "", false)
                local wantedLvl = GetPlayerWantedLevel(id)

                if showsprite then
                    Citizen.InvokeNative(0x63BB75ABEDC1F6A0, headId, 0, true) -- Add player name sprite
                    -- Wanted level display
                    if wantedLvl then

                        Citizen.InvokeNative(0x63BB75ABEDC1F6A0, headId, 7, true) -- Add wanted sprite
                        Citizen.InvokeNative(0xCF228E2AA03099C3, headId, wantedLvl) -- Set wanted number

                    else

                        Citizen.InvokeNative(0x63BB75ABEDC1F6A0, headId, 7, false) -- Remove wanted sprite

                    end

                    -- Speaking display
                    if NetworkIsPlayerTalking(id) then

                        Citizen.InvokeNative(0x63BB75ABEDC1F6A0, headId, 9, true) -- Add speaking sprite

                    else

                        Citizen.InvokeNative(0x63BB75ABEDC1F6A0, headId, 9, false) -- Remove speaking sprite

                    end
                else
                    Citizen.InvokeNative(0x63BB75ABEDC1F6A0, headId, 7, false) -- Remove wanted sprite
                    Citizen.InvokeNative(0x63BB75ABEDC1F6A0, headId, 9, false) -- Remove speaking sprite
                    Citizen.InvokeNative(0x63BB75ABEDC1F6A0, headId, 0, false) -- Remove player name sprite
                end
                if showblip then
                    -- BLIP STUFF --

                    if not DoesBlipExist(blip) then
                        -- Add blip and create head display on player

                        blip = AddBlipForEntity(ped)
                        SetBlipSprite(blip, 1)
                        Citizen.InvokeNative(0x5FBCA48327B914DF, blip, true) -- Player Blip indicator

                    else
                        -- update blip

                        local veh = GetVehiclePedIsIn(ped, false)
                        local blipSprite = GetBlipSprite(blip)

                        if not GetEntityHealth(ped) then
                            -- dead

                            if blipSprite ~= 274 then

                                SetBlipSprite(blip, 274)
                                Citizen.InvokeNative(0x5FBCA48327B914DF, blip, false) -- Player Blip indicator

                            end

                        elseif veh then

                            local vehClass = GetVehicleClass(veh)
                            local vehModel = GetEntityModel(veh)

                            if vehClass == 15 then
                                -- jet

                                if blipSprite ~= 422 then

                                    SetBlipSprite(blip, 422)
                                    Citizen.InvokeNative(0x5FBCA48327B914DF, blip, false) -- Player Blip indicator

                                end

                            elseif vehClass == 16 then
                                -- plane

                                if vehModel == GetHashKey("besra") or vehModel == GetHashKey("hydra")
                                        or vehModel == GetHashKey("lazer") then
                                    -- jet

                                    if blipSprite ~= 424 then

                                        SetBlipSprite(blip, 424)
                                        Citizen.InvokeNative(0x5FBCA48327B914DF, blip, false) -- Player Blip indicator

                                    end

                                elseif blipSprite ~= 423 then

                                    SetBlipSprite(blip, 423)
                                    Citizen.InvokeNative(0x5FBCA48327B914DF, blip, false) -- Player Blip indicator

                                end

                            elseif vehClass == 14 then
                                -- boat

                                if blipSprite ~= 427 then

                                    SetBlipSprite(blip, 427)
                                    Citizen.InvokeNative(0x5FBCA48327B914DF, blip, false) -- Player Blip indicator

                                end

                            elseif vehModel == GetHashKey("insurgent") or vehModel == GetHashKey("insurgent2")
                                    or vehModel == GetHashKey("limo2") then
                                -- insurgent (+ turreted limo cuz limo blip wont work)

                                if blipSprite ~= 426 then

                                    SetBlipSprite(blip, 426)
                                    Citizen.InvokeNative(0x5FBCA48327B914DF, blip, false) -- Player Blip indicator

                                end

                            elseif vehModel == GetHashKey("rhino") then
                                -- tank

                                if blipSprite ~= 421 then

                                    SetBlipSprite(blip, 421)
                                    Citizen.InvokeNative(0x5FBCA48327B914DF, blip, false) -- Player Blip indicator

                                end

                            elseif blipSprite ~= 1 then
                                -- default blip

                                SetBlipSprite(blip, 1)
                                Citizen.InvokeNative(0x5FBCA48327B914DF, blip, true) -- Player Blip indicator

                            end

                            -- Show number in case of passangers
                            local passengers = GetVehicleNumberOfPassengers(veh)

                            if passengers then

                                if not IsVehicleSeatFree(veh, -1) then

                                    passengers = passengers + 1

                                end

                                ShowNumberOnBlip(blip, passengers)

                            else

                                HideNumberOnBlip(blip)

                            end

                        else

                            -- Remove leftover number
                            HideNumberOnBlip(blip)

                            if blipSprite ~= 1 then
                                -- default blip

                                SetBlipSprite(blip, 1)
                                Citizen.InvokeNative(0x5FBCA48327B914DF, blip, true) -- Player Blip indicator

                            end

                        end

                        SetBlipRotation(blip, math.ceil(GetEntityHeading(veh))) -- update rotation
                        SetBlipNameToPlayerName(blip, id) -- update blip name
                        SetBlipScale(blip, 0.85) -- set scale

                        -- set player alpha
                        if IsPauseMenuActive() then

                            SetBlipAlpha(blip, 255)

                        else

                            local x1, y1 = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
                            local x2, y2 = table.unpack(GetEntityCoords(GetPlayerPed(id), true))
                            local distance = (math.floor(math.abs(math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))) / -1)) + 900
                            -- Probably a way easier way to do this but whatever im an idiot

                            if distance < 0 then

                                distance = 0

                            elseif distance > 255 then

                                distance = 255

                            end

                            SetBlipAlpha(blip, distance)

                        end
                    end
                else
                    RemoveBlip(blip)
                end

            end

        end

    end
end)