--TODO enviar menus para Menu Police!
-- this module define some police tools and functions
local lang = zRP.lang
local cfg = module("cfg/Modules/police")

-- jail system
local unjailed = {}

function zRP.jail_clock(target_id, timer)
    local target = zRP.getUserSource(tonumber(target_id))
    local users = zRP.getUsers()
    local online = false
    for k, v in pairs(users) do
        if tonumber(k) == tonumber(target_id) then
            online = true
        end
    end
    if online then
        if timer > 0 then
            zRPclient.notify(target, lang.jail.timer({ timer }))
            zRP.setUData(tonumber(target_id), "zRP:jail:time", json.encode(timer))
            SetTimeout(60 * 1000, function()
                for k, v in pairs(unjailed) do
                    -- check if player has been unjailed by cop or admin
                    if v == tonumber(target_id) then
                        unjailed[v] = nil
                        timer = 0
                    end
                end
                zRP.setHunger(tonumber(target_id), 0)
                zRP.setThirst(tonumber(target_id), 0)
                zRP.jail_clock(tonumber(target_id), timer - 1)
            end)
        else
            zRPclient.loadFreeze(target, false, true, true)
            SetTimeout(15000, function()
                zRPclient.loadFreeze(target, false, false, false)
            end)
            zRPclient.teleport(target, 425.7607421875, -978.73425292969, 30.709615707397) -- teleport to outside jail
            zRPclient.setHandcuffed(target, false)
            zRPclient.notify(target, lang.jail.free())
            zRP.setUData(tonumber(target_id), "zRP:jail:time", json.encode(-1))
        end
    end
end



-- police records

-- insert a police record for a specific user
--- line: text for one line (can be html)
function zRP.insertPoliceRecord(user_id, line)
    if user_id then
        local data = zRP.getUData(user_id, "zRP:police_records")
        local records = data .. line .. "<br />"
        zRP.setUData(user_id, "zRP:police_records", records)
    end
end

-- police PC

local menu_pc = { name = lang.police.pc.title(), css = { top = "75px", header_color = "rgba(0,125,255,0.75)" } }

-- search identity by registration
local function ch_searchreg(player, choice)
    local reg = zRP.prompt(player, lang.police.pc.searchreg.prompt(), "")
    local user_id = zRP.getUserByRegistration(reg)
    if user_id then
        local identity = zRP.getUserIdentity(user_id)
        if identity then
            -- display identity and business
            local name = identity.name
            local firstname = identity.firstname
            local age = identity.age
            local phone = identity.phone
            local registration = identity.registration
            local bname = ""
            local bcapital = 0
            local home = ""
            local number = ""

            local business = zRP.getUserBusiness(user_id)
            if business then
                bname = business.name
                bcapital = business.capital
            end

            local address = zRP.getUserAddress(user_id)
            if address then
                home = address.home
                number = address.number
            end

            local content = lang.police.identity.info({ name, firstname, age, registration, phone, bname, bcapital, home, number })
            zRPclient._setDiv(player, "police_pc", ".div_police_pc{ background-color: rgba(0,0,0,0.75); color: white; font-weight: bold; width: 500px; padding: 10px; margin: auto; margin-top: 150px; }", content)
        else
            zRPclient._notify(player, lang.common.not_found())
        end
    else
        zRPclient._notify(player, lang.common.not_found())
    end
end

-- show police records by registration
local function ch_show_police_records(player, choice)
    local reg = zRP.prompt(player, lang.police.pc.searchreg.prompt(), "")
    local user_id = zRP.getUserByRegistration(reg)
    if user_id then
        local content = zRP.getUData(user_id, "zRP:police_records")
        zRPclient._setDiv(player, "police_pc", ".div_police_pc{ background-color: rgba(0,0,0,0.75); color: white; font-weight: bold; width: 500px; padding: 10px; margin: auto; margin-top: 150px; }", content)
    else
        zRPclient._notify(player, lang.common.not_found())
    end
end

-- delete police records by registration
local function ch_delete_police_records(player, choice)
    local reg = zRP.prompt(player, lang.police.pc.searchreg.prompt(), "")
    local user_id = zRP.getUserByRegistration(reg)
    if user_id then
        zRP.setUData(user_id, "zRP:police_records", "")
        zRPclient._notify(player, lang.police.pc.records.delete.deleted())
    else
        zRPclient._notify(player, lang.common.not_found())
    end
end

