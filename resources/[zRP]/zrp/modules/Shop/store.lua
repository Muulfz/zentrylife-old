---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Muulfz and Marmota.
--- DateTime: 12/10/2018 11:12 PM
---


local lang = zRP.lang
local cfg = module("cfg/Modules/Shop/stores")

zRP.stores = {}

Citizen.CreateThread(function()
    for k, v in pairs(cfg.store_config) do
        local ismanager = false
        if v["dbmanager"] then
            ismanager = v["dbmanager"]
        end
        if not zRP.storeExistsOnDB(k) then
            zRP.execute("zRP/create_store", { id = k, data = json.encode(v), dbmanager = ismanager })
        end
        if not ismanager then
            zRP.store[k] = v
        end
    end

    local stores = zRP.getStoresDB()
    if #stores > 0 then
        for i = 1, #stores do
            local name = stores[i].id
            --add na tabela
            zRP.stores = {name = json.decode(stores[i].data)}
        end
    end
    zRP.updateStores(zRP.stores)
end)

function zRP.updateStores(table)
--update tabela
end


function zRP.getStoresDB()
    local rows = zRP.query("zRP/get_stores_db")
    return rows
end

function zRP.storeExistsOnDB(id)
    local rows = zRP.query("zRP/get_stores")
    for k, v in pairs(rows[1]) do
        if k == id then
            return true
        end
    end
    return false
end

function zRP.getStoreData(id)
    local rows = zRP.query("zRP/get_store", { id = id })
    return rows
end

