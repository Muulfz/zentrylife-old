-- periodic player state update

local state_ready = false

function tzRP.playerStateReady(state)
    state_ready = state
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(30000)

        if IsPlayerPlaying(PlayerId()) and state_ready then
            local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))

            zRPserver._updatePos(x, y, z)
            zRPserver._updateHealth(tzRP.getHealth())
            zRPserver._updateWeapons(tzRP.getWeapons())
            zRPserver._updateCustomization(tzRP.getCustomization())
        end
    end
end)

-- WEAPONS

-- def
local weapon_types = {
    "WEAPON_KNIFE",
    "WEAPON_STUNGUN",
    "WEAPON_FLASHLIGHT",
    "WEAPON_NIGHTSTICK",
    "WEAPON_HAMMER",
    "WEAPON_BAT",
    "WEAPON_GOLFCLUB",
    "WEAPON_CROWBAR",
    "WEAPON_PISTOL",
    "WEAPON_COMBATPISTOL",
    "WEAPON_APPISTOL",
    "WEAPON_PISTOL50",
    "WEAPON_MICROSMG",
    "WEAPON_SMG",
    "WEAPON_ASSAULTSMG",
    "WEAPON_ASSAULTRIFLE",
    "WEAPON_CARBINERIFLE",
    "WEAPON_ADVANCEDRIFLE",
    "WEAPON_MG",
    "WEAPON_COMBATMG",
    "WEAPON_PUMPSHOTGUN",
    "WEAPON_SAWNOFFSHOTGUN",
    "WEAPON_ASSAULTSHOTGUN",
    "WEAPON_BULLPUPSHOTGUN",
    "WEAPON_STUNGUN",
    "WEAPON_SNIPERRIFLE",
    "WEAPON_HEAVYSNIPER",
    "WEAPON_REMOTESNIPER",
    "WEAPON_GRENADELAUNCHER",
    "WEAPON_GRENADELAUNCHER_SMOKE",
    "WEAPON_RPG",
    "WEAPON_PASSENGER_ROCKET",
    "WEAPON_AIRSTRIKE_ROCKET",
    "WEAPON_STINGER",
    "WEAPON_MINIGUN",
    "WEAPON_GRENADE",
    "WEAPON_STICKYBOMB",
    "WEAPON_SMOKEGRENADE",
    "WEAPON_BZGAS",
    "WEAPON_MOLOTOV",
    "WEAPON_FIREEXTINGUISHER",
    "WEAPON_PETROLCAN",
    "WEAPON_DIGISCANNER",
    "WEAPON_BRIEFCASE",
    "WEAPON_BRIEFCASE_02",
    "WEAPON_BALL",
    "WEAPON_FLARE"
}

local weapon_list = {
}

function tzRP.getWeaponTypes()
    return weapon_types
end

function tzRP.getWeapons()
    local player = GetPlayerPed(-1)

    local ammo_types = {} -- remember ammo type to not duplicate ammo amount

    local weapons = {}
    for k, v in pairs(weapon_types) do
        local hash = GetHashKey(v)
        if HasPedGotWeapon(player, hash) then
            local weapon = {}
            weapons[v] = weapon

            local atype = Citizen.InvokeNative(0x7FEAD38B326B9F74, player, hash)
            if ammo_types[atype] == nil then
                ammo_types[atype] = true
                weapon.ammo = GetAmmoInPedWeapon(player, hash)
            else
                weapon.ammo = 0
            end
        end
    end

    tzRP.legalWeaponsChecker(weapons)

    return weapons
end

-- replace weapons (combination of getWeapons and giveWeapons)
-- return previous weapons
function tzRP.replaceWeapons(weapons)
    local old_weapons = tzRP.getWeapons()
    tzRP.giveWeapons(weapons, true)
    return old_weapons
end

function tzRP.giveWeapons(weapons, clear_before)
    local player = GetPlayerPed(-1)

    -- give weapons to player

    if clear_before then
        RemoveAllPedWeapons(player, true)
        weapon_list = {}
    end

    for k, weapon in pairs(weapons) do
        local hash = GetHashKey(k)
        local ammo = weapon.ammo or 0
        GiveWeaponToPed(player, hash, ammo, false)
        weapon_list[k] = weapon
    end

end
--todo

function tzRP.hasWeapons()
    for k,v in pairs(weapon_list) do
        return true
    end
    return false
end

function tzRP.hasArmour()
    if tzRP.getArmour() >= 95 then
        return true
    end
    return false
end

function tzRP.getWeaponsLegal()
    return weapon_list
end

function tzRP.legalWeaponsChecker(weapon)
    local weapon = weapon
    local weapons_legal = tzRP.getWeaponsLegal()
    local ilegal = false
    for v, b in pairs(weapon) do
        if not weapon_list[v] then
            ilegal = true
        end
    end
    if ilegal then
        --todo Colocar um aviso de hacker no player
        tzRP.giveWeapons(weapons_legal, true)
        weapon = {}
    end
    return weapon
end

--todo editar loja de venda


-- set player armour (0-100)
function tzRP.setArmour(amount)
    SetPedArmour(GetPlayerPed(-1), amount)
end

--[[
function tzRP.dropWeapon()
  SetPedDropsWeapon(GetPlayerPed(-1))
end
--]]

-- PLAYER CUSTOMIZATION

-- parse part key (a ped part or a prop part)
-- return is_proppart, index
local function parse_part(key)
    if type(key) == "string" and string.sub(key, 1, 1) == "p" then
        return true, tonumber(string.sub(key, 2))
    else
        return false, tonumber(key)
    end