-- close business of an arrested owner
local function ch_closebusiness(player, choice)
    local nplayer = zRPclient.getNearestPlayer(player, 5)
    local nuser_id = zRP.getUserId(nplayer)
    if nuser_id then
        local identity = zRP.getUserIdentity(nuser_id)
        local business = zRP.getUserBusiness(nuser_id)
        if identity and business then
            if zRP.request(player, lang.police.pc.closebusiness.request({ identity.name, identity.firstname, business.name }), 15) then
                zRP.closeBusiness(nuser_id)
                zRPclient._notify(player, lang.police.pc.closebusiness.closed())
            end
        else
            zRPclient._notify(player, lang.common.no_player_near())
        end
    else
        zRPclient._notify(player, lang.common.no_player_near())
    end
end

-- track vehicle
local function ch_trackveh(player, choice)
    local reg = zRP.prompt(player, lang.police.pc.trackveh.prompt_reg(), "")
    local user_id = zRP.getUserByRegistration(reg)
    if user_id then
        local note = zRP.prompt(player, lang.police.pc.trackveh.prompt_note(), "")
        -- begin veh tracking
        zRPclient._notify(player, lang.police.pc.trackveh.tracking())
        local seconds = math.random(cfg.trackveh.min_time, cfg.trackveh.max_time)
        SetTimeout(seconds * 1000, function()
            local tplayer = zRP.getUserSource(user_id)
            if tplayer then
                local ok, x, y, z = zRPclient.getAnyOwnedVehiclePosition(tplayer)
                if ok then
                    -- track success
                    zRP.sendServiceAlert(nil, cfg.trackveh.service, x, y, z, lang.police.pc.trackveh.tracked({ reg, note }))
                else
                    zRPclient._notify(player, lang.police.pc.trackveh.track_failed({ reg, note })) -- failed
                end
            else
                zRPclient._notify(player, lang.police.pc.trackveh.track_failed({ reg, note })) -- failed
            end
        end)
    else
        zRPclient._notify(player, lang.common.not_found())
    end
end

menu_pc[lang.police.pc.searchreg.title()] = { ch_searchreg, lang.police.pc.searchreg.description() }
menu_pc[lang.police.pc.trackveh.title()] = { ch_trackveh, lang.police.pc.trackveh.description() }
menu_pc[lang.police.pc.records.show.title()] = { ch_show_police_records, lang.police.pc.records.show.description() }
menu_pc[lang.police.pc.records.delete.title()] = { ch_delete_police_records, lang.police.pc.records.delete.description() }
menu_pc[lang.police.pc.closebusiness.title()] = { ch_closebusiness, lang.police.pc.closebusiness.description() }

menu_pc.onclose = function(player)
    -- close pc gui
    zRPclient._removeDiv(player, "police_pc")
end

local function pc_enter(source, area)
    local user_id = zRP.getUserId(source)
    if user_id and zRP.hasPermission(user_id, "police.pc") then
        zRP.openMenu(source, menu_pc)
    end
end

local function pc_leave(source, area)
    zRP.closeMenu(source)
end

-- main menu choices

---- handcuff
local choice_handcuff = { function(player, choice)
    local nplayer = zRPclient.getNearestPlayer(player, 10)
    if nplayer then
        local nuser_id = zRP.getUserId(nplayer)
        if nuser_id then
            zRPclient._toggleHandcuff(nplayer)
        else
            zRPclient._notify(player, lang.common.no_player_near())
        end
    end
end, lang.police.menu.handcuff.description() }

---- drag
local choice_drag = { function(player, choice)
    local nplayer = zRPclient.getNearestPlayer(player, 10)
    if nplayer then
        local nuser_id = zRP.getUserId(nplayer)
        if nuser_id then
            local followed = zRPclient.getFollowedPlayer(nplayer)
            if followed ~= player then
                -- drag
                zRPclient._followPlayer(nplayer, player)
            else
                -- stop follow
                zRPclient._followPlayer(nplayer)
            end
        else
            zRPclient._notify(player, lang.common.no_player_near())
        end
    end
end, lang.police.menu.drag.description() }

---- putinveh
--[[
-- veh at position version
local choice_putinveh = {function(player,choice)
  zRPclient.getNearestPlayer(player,{10},function(nplayer)
    local nuser_id = zRP.getUserId(nplayer)
    if nuser_id ~= nil then
      zRPclient.isHandcuffed(nplayer,{}, function(handcuffed)  -- check handcuffed
        if handcuffed then
          zRPclient.getNearestOwnedVehicle(player, {10}, function(ok,vtype,name) -- get nearest owned vehicle
            if ok then
              zRPclient.getOwnedVehiclePosition(player, {vtype}, function(x,y,z)
                zRPclient.putInVehiclePositionAsPassenger(nplayer,{x,y,z}) -- put player in vehicle
              end)
            else
              zRPclient._notify(player,lang.vehicle.no_owned_near())
            end
          end)
        else
          zRPclient._notify(player,lang.police.not_handcuffed())
        end
      end)
    else
      zRPclient._notify(player,lang.common.no_player_near())
    end
  end)
end,lang.police.menu.putinveh.description()}
--]]

