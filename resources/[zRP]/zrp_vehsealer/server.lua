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
            table.insert(client_vehicles, { class = k, model = string.upper(x), name = y.name, price = y.price, image = y.image })
        server_vehicles[string.upper(x)] = y
    end
end

--print(json.encode(server_vehicles))

SetTimeout(1000, function()
    --print(json.encode(client_cars), json.encode(client_classes))
    TriggerClientEvent("zrp_vehsealer:createTables", -1, client_vehicles, client_classes)
end)

function t.buyVehicle(model)
    local user_id = zRP.getUserId(source)
    local vehicle = server_vehicles[model]
    if user_id and vehicle then
        if user_has_vehicle(user_id, model) then
            return "Voce ja possui este veiculo"
        end
        if zRP.tryPayment(user_id, vehicle.price) then
            zRP.execute("zRP/add_vehicle", {user_id = user_id, vehicle = model})
            return "ok"
        end
        return "Dinheiro insuficiente"
    end
end

function t.buySaleVehicle(owner_id, model)
    local user_id = zRP.getUserId(source)
    if user_id then
        local vehicle = zRP.query("zRP/get_sale_vehicle", {user_id = owner_id, vehicle = model})[1]
        if vehicle then
            if user_has_vehicle(user_id, model) then
                return {"Voce ja possui este veiculo", generate_sale_vehicles(user_id)}
            end
            if zRP.tryPayment(user_id, vehicle.price) then
                zRP.execute("zRP/remove_sale_vehicle", {user_id = owner_id, vehicle = model})
                zRP.execute("zRP/add_full_vehicle", {user_id = user_id, vehicle = model, upgrades = vehicle.upgrades})
                if zRP.getUserSource(owner_id) then
                    zRP.giveBankMoney(owner_id, vehicle.price)
                else
                    local rows = zRP.query("zRP/get_money_json", {user_id = owner_id})
                    if #rows > 0 then
                        local user_money_json = json.decode(rows[1].money)
                        user_money_json.bank = user_money_json.bank + vehicle.price
                        zRP.execute("zRP/set_money_json", {user_id = owner_id, money = json.encode(user_money_json)})
                    end
                end
                return {"ok", generate_sale_vehicles(user_id)}
            end
            return {"Dinheiro insuficiente", generate_sale_vehicles(user_id)}
        end
        return {"Ocorreu um erro", generate_sale_vehicles(user_id)}
    end
end

function t.getPlayerVehicles()
    local user_id = zRP.getUserId(source)
    if user_id then
        return generate_user_not_seized_vehicles(user_id)
    end
end

function t.getSaleVehicles()
    return generate_sale_vehicles(zRP.getUserId(source))
end

function t.getSaleVehicle(model, user_id)
    if not user_id then
        user_id = zRP.getUserId(source)
    end
    local rows = zRP.query("zRP/get_sale_vehicle", {user_id = user_id, vehicle = model})
    return {price = rows[1].price or 0, description = rows[1].description or ""}
end

function t.editSaleVehicle(model, price, description)
    local user_id = zRP.getUserId(source)
    if user_id then
        zRP.execute("zRP/set_sale_vehicle", {user_id = user_id, vehicle = model, price = price, description = description})
        return {"ok", generate_sale_vehicles(user_id)}
    end
end

function t.removeSaleVehicle(model)
    local user_id = zRP.getUserId(source)
    if user_id then
        local user_vehicle = zRP.query("zRP/get_sale_vehicle", {user_id = user_id, vehicle = model})[1]
        zRP.execute("zRP/remove_sale_vehicle", {user_id = user_id, vehicle = model})
        if user_vehicle then
            zRP.execute("zRP/add_full_vehicle", {user_id = user_id, vehicle = model, upgrades = user_vehicle.upgrades})
        end
        return {"ok", generate_sale_vehicles(user_id)}
    end
end

function t.createAd(model, price, description)
    local user_id = zRP.getUserId(source)
    if user_id then
        local user_vehicle = zRP.query("zRP/get_full_vehicle", {user_id = user_id, vehicle = model})[1]
        if user_vehicle then
            zRP.execute("zRP/remove_vehicle", {user_id = user_id, vehicle = model})
            zRP.execute("zRP/add_sale_vehicle", {user_id = user_id, vehicle = model, price = price, description = description, upgrades = user_vehicle.upgrades or ""})
            return {"ok", generate_user_not_seized_vehicles(user_id)}
        end
    end
    return {"Ocorreu um erro"}
end



function user_has_vehicle(user_id, vehicle)
    for k, v in pairs(zRP.query("zRP/get_vehicles", {user_id = user_id})) do
        if string.upper(v.vehicle) == vehicle then
            return true
        end
    end
    for k, v in pairs(zRP.query("zRP/get_sale_vehicles", {user_id = user_id})) do
        if string.upper(v.vehicle) == vehicle then
            return true
        end
    end
    return false
end

function generate_user_not_seized_vehicles(user_id)
    local vehicles = {}
    for k, v in pairs(zRP.query("zRP/get_vehicles_unseized", {user_id = user_id})) do
        local model = string.upper(v.vehicle)
        local vehicle = server_vehicles[model]
        if vehicle then
            table.insert(vehicles, {model = model, name = vehicle.name, image = vehicle.image})
        end
    end
    return vehicles
end

function generate_sale_vehicles(user_id)
    local vehicles = {}
    for k, v in pairs(zRP.query("zRP/get_all_sale_vehicles", {})) do
        local model = string.upper(v.vehicle)
        local vehicle = server_vehicles[model]
        if user_id == v.user_id then
            v.user_id = 0
        end
        if vehicle then
            table.insert(vehicles, {model = model, owner_id = v.user_id, name = vehicle.name, price = v.price,description = v.description, image = vehicle.image})
        end
    end
    return vehicles
end