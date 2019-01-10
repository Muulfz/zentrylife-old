local cfg = module("cfg/Modules/survival")
local lang = zRP.lang

-- api

function zRP.getHunger(user_id)
    local data = zRP.getUserDataTable(user_id)
    if data then
        return data.hunger
    end

    return 0
end

function zRP.getThirst(user_id)
    local data = zRP.getUserDataTable(user_id)
    if data then
        return data.thirst
    end

    return 0
end

function zRP.setHunger(user_id, value)
    local data = zRP.getUserDataTable(user_id)
    if data then
        data.hunger = value
        if data.hunger < 0 then
            data.hunger = 0
        elseif data.hunger > 100 then
            data.hunger = 100
        end

        -- update bar
        local source = zRP.getUserSource(user_id)
        zRPclient._setProgressBarValue(source, "zRP:hunger", data.hunger)
        if data.hunger >= 100 then
            zRPclient._setProgressBarText(source, "zRP:hunger", lang.survival.starving())
        else
            zRPclient._setProgressBarText(source, "zRP:hunger", "")
        end
    end
end

function zRP.setThirst(user_id, value)
    local data = zRP.getUserDataTable(user_id)
    if data then
        data.thirst = value
        if data.thirst < 0 then
            data.thirst = 0
        elseif data.thirst > 100 then
            data.thirst = 100
        end

        -- update bar
        local source = zRP.getUserSource(user_id)
        zRPclient._setProgressBarValue(source, "zRP:thirst", data.thirst)
        if data.thirst >= 100 then
            zRPclient._setProgressBarText(source, "zRP:thirst", lang.survival.thirsty())
        else
            zRPclient._setProgressBarText(source, "zRP:thirst", "")
        end
    end
end

function zRP.varyHunger(user_id, variation)
    local data = zRP.getUserDataTable(user_id)
    if data then
        local was_starving = data.hunger >= 100
        data.hunger = data.hunger + variation
        local is_starving = data.hunger >= 100

        -- apply overflow as damage
        local overflow = data.hunger - 100
        if overflow > 0 then
            zRPclient._varyHealth(zRP.getUserSource(user_id), -overflow * cfg.overflow_damage_factor)
        end

        if data.hunger < 0 then
            data.hunger = 0
        elseif data.hunger > 100 then
            data.hunger = 100
        end

        -- set progress bar data
        local source = zRP.getUserSource(user_id)
        zRPclient._setProgressBarValue(source, "zRP:hunger", data.hunger)
        if was_starving and not is_starving then
            zRPclient._setProgressBarText(source, "zRP:hunger", "")
        elseif not was_starving and is_starving then
            zRPclient._setProgressBarText(source, "zRP:hunger", lang.survival.starving())
        end
    end
end

function zRP.varyThirst(user_id, variation)
    local data = zRP.getUserDataTable(user_id)
    if data then
        local was_thirsty = data.thirst >= 100
        data.thirst = data.thirst + variation
        local is_thirsty = data.thirst >= 100

        -- apply overflow as damage
        local overflow = data.thirst - 100
        if overflow > 0 then
            zRPclient._varyHealth(zRP.getUserSource(user_id), -overflow * cfg.overflow_damage_factor)
        end

        if data.thirst < 0 then
            data.thirst = 0
        elseif data.thirst > 100 then
            data.thirst = 100
        end

        -- set progress bar data
        local source = zRP.getUserSource(user_id)
        zRPclient._setProgressBarValue(source, "zRP:thirst", data.thirst)
        if was_thirsty and not is_thirsty then
            zRPclient._setProgressBarText(source, "zRP:thirst", "")
        elseif not was_thirsty and is_thirsty then
            zRPclient._setProgressBarText(source, "zRP:thirst", lang.survival.thirsty())
        end
    end
end

-- tunnel api (expose some functions to clients)

function tzRP.varyHunger(variation)
    local user_id = zRP.getUserId(source)
    if user_id then
        zRP.varyHunger(user_id, variation)
    end
end

function tzRP.varyThirst(variation)
    local user_id = zRP.getUserId(source)
    if user_id then
        zRP.varyThirst(user_id, variation)
    end
end

-- tasks

-- hunger/thirst increase
function task_update()
    for k, v in pairs(zRP.users) do
        zRP.varyHunger(v, cfg.hunger_per_minute)
        zRP.varyThirst(v, cfg.thirst_per_minute)
    end

    SetTimeout(60000, task_update)
end

async(function()
    task_update()
end)

-- handlers

-- init values
AddEventHandler("zRP:playerJoin", function(user_id, source, name, last_login)
    local data = zRP.getUserDataTable(user_id)
    if data.hunger == nil then
        data.hunger = 0
        data.thirst = 0
    end
end)

-- add survival progress bars on spawn
AddEventHandler("zRP:playerSpawn", function(user_id, source, first_spawn)
    local data = zRP.getUserDataTable(user_id)

    -- disable police
    zRPclient._setPolice(source, cfg.police)
    -- set friendly fire
    zRPclient._setFriendlyFire(source, cfg.pvp)

    zRPclient._setProgressBar(source, "zRP:hunger", "minimap", htxt, 255, 153, 0, 0)
    zRPclient._setProgressBar(source, "zRP:thirst", "minimap", ttxt, 0, 125, 255, 0)
    zRP.setHunger(user_id, data.hunger)
    zRP.setThirst(user_id, data.thirst)
end)

-- EMERGENCY

---- revive
local revive_seq = {
    { "amb@medic@standing@kneel@enter", "enter", 1 },
    { "amb@medic@standing@kneel@idle_a", "idle_a", 1 },
    { "amb@medic@standing@kneel@exit", "exit", 1 }
}

function zRPMenu.choice_revive(player, nplayer)
    local nplayer_check = zRPclient.getNearestPlayers(player, 15)
    local is_ok = false
    for k, v in pairs(nplayer_check) do
        if k == nplayer then
            is_ok = true
        end
    end
    if is_ok then
        if zRPclient.isInComa(nplayer) then
            if zRP.tryGetInventoryItem(user_id, "medkit", 1, true) then
                zRPclient._playAnim(player, false, revive_seq, false) -- anim
                SetTimeout(15000, function()
                    zRPclient._varyHealth(nplayer, 50) -- heal 50
                end)
            end
        else
            zRPclient._notify(player, lang.emergency.menu.revive.not_in_coma())
        end
    else
        zRPclient._notify(player, lang.common.no_player_near())
    end
end