local choice_putinveh = { function(player, choice)
    local nplayer = zRPclient.getNearestPlayer(player, 10)
    local nuser_id = zRP.getUserId(nplayer)
    if nuser_id then
        if zRPclient.isHandcuffed(nplayer) then
            -- check handcuffed
            zRPclient._putInNearestVehicleAsPassenger(nplayer, 5)
        else
            zRPclient._notify(player, lang.police.not_handcuffed())
        end
    else
        zRPclient._notify(player, lang.common.no_player_near())
    end
end, lang.police.menu.putinveh.description() }

local choice_getoutveh = { function(player, choice)
    local nplayer = zRPclient.getNearestPlayer(player, 10)
    local nuser_id = zRP.getUserId(nplayer)
    if nuser_id then
        if zRPclient.isHandcuffed(nplayer) then
            -- check handcuffed
            zRPclient._ejectVehicle(nplayer)
        else
            zRPclient._notify(player, lang.police.not_handcuffed())
        end
    else
        zRPclient._notify(player, lang.common.no_player_near())
    end
end, lang.police.menu.getoutveh.description() }

---- askid
local choice_askid = { function(player, choice)
    local nplayer = zRPclient.getNearestPlayer(player, 10)
    local nuser_id = zRP.getUserId(nplayer)
    if nuser_id then
        zRPclient._notify(player, lang.police.menu.askid.asked())
        if zRP.request(nplayer, lang.police.menu.askid.request(), 15) then
            local identity = zRP.getUserIdentity(nuser_id)
            if identity then
                -- display identity and business
                local name = identity.name
                local firstname = identity.firstname
                local age = identity.age
                local phone = identity.phone
                local registration = identity.registration
                local bname = ""
                local bcapital = 0
                local home = ""
                local number = ""

                local business = zRP.getUserBusiness(nuser_id)
                if business then
                    bname = business.name
                    bcapital = business.capital
                end

                local address = zRP.getUserAddress(nuser_id)
                if address then
                    home = address.home
                    number = address.number
                end

                local content = lang.police.identity.info({ name, firstname, age, registration, phone, bname, bcapital, home, number })
                zRPclient._setDiv(player, "police_identity", ".div_police_identity{ background-color: rgba(0,0,0,0.75); color: white; font-weight: bold; width: 500px; padding: 10px; margin: auto; margin-top: 150px; }", content)
                -- request to hide div
                zRP.request(player, lang.police.menu.askid.request_hide(), 1000)
                zRPclient._removeDiv(player, "police_identity")
            end
        else
            zRPclient._notify(player, lang.common.request_refused())
        end
    else
        zRPclient._notify(player, lang.common.no_player_near())
    end
end, lang.police.menu.askid.description() }

---- police check
local choice_check = { function(player, choice)
    local nplayer = zRPclient.getNearestPlayer(player, 5)
    local nuser_id = zRP.getUserId(nplayer)
    if nuser_id then
        zRPclient._notify(nplayer, lang.police.menu.check.checked())
        local weapons = zRPclient.getWeapons(nplayer)
        -- prepare display data (money, items, weapons)
        local money = zRP.getMoney(nuser_id)
        local items = ""
        local data = zRP.getUserDataTable(nuser_id)
        if data and data.inventory then
            for k, v in pairs(data.inventory) do
                local item_name, item_desc, item_weight = zRP.getItemDefinition(k)
                if item_name then
                    items = items .. "<br />" .. item_name .. " (" .. v.amount .. ")"
                end
            end
        end

        local weapons_info = ""
        for k, v in pairs(weapons) do
            weapons_info = weapons_info .. "<br />" .. k .. " (" .. v.ammo .. ")"
        end

        zRPclient._setDiv(player, "police_check", ".div_police_check{ background-color: rgba(0,0,0,0.75); color: white; font-weight: bold; width: 500px; padding: 10px; margin: auto; margin-top: 150px; }", lang.police.menu.check.info({ money, items, weapons_info }))
        -- request to hide div
        zRP.request(player, lang.police.menu.check.request_hide(), 1000)
        zRPclient._removeDiv(player, "police_check")
    else
        zRPclient._notify(player, lang.common.no_player_near())
    end
end, lang.police.menu.check.description() }

