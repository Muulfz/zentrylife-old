---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Muulfz.
--- DateTime: 1/10/2019 2:07 AM
---

local lang = zRP.lang.basic_menu

function zRPMenu.player_job_menu(player, choice)
    local user_id = zRP.getUserId(player)
    local menu = {}
    menu.name = "Job"
    menu.css = {top = "75px", header_color = "rgba(0,0,255,0.75)"}
    menu.onclose = function(player) zRP.openQuickMenu(player) end -- nest menu
    -------------------------------IMPLEMENTACAO
    if zRP.hasPermission(user_id,lang.basic_menu.service.perm()) and zRP.hasMission(player) then
        menu["2-"..lang.basic_menu.service.button()] = {zRPMenu.mission_services,lang.basic_menu.service.desc()} -- toggle the receiving of missions
        menu["1-"..lang.mission.cancel.title()] = {function(player,choice)zRP.stopMission(player) end}
    end
    if zRP.hasPermission(user_id,lang.basic_menu.hacker.perm()) then
        menu[lang.basic_menu.hacker.button()] = {zRPMenu.hackewr_hack, lang.basic_menu.hacker.desc()} --  1 in 100 chance of stealing 1% of nearest player bank
    end

    if zRP.hasPermission(user_id,lang.basic_menu.lockpick.perm()) then
        menu[lang.basic_menu.lockpick.button()] = {zRPMenu.thief_lockpickveh, lang.basic_menu.lockpick.desc()} -- opens a locked vehicle
    end

    menu[lang.robber.title()] = {zRPMenu.player_robPlayer, lang.robber.description()}

    if zRP.hasPermission(user_id,lang.basic_menu.unjail.perm()) then
        menu[lang.basic_menu.unjail.button()] = {zRPMenu.police_unjail, lang.basic_menu.spikes.desc()} -- Un jails chosen player if he is jailed (Use admin.easy_unjail as permission to have this in admin menu working in non jailed players)
    end

    if zRP.hasPermission(user_id,lang.basic_menu.spikes.perm()) then
        menu[lang.basic_menu.spikes.button()] = {zRPMenu.police_spikes, lang.basic_menu.spikes.desc()} -- Toggle spikes
    end

    zRP.openMenu(player, menu)
end