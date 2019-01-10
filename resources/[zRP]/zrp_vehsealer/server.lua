local Proxy = module("zrp", "lib/Proxy")
local Tunnel = module("zrp", "lib/Tunnel")

local cfg = module("zrp_vehsealer", "Config")

local zRP = Proxy.getInterface("zRP", "zrp_vehsealer")

local t = {}

Tunnel.bindInterface("zrp_vehsealer", t)

local client_vehicles = {}
local client_classes = {}

local server_vehicles = {}

for k, v in pairs(cfg.cars) do
    table.insert(client_classes, k)
    for x, y in pairs(v) do
        table.insert(client_vehicles, { class = k, model = string.lower(x), name = y.name, price = y.price, image = y.image })
        server_vehicles[string.lower(x)] = y
    end
end

--print(json.encode(server_vehicles))

SetTimeout(1000, function()
    --print(json.encode(client_cars), json.encode(client_classes))
    TriggerClientEvent("zrp_vehsealer:createTables", -1, client_vehicles, client_classes)
end)

function t.buyVehicle(model)
    local source = source
    local user_id = zRP.getUserId(source)
    local vehicle = server_vehicles[model]
    if user_id and vehicle then
        for k, v in pairs(zRP.query("zRP/get_vehicles", { user_id = user_id })) do
            if string.lower(v.vehicle) == model then
                return "Voce ja possui este veiculo"
            end
        end
        for k, v in pairs(zRP.query("zRP/get_sale_vehicles", { user_id = user_id })) do
            if string.lower(v.vehicle) == model then
                return "Voce ja possui este veiculo"
            end
        end
        if zRP.tryFullPayment(user_id, vehicle.price) then
            zRP.execute("zRP/add_vehicle", { user_id = user_id, vehicle = model })
            return 'ok'
        end
        return "Voce nao tem dinheiro suficiente"
    end
end

function t.getPlayerVehicles()
    local source = source
    local user_id = zRP.getUserId(source)
    if user_id then
        local pVehicles = zRP.query("zRP/get_vehicles_unseized", {user_id = user_id})
        if #pVehicles > 0 then
            local vehicles = {}
            for k, v in pairs(pVehicles) do
                local model = string.lower(v.vehicle)
                local vehicle = server_vehicles[model]
                if vehicle then
                    table.insert(vehicles, { model = model, name = vehicle.name, image = vehicle.image })
                end
            end
            return vehicles
        end
    end
    return {}
end

function t.getSaleVehicles()
    local user_id = zRP.getUserId(source)
    if user_id then
        local vehicles = {}
        for k, v in pairs(zRP.query("zRP/get_all_sale_vehicles", {})) do
            local model = string.lower(v.vehicle)
            local vehicle = server_vehicles[model]
            if user_id == v.user_id then
                v.user_id = 0
            end
            table.insert(vehicles, {model = model, owner_id = v.user_id, name = vehicle.name, price = v.price,description = v.description, image = vehicle.image})
        end
        return vehicles
    end
    return {}
end

function t.getSaleVehicle(model, user_id)
    if not user_id then
        user_id = zRP.getUserId(source)
    end
    local rows = zRP.query("zRP/get_sale_vehicle", {user_id = 1, vehicle = model})
    return {price = rows[1].price or 0, description = rows[1].description or ""}
end

function t.editSaleVehicle(model, price, description)
    local user_id = zRP.getUserId(source)
    if user_id then
        zRP.execute("zRP/set_sale_vehicle", {user_id = user_id, vehicle = model, price = price, description = description})
        local vehicles = {}
        for k, v in pairs(zRP.query("zRP/get_all_sale_vehicles", {})) do
            local model = string.lower(v.vehicle)
            local vehicle = server_vehicles[model]
            if user_id == v.user_id then
                v.user_id = 0
            end
            table.insert(vehicles, {model = model, owner_id = v.user_id, name = vehicle.name, price = v.price,description = v.description, image = vehicle.image})
        end
        return 'ok', vehicles
    end
end

function t.removeSaleVehicle(model)
    local user_id = zRP.getUserId(source)
    if user_id then
        local user_vehicle = zRP.query("zRP/get_remove_sale_vehicle", {user_id = user_id, vehicle = model})[1]
        local vehicles = {}
        for k, v in pairs(zRP.query("zRP/get_all_sale_vehicles", {})) do
            local model = string.lower(v.vehicle)
            local vehicle = server_vehicles[model]
            if user_id == v.user_id then
                v.user_id = 0
            end
            table.insert(vehicles, {model = model, owner_id = v.user_id, name = vehicle.name, price = v.price,description = v.description, image = vehicle.image})
        end
        if user_vehicle then
            zRP.execute("zRP/add_full_vehicle", {user_id = user_id, vehicle = model, upgrades = user_vehicle.upgrades})
        end
        return 'ok', vehicles
    end
end

function t.createAd(model, price, description)
    local source = source
    local user_id = zRP.getUserId(source)
    if user_id then
        local user_vehicle = zRP.query("zRP/get_remove_vehicle", { user_id = user_id, vehicle = model })[1]
        zRP.execute("zRP/add_sale_vehicle", { user_id = user_id, vehicle = model, price = price, description = description, upgrades = user_vehicle.upgrades or "" })
        local vehicles = {}
        for k, v in pairs(zRP.query("zRP/get_vehicles_unseized", { user_id = user_id })) do
            local veh_model = string.lower(v.vehicle)
            local vehicle = server_vehicles[veh_model]
            table.insert(vehicles, { model = veh_model, name = vehicle.name, image = vehicle.image })
        end
        return 'ok', vehicles
    end
    return "Ocorreu um erro"
end