local choice_seize_weapons = { function(player, choice)
    local user_id = zRP.getUserId(player)
    if user_id then
        local nplayer = zRPclient.getNearestPlayer(player, 5)
        local nuser_id = zRP.getUserId(nplayer)
        if nuser_id and zRP.hasPermission(nuser_id, "police.seizable") then
            if zRPclient.isHandcuffed(nplayer) then
                -- check handcuffed
                local weapons = zRPclient.replaceWeapons(nplayer, {})
                for k, v in pairs(weapons) do
                    -- display seized weapons
                    -- zRPclient._notify(player,lang.police.menu.seize.seized({k,v.ammo}))
                    -- convert weapons to parametric weapon items
                    zRP.giveInventoryItem(user_id, "wbody|" .. k, 1, true)
                    if v.ammo > 0 then
                        zRP.giveInventoryItem(user_id, "wammo|" .. k, v.ammo, true)
                    end
                end

                zRPclient._notify(nplayer, lang.police.menu.seize.weapons.seized())
            else
                zRPclient._notify(player, lang.police.not_handcuffed())
            end
        else
            zRPclient._notify(player, lang.common.no_player_near())
        end
    end
end, lang.police.menu.seize.weapons.description() }

local choice_seize_items = { function(player, choice)
    local user_id = zRP.getUserId(player)
    if user_id then
        local nplayer = zRPclient.getNearestPlayer(player, 5)
        local nuser_id = zRP.getUserId(nplayer)
        if nuser_id and zRP.hasPermission(nuser_id, "police.seizable") then
            if zRPclient.isHandcuffed(nplayer) then
                -- check handcuffed
                local inv = zRP.getInventory(user_id)

                for k, v in pairs(cfg.seizable_items) do
                    -- transfer seizable items
                    local sub_items = { v } -- single item

                    if string.sub(v, 1, 1) == "*" then
                        -- seize all parametric items of this idname
                        local idname = string.sub(v, 2)
                        sub_items = {}
                        for fidname, _ in pairs(inv) do
                            if splitString(fidname, "|")[1] == idname then
                                -- same parametric item
                                table.insert(sub_items, fidname) -- add full idname
                            end
                        end
                    end

                    for _, idname in pairs(sub_items) do
                        local amount = zRP.getInventoryItemAmount(nuser_id, idname)
                        if amount > 0 then
                            local item_name, item_desc, item_weight = zRP.getItemDefinition(idname)
                            if item_name then
                                -- do transfer
                                if zRP.tryGetInventoryItem(nuser_id, idname, amount, true) then
                                    zRP.giveInventoryItem(user_id, idname, amount, false)
                                    zRPclient._notify(player, lang.police.menu.seize.seized({ item_name, amount }))
                                end
                            end
                        end
                    end
                end

                zRPclient._notify(nplayer, lang.police.menu.seize.items.seized())
            else
                zRPclient._notify(player, lang.police.not_handcuffed())
            end
        else
            zRPclient._notify(player, lang.common.no_player_near())
        end
    end
end, lang.police.menu.seize.items.description() }

-- toggle jail nearest player
local choice_jail = { function(player, choice)
    local user_id = zRP.getUserId(player)
    if user_id then
        local nplayer = zRPclient.getNearestPlayer(player, 5)
        local nuser_id = zRP.getUserId(nplayer)
        if nuser_id then
            if zRPclient.isJailed(nplayer) then
                zRPclient._unjail(nplayer)
                zRPclient._notify(nplayer, lang.police.menu.jail.notify_unjailed())
                zRPclient._notify(player, lang.police.menu.jail.unjailed())
            else
                -- find the nearest jail
                local x, y, z = zRPclient.getPosition(nplayer)
                local d_min = 1000
                local v_min = nil
                for k, v in pairs(cfg.jails) do
                    local dx, dy, dz = x - v[1], y - v[2], z - v[3]
                    local dist = math.sqrt(dx * dx + dy * dy + dz * dz)

                    if dist <= d_min and dist <= 15 then
                        -- limit the research to 15 meters
                        d_min = dist
                        v_min = v
                    end

                    -- jail
                    if v_min then
                        zRPclient._jail(nplayer, v_min[1], v_min[2], v_min[3], v_min[4])
                        zRPclient._notify(nplayer, lang.police.menu.jail.notify_jailed())
                        zRPclient._notify(player, lang.police.menu.jail.jailed())
                    else
                        zRPclient._notify(player, lang.police.menu.jail.not_found())
                    end
                end
            end
        else
            zRPclient._notify(player, lang.common.no_player_near())
        end
    end
end, lang.police.menu.jail.description() }

