---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Muulfz.
--- DateTime: 12/4/2018 4:42 PM
---
local lang = zRP.lang

function zRPMenu.thief_mug(player, nplayer)
    -- get nearest player
    local user_id = zRP.getUserId(player)
    if user_id ~= nil then
        local nplayer_check = zRPclient.getNearestPlayers(player, 15)
        local is_ok = false
        for k, v in pairs(nplayer_check) do
            if k == nplayer then
                is_ok = true
            end
        end
        if is_ok then
            local nuser_id = zRP.getUserId(nplayer)
            if nuser_id ~= nil then
                -- prompt number
                local nmoney = zRP.getMoney(nuser_id)
                local amount = nmoney
                if math.random(1, 3) == 1 then
                    if zRP.tryPayment(nuser_id, amount) then
                        zRPclient.notify(nplayer, lang.basic_menu.mugger.mugged({ amount }))
                        zRP.giveInventoryItem(user_id, "dirty_money", amount, true)
                    else
                        zRPclient.notify(player, lang.money.not_enough())
                    end
                else
                    zRPclient.notify(nplayer, lang.mugger.failed.good())
                    zRPclient.notify(player, lang.mugger.failed.bad())
                end
            else
                zRPclient.notify(player, lang.common.no_player_near())
            end
        else
            zRPclient.notify(player, lang.common.no_player_near())
        end
    end
end

function zRPMenu.thief_loot(player,nearestplayer)
    local user_id = zRP.getUserId(player)
    if user_id ~= nil then
        local nplayer_check = zRPclient.getNearestPlayer(player, 15)
        local nplayer = nearestplayer
        local is_ok
        for k, v in pairs(nplayer_check) do
            if k == nplayer then
                is_ok = true
            end
        end
        local nuser_id = zRP.getUserId(nplayer)
        if is_ok then
            local in_coma = zRPclient.isInComa(nplayer)
            if in_coma then
                local revive_seq = {
                    { "amb@medic@standing@kneel@enter", "enter", 1 },
                    { "amb@medic@standing@kneel@idle_a", "idle_a", 1 },
                    { "amb@medic@standing@kneel@exit", "exit", 1 }
                }
                zRPclient.playAnim(player, false, revive_seq, false) -- anim
                SetTimeout(15000, function()
                    local ndata = zRP.getUserDataTable(nuser_id)
                    if ndata ~= nil then
                        if ndata.inventory ~= nil then
                            -- gives inventory items
                            zRP.clearInventory(nuser_id)
                            for k, v in pairs(ndata.inventory) do
                                zRP.giveInventoryItem(user_id, k, v.amount, true)
                            end
                        end
                    end
                    local nmoney = zRP.getMoney(nuser_id)
                    if zRP.tryPayment(nuser_id, nmoney) then
                        zRP.giveMoney(user_id, nmoney)
                    end
                end)
                zRPclient.stopAnim(player, false)
            else
                zRPclient.notify(player, lang.basic_menu.emergency.menu.revive.not_in_coma())
            end
        else
            zRPclient.notify(player, lang.common.no_player_near())
        end
    end
end

function zRPMenu.thief_lockpickveh()
    local user_id = zRP.getUserId(player)
    local service = lang.service.group()
    if user_id ~= nil then
        if zRP.hasGroup(user_id, service) then
            zRP.removeUserGroup(user_id, service)
            if zRP.hasMission(player) then
                zRP.stopMission(player)
            end
            zRPclient.notify(player, lang.basic_menu.service.off())
        else
            zRP.addUserGroup(user_id, service)
            zRPclient.notify(player, lang.basic_menu.service.on())
        end
    end
end

zRP.defInventoryItem(lang.basic_menu.lockpick.id(), lang.basic_menu.lockpick.name(), lang.basic_menu.lockpick.desc(), -- add it for sale to zrp/cfg/markets.lua if you want to use it
        function(args)
            local choices = {}

            choices[lang.basic_menu.lockpick.button()] = { function(player, choice)
                local user_id = zRP.getUserId(player)
                if user_id ~= nil then
                    if zRP.tryGetInventoryItem(user_id, lang.basic_menu.lockpick.id(), 1, true) then
                        zRPclient.lockpickVehicle(player, 20, true) -- 20s to lockpick, allow to carjack unlocked vehicles (has to be true for NoCarJack Compatibility)
                        zRP.closeMenu(player)
                    end
                end
            end, lang.basic_menu.lockpick.desc() }

            return choices
        end,
        0.75)


function zRPMenu.player_robPlayer(player, choice)
    local user_id = zRP.getUserId(player)
    if user_id then
        local nPlayer = zRPclient.getNearestPlayer(player, 10)
        if nPlayer then
            if zRPclient.player_isHandsUp(nPlayer) then
                local nUser_id = zRP.getUserId(nPlayer)
                local nInventory = zRP.getInventory(nUser_id)
                local nWeapons = zRPclient.replaceWeapons(nPlayer, {})
                local nMoney = zRP.getMoney(nUser_id)
                zRP.clearInventory(nUser_id)
                if zRP.tryPayment(nUser_id, nMoney) then
                    zRP.giveMoney(user_id, nMoney)
                end
                for k, v in pairs(nInventory) do
                    zRP.giveInventoryItem(user_id, k, v.amount, true)
                end
                for k,v in pairs(nWeapons) do
                    zRP.giveInventoryItem(user_id, "wbody|"..k, 1, true)
                    if v.ammo > 0 then
                        zRP.giveInventoryItem(user_id, "wammo|"..k, v.ammo, true)
                    end
                end
                zRPclient.notify(nPlayer, lang.robber.victim.robbed)
                zRPclient.notify(player, lang.robber.robber.sucess)
            else
                zRPclient.notify(player, lang.robber.robber.notHandsUp)
                zRPclient.notify(nPlayer, lang.robber.victim.triedRob)
            end
        else
            zRPclient.notify(player, lang.robber.robber.noNearPlayers)
        end
    end
end