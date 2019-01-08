-- Credits Marmota#2533

AddEventHandler("zrp_itemdrop:createBag", function(player, item, amount)
    local id = zRPclient.createBag(player)
    bags[id] = {item = item, amount = amount}
    SetTimeout(600000, function ()
        if bags[id] then
            bags[id] = nil
            TriggerClientEvent("zrp_itemdrop:deleteBag", -1, id)
        end
    end)
end)

RegisterServerEvent("zrp_itemdrop:takeBag")
AddEventHandler("zrp_itemdrop:takeBag", function(id)
    local source = source
    local user_id = zRP.getUserId(source)
    local bag = bags[id]
    if bag then
        if zRP.getInventoryWeight(user_id) + zRP.getItemWeight(bag.item) * bag.amount <= zRP.getInventoryMaxWeight(user_id) then
            zRP.giveInventoryItem(user_id, bag.item, bag.amount, true)
            zRPclient._playAnim(source, true, {{"pickup_object", "pickup_low", 1}}, false)
            bags[id] = nil
            TriggerClientEvent("zrp_itemdrop:deleteBag", -1, id)
        else
            zRPclient._notify(source, "~r~Sem espaco no inventario")
        end
    end
end)

function tzRP.verifyBag(id)
    return bags[id] ~= nil
end