local choice_fine = { function(player, choice)
    local user_id = zRP.getUserId(player)
    if user_id then
        local nplayer = zRPclient.getNearestPlayer(player, 5)
        local nuser_id = zRP.getUserId(nplayer)
        if nuser_id then
            local money = zRP.getMoney(nuser_id) + zRP.getBankMoney(nuser_id)

            -- build fine menu
            local menu = { name = lang.police.menu.fine.title(), css = { top = "75px", header_color = "rgba(0,125,255,0.75)" } }

            local choose = function(player, choice)
                -- fine action
                local amount = cfg.fines[choice]
                if amount ~= nil then
                    if zRP.tryFullPayment(nuser_id, amount) then
                        zRP.insertPoliceRecord(nuser_id, lang.police.menu.fine.record({ choice, amount }))
                        zRPclient._notify(player, lang.police.menu.fine.fined({ choice, amount }))
                        zRPclient._notify(nplayer, lang.police.menu.fine.notify_fined({ choice, amount }))
                        zRP.closeMenu(player)
                    else
                        zRPclient._notify(player, lang.money.not_enough())
                    end
                end
            end

            for k, v in pairs(cfg.fines) do
                -- add fines in function of money available
                if v <= money then
                    menu[k] = { choose, v }
                end
            end

            -- open menu
            zRP.openMenu(player, menu)
        else
            zRPclient._notify(player, lang.common.no_player_near())
        end
    end
end, lang.police.menu.fine.description() }

local choice_store_weapons = { function(player, choice)
    local user_id = zRP.getUserId(player)
    if user_id then
        local weapons = zRPclient.replaceWeapons(player, {})
        for k, v in pairs(weapons) do
            -- convert weapons to parametric weapon items
            zRP.giveInventoryItem(user_id, "wbody|" .. k, 1, true)
            if v.ammo > 0 then
                zRP.giveInventoryItem(user_id, "wammo|" .. k, v.ammo, true)
            end
        end
    end
end, lang.police.menu.store_weapons.description() }

function zRPMenu.police_unjail(player, choice)
    local target_id = zRP.prompt(player, lang.unjail.prompt(), "")
    if target_id ~= nil and target_id ~= "" then
        local value = zRP.getUData(tonumber(target_id), "zRP:jail:time")
        if value ~= nil then
            local custom = json.decode(value)
            if custom ~= nil then
                local user_id = zRP.getUserId(player)
                if tonumber(custom) > 0 or zRP.hasPermission(user_id, lang.unjail.admin()) then
                    local target = zRP.getUserSource(tonumber(target_id))
                    if target ~= nil then
                        unjailed[target] = tonumber(target_id)
                        zRPclient.notify(player, lang.unjail.released())
                        zRPclient.notify(target, lang.unjail.lowered())
                        zRPbm.logInfoToFile(lang.unjail.file(), lang.unjail.log({ user_id, target_id, custom }))
                    else
                        zRPclient.notify(player, lang.common.invalid_value())
                    end
                else
                    zRPclient.notify(player, lang.common.invalid_value())
                end
            end
        end
    else
        zRPclient.notify(player, lang.common.invalid_value())
    end
end

-- add choices to the menu
zRP.registerMenuBuilder("main", function(add, data)
    local player = data.player

    local user_id = zRP.getUserId(player)
    if user_id then
        local choices = {}

        if zRP.hasPermission(user_id, "police.menu") then
            -- build police menu
            choices[lang.police.title()] = { function(player, choice)
                local menu = zRP.buildMenu("police", { player = player })
                menu.name = lang.police.title()
                menu.css = { top = "75px", header_color = "rgba(0,125,255,0.75)" }

                if zRP.hasPermission(user_id, "police.handcuff") then
                    menu[lang.police.menu.handcuff.title()] = choice_handcuff
                end

                if zRP.hasPermission(user_id, "police.drag") then
                    menu[lang.police.menu.drag.title()] = choice_drag
                end

                if zRP.hasPermission(user_id, "police.putinveh") then
                    menu[lang.police.menu.putinveh.title()] = choice_putinveh
                end

                if zRP.hasPermission(user_id, "police.getoutveh") then
                    menu[lang.police.menu.getoutveh.title()] = choice_getoutveh
                end

                if zRP.hasPermission(user_id, "police.check") then
                    menu[lang.police.menu.check.title()] = choice_check
                end

                if zRP.hasPermission(user_id, "police.seize.weapons") then
                    menu[lang.police.menu.seize.weapons.title()] = choice_seize_weapons
                end

                if zRP.hasPermission(user_id, "police.seize.items") then
                    menu[lang.police.menu.seize.items.title()] = choice_seize_items
                end

                if zRP.hasPermission(user_id, "police.jail") then
                    menu[lang.police.menu.jail.title()] = choice_jail
                end

                if zRP.hasPermission(user_id, "police.fine") then
                    menu[lang.police.menu.fine.title()] = choice_fine
                end

                zRP.openMenu(player, menu)
            end }
        end

        if zRP.hasPermission(user_id, "police.askid") then
            choices[lang.police.menu.askid.title()] = choice_askid
        end

        if zRP.hasPermission(user_id, "police.store_weapons") then
            choices[lang.police.menu.store_weapons.title()] = choice_store_weapons
        end

        add(choices)
    end
end)

