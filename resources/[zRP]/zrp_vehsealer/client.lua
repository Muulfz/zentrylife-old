
local Tunnel = module("zrp","lib/Tunnel")

local tServer = Tunnel.getInterface("zrp_vehsealer", "zrp_vehsealer")

local menuEnabled = false

function toggleMenu()
    menuEnabled = not menuEnabled
    SetNuiFocus(menuEnabled,menuEnabled)
    SendNUIMessage({
        show = menuEnabled
    })
end

RegisterNetEvent("zrp_vehsealer:createTables")
AddEventHandler("zrp_vehsealer:createTables",function (cars, classes)
    --print(json.encode(cars), json.encode(classes))
    SetTimeout(1000, function ()
        SendNUIMessage({
            func = 'create',
            cars = cars,
            classes = classes
        })
    end)
end)

Citizen.CreateThread(function ()
    while true do
        Wait(0)
        if not menuEnabled then
            SetNuiFocus(false, false)
        end
        if IsControlJustReleased(1--[[input group]],  51--[[control index]]) then
            toggleMenu()
        end
    end
end)

RegisterNUICallback('close', function(data, cb)
    toggleMenu()
end)

RegisterNUICallback('buy', function(data, cb)
    cb(tServer.buyVehicle(data.model))
end)

RegisterNUICallback('buySaleVehicle', function(data, cb)
    cb(tServer.buySaleVehicle(data.user_id ,data.model))
end)

RegisterNUICallback('getVehicles', function (data, cb)
    cb(tServer.getPlayerVehicles())
end)

RegisterNUICallback('getSaleVehicles', function (data, cb)
    cb(tServer.getSaleVehicles())
end)

RegisterNUICallback('getSaleVehicle', function (data, cb)
    cb(tServer.getSaleVehicle(data.model))
end)

RegisterNUICallback('editSaleVehicle', function (data, cb)
    cb(tServer.editSaleVehicle(data.model, data.price, data.description))
end)

RegisterNUICallback('removeSaleVehicle', function (data, cb)
    cb(tServer.removeSaleVehicle(data.model))
end)

RegisterNUICallback('sell', function (data, cb)
    cb(tServer.createAd(data.model, data.price, data.description))
end)