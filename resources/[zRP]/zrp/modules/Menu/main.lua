---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Muulfz.
--- DateTime: 12/2/2018 3:15 PM
---
--TODO Unir em um builder apenas

local htmlEntities = module("lib/htmlEntities")
local lang = zRP.lang
print("ROBERT")


-- add choices to the menu
-- character/aptitude.lua
zRP.registerMenuBuilder("main", function(add, data)
    local user_id = zRP.getUserId(data.player)
    if user_id then
        local choices = {}
        choices[lang.aptitude.title()] = {zRPMenu.apitude_aptitude,lang.aptitude.description()}

        add(choices)
        print("=====================================MENU APTITUDE - OK")
    end
end)


zRP.registerMenuBuilder("main", function(add, data)
    local choices = {}
    choices[lang.emotes.title()] = {function(player, choice)
        -- build emotes menu
        local menu = {name=lang.emotes.title(),css={top="75px",header_color="rgba(0,125,255,0.75)"}}
        local user_id = zRP.getUserId(player)

        if user_id then
            -- add emotes to the emote menu
            for k,v in pairs(emotes) do
                if zRP.hasPermissions(user_id, v.permissions or {}) then
                    menu[k] = {zRPMenu.player_emote}
                end
            end
        end

        -- clear current emotes
        menu[lang.emotes.clear.title()] = {function(player,choice)
            zRPclient._stopAnim(player,true) -- upper
            zRPclient._stopAnim(player,false) -- full
        end, lang.emotes.clear.description()}

        zRP.openMenu(player,menu)
    end}
    add(choices)
    print("=====================================EMOTICON - OK")
end)

-- add identity to main menu
zRP.registerMenuBuilder("main", function(add, data)
    local player = data.player

    local user_id = zRP.getUserId(player)
    if user_id then
        local identity = zRP.getUserIdentity(user_id)

        if identity then
            -- generate identity content
            -- get address
            local address = zRP.getUserAddress(user_id)
            local home = ""
            local number = ""
            if address then
                home = address.home
                number = address.number
            end

            local content = lang.cityhall.menu.info({htmlEntities.encode(identity.name),htmlEntities.encode(identity.firstname),identity.age,identity.registration,identity.phone,home,number})
            local choices = {}
            choices[lang.cityhall.menu.title()] = {function()end, content}

            add(choices)
        end
    end
end)

-- add choices to the main menu (emergency)
zRP.registerMenuBuilder("main", function(add, data)
    local user_id = zRP.getUserId(data.player)
    if user_id then
        local choices = {}
        if zRP.hasPermission(user_id,"emergency.revive") then
            choices[lang.emergency.menu.revive.title()] = {zRPMenu.choice_revive, lang.emergency.menu.revive.description() }
        end

        add(choices)
    end
end)

-- add player give money to main menu
zRP.registerMenuBuilder("main", function(add, data)
    local user_id = zRP.getUserId(data.player)
    if user_id then
        local choices = {}
        choices[lang.money.give.title()] = {zRPMenu.ch_give, lang.money.give.description()}

        add(choices)
    end
end)

-- MAIN MENU
zRP.registerMenuBuilder("main", function(add, data)
    local player = data.player
    local user_id = zRP.getUserId(player)
    if user_id then
        local choices = {}

        -- build admin menu
        choices[lang.mission.cancel.title()] = {function(player,choice)
            zRP.stopMission(player)
        end}

        add(choices)
    end
end)


zRP.registerMenuBuilder("main", function(add, data)
    local user_id = zRP.getUserId(data.player)
    if user_id ~= nil then
        local choices = {}

        if zRP.hasPermission(user_id,lang.basic_menu.player.perm()) then
            choices[lang.basic_menu.player.button()] = {zRPMenu.player_menu,lang.basic_menu.player.desc()} -- opens player submenu
        end

        if zRP.hasPermission(user_id,lang.basic_menu.service.perm()) then
            choices[lang.basic_menu.service.button()] = {zRPMenu.mission_services,lang.basic_menu.service.desc()} -- toggle the receiving of missions
        end

        if zRP.hasPermission(user_id,lang.basic_menu.loot.perm()) then
            choices[lang.basic_menu.loot.button()] = {zRPMenu.thief_loot, lang.basic_menu.loot.desc()} -- take the items of nearest player in coma
        end

        if zRP.hasPermission(user_id,lang.basic_menu.mugger.perm()) then
            choices[lang.basic_menu.mugger.button()] = {zRPMenu.thief_mug, lang.basic_menu.mugger.desc()} -- steal nearest player wallet
        end

        if zRP.hasPermission(user_id,lang.basic_menu.hacker.perm()) then
            choices[lang.basic_menu.hacker.button()] = {zRPMenu.hackewr_hack, lang.basic_menu.hacker.desc()} --  1 in 100 chance of stealing 1% of nearest player bank
        end

        if zRP.hasPermission(user_id,lang.basic_menu.lockpick.perm()) then
                choices[lang.basic_menu.lockpick.button()] = {zRPMenu.thief_lockpickveh, lang.basic_menu.lockpick.desc()} -- opens a locked vehicle
        end
        add(choices)
    end
end)