local function build_client_points(source)
    -- PC
    for k, v in pairs(cfg.pcs) do
        local x, y, z = table.unpack(v)
        zRPclient._addMarker(source, x, y, z - 1, 0.7, 0.7, 0.5, 0, 125, 255, 125, 150)
        zRP.setArea(source, "zRP:police:pc" .. k, x, y, z, 1, 1.5, pc_enter, pc_leave)
    end
end

-- build police points
AddEventHandler("zRP:playerSpawn", function(user_id, source, first_spawn)
    if first_spawn then
        build_client_points(source)
    end
end)

-- WANTED SYNC

local wantedlvl_players = {}

function zRP.getUserWantedLevel(user_id)
    return wantedlvl_players[user_id] or 0
end

-- receive wanted level
function tzRP.updateWantedLevel(level)
    local player = source
    local user_id = zRP.getUserId(player)
    if user_id then
        local was_wanted = (zRP.getUserWantedLevel(user_id) > 0)
        wantedlvl_players[user_id] = level
        local is_wanted = (level > 0)

        -- send wanted to listening service
        if not was_wanted and is_wanted then
            local x, y, z = zRPclient.getPosition(player)
            zRP.sendServiceAlert(nil, cfg.wanted.service, x, y, z, lang.police.wanted({ level }))
        end

        if was_wanted and not is_wanted then
            zRPclient._removeNamedBlip(-1, "zRP:wanted:" .. user_id) -- remove wanted blip (all to prevent phantom blip)
        end
    end
end

-- delete wanted entry on leave
AddEventHandler("zRP:playerLeave", function(user_id, player)
    wantedlvl_players[user_id] = nil
    zRPclient._removeNamedBlip(-1, "zRP:wanted:" .. user_id)  -- remove wanted blip (all to prevent phantom blip)
end)

-- display wanted positions
local function task_wanted_positions()
    local listeners = zRP.getUsersByPermission("police.wanted")
    for k, v in pairs(wantedlvl_players) do
        -- each wanted player
        local player = zRP.getUserSource(tonumber(k))
        if player and v and v > 0 then
            local x, y, z = zRPclient.getPosition(player)
            for l, w in pairs(listeners) do
                -- each listening player
                local lplayer = zRP.getUserSource(w)
                if lplayer then
                    zRPclient._setNamedBlip(lplayer, "zRP:wanted:" .. k, x, y, z, cfg.wanted.blipid, cfg.wanted.blipcolor, lang.police.wanted({ v }))
                end
            end
        end
    end
    SetTimeout(5000, task_wanted_positions)
end

async(function()
    task_wanted_positions()
end)

-- (server) called when a logged player spawn to check for zRP:jail in user_data
AddEventHandler("zRP:playerSpawn", function(user_id, source, first_spawn)
    local target = zRP.getUserSource(user_id)
    SetTimeout(35000, function()
        local custom = {}
        local value = zRP.getUData(user_id, "zRP:jail:time")
        if value ~= nil then
            custom = json.decode(value)
            if custom ~= nil then
                if tonumber(custom) > 0 then
                    zRPclient.loadFreeze(target, false, true, true)
                    SetTimeout(15000, function()
                        zRPclient.loadFreeze(target, false, false, false)
                    end)
                    zRPclient.setHandcuffed(target, true)
                    zRPclient.teleport(target, 1641.5477294922, 2570.4819335938, 45.564788818359) -- teleport inside jail
                    zRPclient.notify(target, lang.jail.resent())
                    zRP.setHunger(tonumber(user_id), 0)
                    zRP.setThirst(tonumber(user_id), 0)
                    local target_id = lang.jail.rejailer()
                    zRP.logInfoToFile(lang.jail.file(), lang.jail.log({ user_id, target_id, custom }))
                    zRP.jail_clock(tonumber(user_id), tonumber(custom))
                end
            end
        end
    end)
end)

local spikes = {}

