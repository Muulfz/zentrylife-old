local vehicles, classes

RegisterNetEvent("veh_sealer:createTables")
AddEventHandler("veh_sealer:createTables",function (rVehicles, rClasses)
    vehicles = rVehicles
    classes = rClasses
end)

RegisterNUICallback('veh_sealer/onLoad', function(data, cb)
    --print(json.encode({cars = vehicles, classes = classes}))
    cb({cars = vehicles, classes = classes})
end)

RegisterNUICallback('veh_sealer/buy', function(data, cb)
    cb(zRPIserver.buyVehicle(data.model))
end)

RegisterNUICallback('veh_sealer/buySaleVehicle', function(data, cb)
    cb(zRPIserver.buySaleVehicle(data.user_id ,data.model))
end)

RegisterNUICallback('veh_sealer/getVehicles', function (data, cb)
    cb(zRPIserver.getPlayerVehicles())
end)

RegisterNUICallback('veh_sealer/getSaleVehicles', function (data, cb)
    cb(zRPIserver.getSaleVehicles())
end)

RegisterNUICallback('veh_sealer/getSaleVehicle', function (data, cb)
    cb(zRPIserver.getSaleVehicle(data.model))
end)

RegisterNUICallback('veh_sealer/editSaleVehicle', function (data, cb)
    cb(zRPIserver.editSaleVehicle(data.model, data.price, data.description))
end)

RegisterNUICallback('veh_sealer/removeSaleVehicle', function (data, cb)
    cb(zRPIserver.removeSaleVehicle(data.model))
end)

RegisterNUICallback('veh_sealer/sell', function (data, cb)
    cb(zRPIserver.createAd(data.model, data.price, data.description))
end)