--[[
Citizen.CreateThread(function ()
    for k, v in pairs(cfg.coords) do
        local key = "zRP:store:" .. k
        local data = json.decode(zRP.getSData(key))
        if data then
            for i, x in pairs(data.coords) do
                if x ~= v[i]  then
                    data = {coords = {v[1], v[2], v[3]}, items = {}, cash = 0, title = "Store"}
                    break
                end
            end
        else
            data = {coords = {v[1], v[2], v[3]}, items = {}, cash = 0, title = "Store"}
        end
        stores[key] = data
    end
end)


local function build_itemlist_menu(name, items, cb, type)
    local menu = { name = name, css = { top = "75px", header_color = "rgba(0,255,125,0.75)" } }

    local kitems = {}

    -- choice callback
    local choose = function(player, choice)
        local idname = kitems[choice]
        if idname then
            cb(idname)
        end
    end

    -- add each item to the menu
    for k, v in pairs(items) do
        local name, description, weight = zRP.getItemDefinition(k)
        if name then
            kitems[name] = k -- reference item by display name
            if type == "store" then
                menu[name] = { choose, lang.player_store.info({ v.value, v.amount, string.format("%.2f", weight) }) }
            else
                menu[name] = { choose, lang.inventory.iteminfo({ v.amount, description,string.format("%.2f", weight) }) }
            end
        end
    end

    return menu
end

function build_client_stores(source)
    local user_id = zRP.getUserId(source)
    if user_id then
        for n, m in pairs(cfg.coords) do
            local x, y, z, buyPrice = table.unpack(m)
            local close_count = 0
            local function store_enter(source, name)
                local store = stores[name]
                local menu = { name = store.title, css = { top = "75px", header_color = "rgba(0,255,125,0.75)" }}
                if store.ownerId then
                    menu = build_itemlist_menu(store.title, store.items, function(choice)
                        if store.ownerId == user_id then
                            local submenu = { name = zRP.getItemName(choice), css = { top = "75px", header_color = "rgba(0,255,125,0.75)" }}
                            submenu[lang.player_store.item.changePrice.title()]= {function ()
                                local value = parseInt(zRP.prompt(source, lang.player_store.item.changePrice.prompt(), ""))
                                if value > 0 then
                                    local item = store.items[choice]
                                    item.value = value
                                else
                                    zRPclient.notify(source, lang.player_store.item.changePrice.failed.invalid())
                                end
                            end, lang.player_store.item.changePrice.description()}
                            submenu[lang.player_store.item.getAmount.title()]= {function ()
                                local item = store.items[choice]
                                local amount = parseInt(zRP.prompt(source, lang.player_store.item.getAmount.prompt({item.amount}), ""))
                                if amount > 0 then
                                    if item.amount >= amount then
                                        zRP.giveInventoryItem(user_id, choice, amount, "")
                                        item.amount = item.amount - amount
                                        if item.amount <= 0 then
                                            store.items[choice] = nil
                                        end
                                    else
                                        zRPclient.notify(source, lang.player_store.item.getAmount.failed.noStock())
                                    end
                                else
                                    zRPclient.notify(source, lang.player_store.item.getAmount.failed.invalid())
                                end
                            end, lang.player_store.item.getAmount.description()}

                            submenu.onclose = function ()
                                if close_count == 1 then
                                    close_count = close_count - 1
                                    store_enter(source, name)
                                end

                            end

                            close_count = close_count + 1
                            zRP.openMenu(source, submenu)
                        else
                            local item = store.items[choice]
                            local amount = parseInt(zRP.prompt(source, lang.player_store.item.buy.prompt({item.amount}), ""))
                            if amount > 0 then
                                if item.amount >= amount then
                                    if zRP.tryPayment(user_id, item.value*amount) then
                                        zRP.giveInventoryItem(user_id, choice, amount, true)
                                        store.cash = store.cash + item.value*amount
                                        item.amount = item.amount - amount
                                        if item.amount <= 0 then
                                            store.items[choice] = nil
                                        end
                                        store_enter(source, name)
                                    else
                                        zRPclient.notify(source, lang.player_store.item.buy.failed.notEnoughMoney())
                                    end
                                end
                            end
                        end
                    end, "store")
                    if store.ownerId == user_id then
                        menu[lang.player_store.item.add.title()] = { function ()
                            local submenu = build_itemlist_menu(lang.player_store.item.add.title(), zRP.getInventory(user_id), function(choice)
                                local amount = parseInt(zRP.prompt(source, lang.player_store.item.add.prompt.amount({zRP.getInventoryItemAmount(user_id, choice)}), ""))
                                if amount > 0 then
                                    local value = parseInt(zRP.prompt(source, lang.player_store.item.add.prompt.price(), ""))
                                    if value > 0 then
                                        if zRP.tryGetInventoryItem(user_id, choice, amount, true) then
                                            if store.items[choice] == nil then
                                                store.items[choice] = { value = value, amount = amount }
                                            else
                                                store.items[choice] = { value = value, amount = store.items[choice].amount + amount }
                                            end
                                            menu[lang.player_store.item.add.title()][1]()
                                            zRPclient.notify(source, lang.player_store.item.add.success())
                                        else
                                            zRPclient.notify(source, lang.player_store.item.add.failed.invalid())
                                        end
                                    else
                                        zRPclient.notify(source, lang.player_store.item.add.failed.invalid())
                                    end
                                else
                                    zRPclient.notify(source, lang.player_store.item.add.failed.invalid())
                                end
                            end, lang.player_store.item.add.description())

                            submenu.onclose = function ()
                                if close_count == 1 then
                                    close_count = close_count - 1
                                    store_enter(source, name)
                                else
                                    close_count = 1
                                end
                            end
                            close_count = close_count + 1
                            zRP.openMenu(source, submenu)
                        end, lang.player_store.item.add.description()}
                        menu[lang.player_store.getCash.title()] = {function ()
                            zRP.giveMoney(user_id, store.cash)
                            store.cash = 0
                            store_enter(source, name)
                        end, lang.player_store.getCash.description({store.cash})}
                    end
                    local items_amount = 0
                    for k, v in pairs(store.items) do
                        items_amount = items_amount + 1
                    end
                    if items_amount == 0 and store.ownerId ~= user_id then
                        menu[lang.player_store.item.none.title()] = {function () end, lang.player_store.item.none.description()}
                    end
                else
                    menu[lang.player_store.buyStore.title()] = {function()
                        if zRP.request(source, lang.player_store.buyStore.request({buyPrice}), 60) then
                            local store_name = zRP.prompt(source, lang.player_store.buyStore.prompt(), "")
                            if store_name ~= "" then
                                if zRP.tryPayment(user_id, buyPrice) then
                                    store.ownerId = user_id
                                    store.title = store_name
                                    zRPclient.notify(source, lang.player_store.buyStore.success())
                                    store_enter(source, name)
                                else
                                    zRPclient.notify(source, lang.player_store.buyStore.failed.notEnoughMoney())
                                end
                            else
                                zRPclient.notify(source, lang.player_store.buyStore.failed.invalid())
                            end
                        end
                    end, lang.player_store.buyStore.description({buyPrice})}
                end
                zRP.openMenu(source, menu)
            end

            local function store_leave(source)
                close_count = 0
                zRP.closeMenu(source)
            end

            zRPclient._addBlip(source, x, y, z, cfg.blipId, cfg.blipColor, "Store")
            zRPclient._addMarker(source, x, y, z - 1, 0.7, 0.7, 0.5, 0, 255, 125, 125, 150)
            zRP.setArea(source, "zRP:store:" .. n, x, y, z, 1, 1.5, store_enter, store_leave)
        end
    end
end

AddEventHandler("zRP:playerSpawn", function(user_id, source, first_spawn)
    if first_spawn then
        build_client_stores(source)
    end
end)

AddEventHandler("zRP:save", function ()
    for k, v in pairs(stores) do
        zRP.setSData(k, json.encode(v))
    end
end)
--]]