function zRPMenu.police_spikes(player, choice)
    local user_id = zRP.getUserId(player)
    local closeby = zRPclient.isCloseToSpikes(player)
    if closeby and (spikes[player] or zRP.hasPermission(user_id, lang.basic_menu.spikes.admin())) then
        zRPclient.removeSpikes(player)
        spikes[player] = false
    elseif closeby and not spikes[player] and not zRP.hasPermission(user_id, lang.basic_menu.spikes.admin()) then
        zRPclient.notify(player, lang.basic_menu.spikes.nocarry())
    elseif not closeby and spikes[player] and not zRP.hasPermission(user_id, lang.basic_menu.spikes.admin()) then
        zRPclient.notify(player, lang.basic_menu.spikes.nodeploy())
    elseif not closeby and (not spikes[player] or zRP.hasPermission(user_id, lang.basic_menu.spikes.admin())) then
        zRPclient.setSpikesOnGround(player)
        spikes[player] = true
    end
end

function zRPMenu.police_drag(player, choice)
    -- get nearest player
    local nplayer = zRPclient.getNearestPlayer(player, 5)
    if nplayer then
        local handcuffed = zRPclient.isHandcuffed(nplayer)
        if handcuffed then
            zRPclient.policeDrag(nplayer, player)
        else
            zRPclient.notify(player, lang.basic_menu.police.not_handcuffed())
        end
    else
        zRPclient.notify(player, lang.basic_menu.common.no_player_near())
    end
end

function zRPMenu.police_jail(player, choice)
    local nplayers = zRPclient.getNearestPlayers(player, 15)
    local user_list = ""
    for k, v in pairs(nplayers) do
        user_list = user_list .. lang.basic_menu.userlist.format({ zRP.getUserId(k), GetPlayerName(k) })
    end
    if user_list ~= "" then
        local target_id = zRP.prompt(player, lang.basic_menu.userlist.nearby({ user_list }), "")
        if target_id ~= nil and target_id ~= "" then
            local jail_time = zRP.prompt(player, lang.basic_menu.jail.prompt(), "")
            if jail_time ~= nil and jail_time ~= "" then
                local target = zRP.getUserSource(tonumber(target_id))
                if target ~= nil then
                    if tonumber(jail_time) > 30 then
                        jail_time = 30
                    end
                    if tonumber(jail_time) < 1 then
                        jail_time = 1
                    end

                    local handcuffed = zRPclient.isHandcuffed(target)
                    if handcuffed then
                        zRPclient.loadFreeze(target, false, true, true)
                        SetTimeout(15000, function()
                            zRPclient.loadFreeze(target, false, false, false)
                        end)
                        zRPclient.teleport(target, 1641.5477294922, 2570.4819335938, 45.564788818359) -- teleport to inside jail
                        zRPclient.notify(target, lang.basic_menu.jail.sent.bad())
                        zRPclient.notify(player, lang.basic_menu.jail.sent.good())
                        zRP.setHunger(tonumber(target_id), 0)
                        zRP.setThirst(tonumber(target_id), 0)
                        zRP.jail_clock(tonumber(target_id), tonumber(jail_time))
                        local user_id = zRP.getUserId(player)
                        zRP.logInfoToFile(lang.basic_menu.jail.file(), lang.basic_menu.jail.log({ user_id, target_id, jail_time }))
                    else
                        zRPclient.notify(player, lang.basic_menu.police.not_handcuffed())
                    end
                else
                    zRPclient.notify(player, lang.basic_menu.common.invalid_value())
                end
            else
                zRPclient.notify(player, lang.basic_menu.common.invalid_value())
            end
        else
            zRPclient.notify(player, lang.basic_menu.common.invalid_value())
        end
    else
        zRPclient.notify(player, lang.basic_menu.common.no_player_near())
    end
end

function zRPMenu.police_unjail(player, choice)
    local target_id = zRP.prompt(player,lang.basic_menu.unjail.prompt(),"")
    if target_id ~= nil and target_id ~= "" then
        local value = zRP.getUData(tonumber(target_id),"zRP:jail:time")
        if value ~= nil then
            local custom = json.decode(value)
            if custom ~= nil then
                local user_id = zRP.getUserId(player)
                if tonumber(custom) > 0 or zRP.hasPermission(user_id,lang.basic_menu.unjail.admin()) then
                    local target = zRP.getUserSource(tonumber(target_id))
                    if target ~= nil then
                        unjailed[target] = tonumber(target_id)
                        zRPclient.notify(player,lang.basic_menu.unjail.released())
                        zRPclient.notify(target,lang.basic_menu.unjail.lowered())
                        zRP.logInfoToFile(lang.basic_menu.unjail.file(),lang.basic_menu.unjail.log({user_id,target_id,custom}))
                    else
                        zRPclient.notify(player,lang.basic_menu.common.invalid_value())
                    end
                else
                    zRPclient.notify(player,lang.basic_menu.common.invalid_value())
                end
            end
        end
    else
        zRPclient.notify(player,lang.basic_menu.common.invalid_value())
    end
