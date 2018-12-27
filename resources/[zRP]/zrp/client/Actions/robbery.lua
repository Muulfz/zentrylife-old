---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Muulfz.
--- DateTime: 12/19/2018 1:35 PM
---
local config = module("cfg/Client/Actions/robbery")

local distanceForMarkerToShow = 15
local distanceToInteractWithMarker = 1.5

local inCircle = false
local isRobbing = false
local spotBeingRobbed = nil

function tzRP.robbery_DebugMessage(msg)
    DisplayHelpText(msg)
end

function tzRP.robbery_StartRobbery(cops)
    local ongoingRobberies = 0
    for k, v in ipairs(config.robbableSpots) do
        if (v.beingRobbed) then
            ongoingRobberies = ongoingRobberies + 1
        end
    end
    if (cops < ongoingRobberies) then
        tzRP.notify("Nao ha policiais suficientes.")
        return
    end
    Citizen.CreateThread(function()
        if (cops >= spotBeingRobbed.copsNeeded) then
            zRPserver.robbery_StartedNotification(spotBeingRobbed.name)
            TaskPlayAnim(GetPlayerPed(-1), "mini@repair", "fixing_a_car", 8.0, 0.0, -1, 1, 0, 0, 0, 0)
            isRobbing = true
            spotBeingRobbed.beingRobbed = true
            config.robbableSpots[spotBeingRobbed.name] = spotBeingRobbed
            zRPserver.robbery_SyncSpots(config.robbableSpots)
            FreezeEntityPosition(GetPlayerPed(-1), true)
            local currentSecondCount = 0
            Citizen.CreateThread(function()
                while isRobbing do
                    if (spotBeingRobbed.isSafe) then
                        DisplayHelpText("Voce esta arrombando o cofrinho (" .. spotBeingRobbed.timeToRob - currentSecondCount .. " secondos restantes)")
                    else
                        DisplayHelpText("Voce esta arrombando a caixa registradora (" .. spotBeingRobbed.timeToRob - currentSecondCount .. " segundos restantes)")
                    end
                    Citizen.Wait(0)
                end
            end)
            while isRobbing do
                currentSecondCount = currentSecondCount + 1
                if (currentSecondCount == spotBeingRobbed.timeToRob) then
                    tzRP.robbery_Over()
                end
                Citizen.Wait(1000)
            end
        else
            tzRP.notify("Nao ha policiais suficientes.")
            return
        end
    end)
end

function tzRP.robbery_SyncSpotsClient(sports)
    config.robbableSpots = sports
end

function tzRP.robbery_StopRobbery()
    isRobbing = false
    spotBeingRobbed.beingRobbed = false
    config.robbableSpots[spotBeingRobbed.name] = spotBeingRobbed

    zRPserver.robbery_SyncSpots(config.robbableSpots)

end

function tzRP.robbery_Over()

end