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

function zRP.getNearestVehicle(player)
    local veh = zRPclient._getNearestVehicle(player,10)
    return veh
end

zRP.registerMenuBuilder("quick_menu", function(add,data)
    local player = data.player
    local user_id = zRP.getUserId(player)
    local is_block = zRPclient.isPlayerBlockFull(player)
    local veh = zRPclient.getNerestVehicleInfo(player)
    if user_id then
        local choices = {}

        --------------------------------------------------------------
        ---                        [MAIN]                          ---
        --------------------------------------------------------------
        if not is_block then
            if zRP.hasPermission(user_id,lang.basic_menu.player.perm()) then
                choices[lang.basic_menu.player.button()] = { function(player, choice) zRPMenu.player_menu(player, choice) end,lang.basic_menu.player.desc()} -- opens player submenu
            end

            if zRP.hasPermission(user_id,"player.phone") then
                choices[lang.phone.title()] = {function() zRP.openMenu(player,zRPMenu.basic_phone()) end}
            end

        end
        --------------------------------------------------------------
        ---                      [Player Near]                     ---
        --------------------------------------------------------------
        if zRP.hasNearByPlayer(player) then
            local nplayers = zRPclient.getNearestPlayers(player,10)
            local number = 0
            for k,v in pairs(nplayers) do
                number = number + 1
                local name = zRP.getUserIdentityForTable(zRP.getUserId(k)).firstname
                name = number.." - "..name
                choices[name] = { function(player, choice)
                    local menu = zRP.buildMenu(name, {player = player})
                    menu.name = name
                    menu.css = {top="75px",header_color="rgba(0,125,255,0.75)"}
                    menu.onclose = function(player) zRP.openQuickMenu(player) end -- nest menu
                    if not is_block then
                        if zRP.hasPermission(user_id,lang.basic_menu.fine.perm()) then
                            menu[lang.basic_menu.fine.button()] = { function() zRPMenu.police_fine(player,k) end, lang.basic_menu.fine.desc()} -- Fines closeby player
                        end
                        if zRP.hasPermission(user_id,lang.basic_menu.fine.perm()) and zRPclient.isInComa(k) then
                            menu[lang.basic_menu.loot.button()] = { function() zRPMenu.thief_loot(player,k) end, lang.basic_menu.loot.desc()} -- take the items of nearest player in coma
                        end
                        if zRP.hasPermission(user_id,lang.basic_menu.mugger.perm()) then
                            menu[lang.basic_menu.mugger.button()] = { function() zRPMenu.thief_mug(player,k) end, lang.basic_menu.mugger.desc()} -- steal nearest player wallet
                        end
                        if zRP.hasPermission(user_id,lang.inspect.perm()) then
                            menu[lang.inspect.button()] = { function() zRPMenu.player_playerCheck(player,k) end, lang.inspect.desc()} -- checks nearest player inventory, like police check from zrp
                        end
                        if zRP.hasPermission(user_id,lang.basic_menu.freeze.perm()) then
                            menu[lang.basic_menu.freeze.button()] = { function() zRPMenu.police_freeze_name(player,k) end, lang.basic_menu.freeze.desc()} -- Toggle freeze
                        end
                        if zRP.hasPermission(user_id,"emergency.revive") and zRPclient.isInComa(k) then
                            menu[lang.emergency.menu.revive.title()] = { function() zRPMenu.choice_revive(player,k) end, lang.emergency.menu.revive.description() }
                        end
                        if zRPclient.isHandcuffed(k) then
                            if zRP.hasPermission(user_id,lang.basic_menu.jail.perm()) then
                                menu[lang.basic_menu.jail.button()] = { function() zRPMenu.police_jail(player, k) end, lang.basic_menu.jail.desc()} -- Send a nearby handcuffed player to jail with prompt for choice and user_list
                            end

                            if zRP.hasPermission(user_id,lang.basic_menu.drag.perm()) then
                                menu[lang.basic_menu.drag.button()] = { function() zRPMenu.police_drag(player,k) end, lang.basic_menu.drag.desc()} -- Drags closest handcuffed player
                            end

                            if zRP.hasPermission(user_id,lang.basic_menu.cuff.perm()) then
                                menu["DES ALGEMAR"] = { function()zRPMenu.police_handcuff(player,k)end, lang.basic_menu.handcuff.desc()} -- Toggle cuffs AND CLOSE MENU for nearby player
                            end

                            if zRP.hasPermission(user_id, "police.putinveh") and veh then
                                menu[lang.police.menu.putinveh.title()] = { function() zRPMenu.police_putinveh(player,k,veh) end, lang.police.menu.putinveh.description() }
                            end
                            if zRP.hasPermission(user_id, "police.getoutveh") then
                                menu[lang.police.menu.getoutveh.title()] = { function()zRPMenu.police_getoutveh(player,k)end, lang.police.menu.getoutveh.description() }
                            end
                        else
                            if zRP.hasPermission(user_id,lang.basic_menu.cuff.perm()) then
                                menu[lang.basic_menu.cuff.button()] = { function()zRPMenu.police_handcuff(player,k)end, lang.basic_menu.handcuff.desc()} -- Toggle cuffs AND CLOSE MENU for nearby player
                            end
                        end
                        if zRP.hasPermission(user_id, "police.check") then
                            menu[lang.police.menu.check.title()] = { function() zRPMenu.police_check(player,k) end, lang.police.menu.check.description()}
                        end
                        if zRP.hasPermission(user_id, "police.seize.weapons") then
                            menu[lang.police.menu.seize.weapons.title()] = { function() zRPMenu.police_seize_weapons(player,k) end, lang.police.menu.seize.weapons.description() }
                        end

                        if zRP.hasPermission(user_id, "police.seize.items") then
                            menu[lang.police.menu.seize.items.title()] = { function() zRPMenu.police_seize_items(player,k) end, lang.police.menu.seize.items.description() }
                        end

                        if zRP.hasPermission(user_id, "police.jail") then
                            menu[lang.police.menu.jail.title()] = { function() zRPMenu.police_jail(player,k) end, lang.police.menu.jail.description() }
                        end

                        if zRP.hasPermission(user_id, "police.fine") then
                            menu[lang.police.menu.fine.title()] = { function() zRPMenu.police_fine(player,k) end, lang.police.menu.fine.description() }
                        end

                        if zRP.hasPermission(user_id, "police.askid") then
                            choices[lang.police.menu.askid.title()] = { function() zRPMenu.police_askid(player,k) end, lang.police.menu.askid.description() }
                        end
                    end
                    ---CODE if is Block and use
                    zRP.openMenu(player,menu)
                end}
            end
        end
        --------------------------------------------------------------
        ---                        [Vehicle]                       ---
        --------------------------------------------------------------
        if veh then
            local name = " [V] " ..veh.fullname
            choices[name] = { function(player,choice)
                local menu = zRP.buildMenu(name,{player = player})
                menu.name = name
                menu.css = {top="75px", header_color="rgba(0,125,255,0.75)"}
                if not is_block then
                    ---- code --
                    if zRPclient.isPedSittingInVeichle(player,veh.hash) then
                        --------IF IS SITTING ON VEICULO
                        if zRP.hasPermission(user_id,"player.phone") then
                            menu["GPS"] = { function() zRP.openMenu(player,zRPMenu.gps()) end}
                        end
                    else
                        ---- CANT SHOW IF SITTING ON VEICULO
                        if zRP.hasPermission(user_id,lang.basic_menu.jail.perm()) then
                            menu["APREENDER VEICULO"] = { function() zRPMenu.police_size_vehicle(player,veh) end, "apreende"}
                        end

                    end
                end
                zRP.openMenu(player,menu)
            end}
        end
        --------------------------------------------------------------
        ---                        [WEAPONS]                       ---
        --------------------------------------------------------------
        if zRPclient.hasWeapons(player) --[[or zRPclient.hasArmour(player) --]]then
            choices["ARMAS"] = { function(player, choice)
                local menu = zRP.buildMenu("armas",{player = player})
                menu.name = "Armas"
                menu.css = {top="75px",header_color="rgba(0,125,255,0.75)"}
                menu.onclose = function(player) zRP.openQuickMenu(player) end -- nest menu
                if not is_block then
                    if zRP.hasPermission(user_id,lang.basic_menu.player.perm()) then
                        menu[lang.weapons.store.button()] = {zRPMenu.player_store_weapons, lang.weapons.store.desc()}-- store player weapons, like police store weapons from zrp
                    end
                    if zRP.hasPermission(user_id,lang.bodyarmor.store.perm()) then
                        menu[lang.bodyarmor.store.button()] = {zRPMenu.player_store_armor, lang.bodyarmor.store.desc()} -- store player armor
                    end
                end
                zRP.openMenu(player,menu)
            end}
        end
        --------------------------------------------------------------
        ---                       [ECONOMMY]                       ---
        --------------------------------------------------------------
        if zRP.hasPermission(user_id,lang.basic_menu.player.perm()) then --TODO Mudar para menu money
            choices["Economias"] = { function(player,choice)
                local menu =zRP.buildMenu("economy",{player = player})
                menu.name = "Economia"
                menu.css = {top="75px",header_color="rgba(0,125,255,0.75)"}
                menu.onclose = function(player) zRP.openQuickMenu(player) end -- nest menu
                if not is_block then
                    if zRP.hasPermission(user_id,lang.money.store.perm()) and zRP.getMoney(user_id) > 0 then
                        menu[lang.money.give.title()] = {zRPMenu.ch_give, lang.money.give.description()}
                        menu[lang.money.store.button()] = {zRPMenu.player_store_money, lang.money.store.desc()} -- transforms money in wallet to money in inventory to be stored in houses and cars
                    end
                    menu[lang.basic_menu.mpay.button()] = {zRPMenu.player_mobilepay, lang.basic_menu.mpay.desc()} -- transfer money through phone
                    menu[lang.basic_menu.mcharge.button()] = {zRPMenu.player_mobilecharge, lang.basic_menu.mcharge.desc()} -- charge money through phone

                end
                zRP.openMenu(player,menu)
            end}
        end
        --------------------------------------------------------------
        ---                        [STATIC]                        ---
        --------------------------------------------------------------
        ---
        if zRP.hasPermission(user_id, lang.basic_menu.player.perm()) then
            choices["Trabalho"] = {function (player, choice) zRPMenu.player_job_menu(player, choice) end,"MENU DE TRABALHO"}
        end

        add(choices)
    end
end)