end

function zRPMenu.police_fine(player, choice)
    local nplayers = zRPclient.getNearestPlayers(player,15)
    local user_list = ""
    for k,v in pairs(nplayers) do
        user_list = user_list .. lang.basic_menu.userlist.format({zRP.getUserId(k),GetPlayerName(k)})
    end
    if user_list ~= "" then
        local target_id = zRP.prompt(player,lang.basic_menu.userlist.nearby({user_list}),"")
        if target_id ~= nil and target_id ~= "" then
            local fine = zRP.prompt(player,lang.basic_menu.fine.prompt.amount(),"")
            if fine ~= nil and fine ~= "" then
                local reason = zRP.prompt(player,lang.basic_menu.fine.prompt.reason(),"")
                if reason ~= nil and reason ~= "" then
                    local target = zRP.getUserSource(tonumber(target_id))
                    if target ~= nil then
                        if tonumber(fine) > 1000 then
                            fine = 1000
                        end
                        if tonumber(fine) < 100 then
                            fine = 100
                        end

                        if zRP.tryFullPayment(tonumber(target_id), tonumber(fine)) then
                            zRP.insertPoliceRecord(tonumber(target_id), lang.basic_menu.police.menu.fine.record({reason,fine}))
                            zRPclient.notify(player,lang.basic_menu.police.menu.fine.fined({reason,fine}))
                            zRPclient.notify(target,lang.basic_menu.police.menu.fine.notify_fined({reason,fine}))
                            local user_id = zRP.getUserId(player)
                            local custom = ""
                            zRP.logInfoToFile(lang.basic_menu.fine.file(),lang.basic_menu.fine.log({user_id,target_id,custom,reason}))
                            zRP.closeMenu(player)
                        else
                            zRPclient.notify(player,lang.basic_menu.money.not_enough())
                        end
                    else
                        zRPclient.notify(player,lang.basic_menu.common.invalid_value())
                    end
                else
                    zRPclient.notify(player,lang.basic_menu.common.invalid_value())
                end
            else
                zRPclient.notify(player,lang.basic_menu.common.invalid_value())
            end
        else
            zRPclient.notify(player,lang.basic_menu.common.invalid_value())
        end
    else
        zRPclient.notify(player,lang.basic_menu.common.no_player_near())
    end
end

function zRPMenu.police_handcuff(player, choice)
    local nplayer = zRPclient.getNearestPlayer(player,10)
    local nuser_id = zRP.getUserId(nplayer)
    if nuser_id ~= nil then
        zRPclient.toggleHandcuff(nplayer)
        local user_id = zRP.getUserId(player)
        zRP.logInfoToFile(lang.cuff.file(),lang.cuff.log({user_id,nuser_id}))
        zRP.closeMenu(nplayer)
    else
        zRPclient.notify(player,lang.common.no_player_near())
    end
end

function zRPMenu.police_freeze(player, choice)
    local user_id = zRP.getUserId(player)
    if zRP.hasPermission(user_id,lang.freeze.admin()) then
        local target_id = zRP.prompt(player,lang.freeze.prompt(),"")
        if target_id ~= nil and target_id ~= "" then
            local target = zRP.getUserSource(tonumber(target_id))
            if target ~= nil then
                zRPclient.notify(player,lang.freeze.notify())
                zRPclient.loadFreeze(target,true,true,true)
            else
                zRPclient.notify(player,lang.common.invalid_value())
            end
        else
            zRPclient.notify(player,lang.common.invalid_value())
        end
    else
        local nplayer = zRPclient.getNearestPlayer(player,10)
        local nuser_id = zRP.getUserId(nplayer)
        if nuser_id ~= nil then
            zRPclient.notify(player,lang.freeze.notify())
            zRPclient.loadFreeze(nplayer,true,false,false)
        else
            zRPclient.notify(player,lang.common.no_player_near())
        end
    end
end


zRP.defInventoryItem(lang.bodyarmor.id(),lang.bodyarmor.name(),lang.bodyarmor.desc(),
        function(args)
            local choices = {}

            choices[lang.bodyarmor.equip()] = {function(player,choice)
                local user_id = zRP.getUserId(player)
                if user_id ~= nil then
                    if zRP.tryGetInventoryItem(user_id, lang.bodyarmor.id(), 1, true) then
                       zRPclient.setArmour(player,100,true)
                        zRP.closeMenu(player)
                    end
                end
            end}

            return choices
        end,
        5.0)


