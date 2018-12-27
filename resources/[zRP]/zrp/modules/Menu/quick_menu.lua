---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Muulfz.
--- DateTime: 12/15/2018 11:33 PM
---

local lang = zRP.lang

function zRP.hasNearByPlayer(player)
    local player = zRPclient.getNearestPlayer(player,5)
    if player then
        return true
    end
    return false
end

function zRP.playerIsCitizen(nplayer)
    local player = zRP.getUserId(nplayer)
    if zRP.hasPermission(player, "police.menu") then
        return false
    end
    return true
end


zRP.registerMenuBuilder("quick_menu", function(add,data)
    local player = data.player
    local user_id = zRP.getUserId(player)
    if user_id then
        local choices = {}
        if zRP.hasNearByPlayer(player) then
            local nplayers = zRPclient.getNearestPlayers(player,5)
            for k,v in pairs(nplayers) do
                 local name = zRP.getPlayerName(k)
                choices[name] = { function(player, choice)
                    local menu = zRP.buildMenu(name, {player = player})
                    menu.name = name
                    menu.css = {top="75px",header_color="rgba(0,125,255,0.75)"}

                    if zRP.hasPermission(user_id,lang.basic_menu.fine.perm()) then
                        menu[lang.basic_menu.fine.button()] = {zRPMenu.police_fine, lang.basic_menu.fine.desc()} -- Fines closeby player
                    end
                   zRP.openMenu(player,menu)
                end}
            end
        end

        add(choices)
    end
end)