end

function tzRP.getDrawables(part)
    local isprop, index = parse_part(part)
    if isprop then
        return GetNumberOfPedPropDrawableVariations(GetPlayerPed(-1), index)
    else
        return GetNumberOfPedDrawableVariations(GetPlayerPed(-1), index)
    end
end

function tzRP.getDrawableTextures(part, drawable)
    local isprop, index = parse_part(part)
    if isprop then
        return GetNumberOfPedPropTextureVariations(GetPlayerPed(-1), index, drawable)
    else
        return GetNumberOfPedTextureVariations(GetPlayerPed(-1), index, drawable)
    end
end

function tzRP.getCustomization()
    local ped = GetPlayerPed(-1)

    local custom = {}

    custom.modelhash = GetEntityModel(ped)

    -- ped parts
    for i = 0, 20 do
        -- index limit to 20
        custom[i] = { GetPedDrawableVariation(ped, i), GetPedTextureVariation(ped, i), GetPedPaletteVariation(ped, i) }
    end

    -- props
    for i = 0, 10 do
        -- index limit to 10
        custom["p" .. i] = { GetPedPropIndex(ped, i), math.max(GetPedPropTextureIndex(ped, i), 0) }
    end

    return custom
end

-- partial customization (only what is set is changed)
function tzRP.setCustomization(custom)
    -- indexed [drawable,texture,palette] components or props (p0...) plus .modelhash or .model
    local r = async()

    Citizen.CreateThread(function()
        -- new thread
        if custom then
            local ped = GetPlayerPed(-1)
            local mhash = nil

            -- model
            if custom.modelhash then
                mhash = custom.modelhash
            elseif custom.model then
                mhash = GetHashKey(custom.model)
            end

            if mhash then
                local i = 0
                while not HasModelLoaded(mhash) and i < 10000 do
                    RequestModel(mhash)
                    Citizen.Wait(10)
                end

                if HasModelLoaded(mhash) then
                    -- changing player model remove weapons and armour, so save it
                    local weapons = tzRP.getWeapons()
                    local armour = GetPedArmour(ped)
                    SetPlayerModel(PlayerId(), mhash)
                    tzRP.giveWeapons(weapons, true)
                    tzRP.setArmour(armour)
                    SetModelAsNoLongerNeeded(mhash)
                end
            end

            ped = GetPlayerPed(-1)

            -- parts
            for k, v in pairs(custom) do
                if k ~= "model" and k ~= "modelhash" then
                    local isprop, index = parse_part(k)
                    if isprop then
                        if v[1] < 0 then
                            ClearPedProp(ped, index)
                        else
                            SetPedPropIndex(ped, index, v[1], v[2], v[3] or 2)
                        end
                    else
                        SetPedComponentVariation(ped, index, v[1], v[2], v[3] or 2)
                    end
                end
            end
        end

        r()
    end)

    return r:wait()
end

-- fix invisible players by resetting customization every minutes
--[[
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(60000)
    if state_ready then
      local custom = tzRP.getCustomization()
      custom.model = nil
      custom.modelhash = nil
      tzRP.setCustomization(custom)
    end
  end
end)
--]]

local state_ready = false

AddEventHandler("playerSpawned", function()
    -- delay state recording
    state_ready = false

    Citizen.CreateThread(function()
        Citizen.Wait(30000)
        state_ready = true
    end)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(30000)

        if IsPlayerPlaying(PlayerId()) and state_ready then
            if tzRP.getArmour() == 0 then
                if (GetEntityModel(GetPlayerPed(-1)) == GetHashKey("mp_m_freemode_01")) or (GetEntityModel(GetPlayerPed(-1)) == GetHashKey("mp_f_freemode_01")) then
                    SetPedComponentVariation(GetPlayerPed(-1), 9, 0, 1, 2)
                end
            end
        end
    end
end)

-- Freeze
local frozen = false
local unfrozen = false
local other = nil
local drag = false
local playerStillDragged = false
local invisible = false
local invincible = false

function tzRP.loadFreeze(notify, god, ghost)
    if not frozen then
        if notify then
            tzRP.notify("Frezzado") -- lang.freeze.frozen()
        end
        frozen = true
        invincible = god
        invisible = ghost
        unfrozen = false
    else
        if notify then
            tzRP.notify("DesFreezadio") -- lang.freeze.unfrozen()
        end
        unfrozen = true
        invincible = false
        invisible = false
    end
end

function frozenT()
    if frozen then
        if unfrozen then
            SetEntityInvincible(GetPlayerPed(-1), false)
            SetEntityVisible(GetPlayerPed(-1), true)
            FreezeEntityPosition(GetPlayerPed(-1), false)
            frozen = false
            invisible = false
            invincible = false
        else
            if invincible then
                SetEntityInvincible(GetPlayerPed(-1), true)
            end
            if invisible then
                SetEntityVisible(GetPlayerPed(-1), false)
            end
            FreezeEntityPosition(GetPlayerPed(-1), true)
        end
    end
    Citizen.Wait(0)
end

Citizen.CreateThread(function()
    tzRP.legalWeaponsChecker(tzRP.getWeapons())
    tzRP.loadFreeze()
    while true do
        tzRP.legalWeaponsChecker(tzRP.getWeapons())
        --frozenT()
        spikesPolice()
        playerDrag()
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    customT()
    tattoThread()
end)

function tzRP.isPlayerBlockFull()
    if tzRP.isInComa() or tzRP.isFrozen() or tzRP.isJailed() or tzRP.isHandcuffed() then
        return true
    end
    return false
end
