local players = {}

AddEventHandler("zRP:playerSpawn", function (user_id, source, first_spawn)
    if first_spawn then
        TriggerClientEvent("zrp_id_display:setTable", source, players)
        players[user_id] = source
        TriggerClientEvent("zrp_id_display:addPlayer", -1, user_id, source)
    end
end)

AddEventHandler("zRP:playerLeave", function (user_id, source)
    players[user_id] = nil
    TriggerClientEvent("zrp_id_display:removePlayer", -1, user_id)
end)