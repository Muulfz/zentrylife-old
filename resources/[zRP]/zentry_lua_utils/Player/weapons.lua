local Config = {}

-- 'bone' use bonetag https://pastebin.com/D7JMnX1g
-- x,y,z are offsets
Config.RealWeapons = {

    { name = 'WEAPON_KNIFE', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'melee', model = 'prop_w_me_knife_01' },
    { name = 'WEAPON_NIGHTSTICK', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'melee', model = 'w_me_nightstick' },
    { name = 'WEAPON_HAMMER', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'melee', model = 'prop_tool_hammer' },
    { name = 'WEAPON_BAT', bone = 24818, x = 0.1, y = -0.15, z = 0.0, xRot = 0.0, yRot = 135.0, zRot = 0.0, category = 'melee', model = 'w_me_bat' },
    { name = 'WEAPON_GOLFCLUB', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'melee', model = 'w_me_gclub' },
    { name = 'WEAPON_CROWBAR', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'melee', model = 'w_me_crowbar' },
    { name = 'WEAPON_BOTTLE', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'melee', model = 'prop_w_me_bottle' },
    { name = 'WEAPON_KNUCKLE', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'melee', model = 'prop_w_me_dagger' },
    { name = 'WEAPON_HATCHET', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'melee', model = 'w_me_hatchet' },
    { name = 'WEAPON_MACHETE', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'melee', model = 'prop_ld_w_me_machette' },
    { name = 'WEAPON_SWITCHBLADE', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'melee', model = 'prop_w_me_dagger' },
    { name = 'WEAPON_FLASHLIGHT', bone = 24818, x = 0.0, y = 0.0, z = 0.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'melee', model = 'prop_w_me_dagger' },

    { name = 'WEAPON_PISTOL', bone = 51826, x = -0.01, y = 0.10, z = 0.07, xRot = -115.0, yRot = 0.0, zRot = 0.0, category = 'handguns', model = 'w_pi_pistol' },
    { name = 'WEAPON_COMBATPISTOL', bone = 51826, x = -0.01, y = 0.10, z = 0.07, xRot = -115.0, yRot = 0.0, zRot = 0.0, category = 'handguns', model = 'w_pi_combatpistol' },
    { name = 'WEAPON_APPISTOL', bone = 51826, x = -0.01, y = 0.10, z = 0.07, xRot = -115.0, yRot = 0.0, zRot = 0.0, category = 'handguns', model = 'w_pi_appistol' },
    { name = 'WEAPON_PISTOL50', bone = 51826, x = -0.01, y = 0.10, z = 0.07, xRot = -115.0, yRot = 0.0, zRot = 0.0, category = 'handguns', model = 'w_pi_pistol50' },
    { name = 'WEAPON_VINTAGEPISTOL', bone = 51826, x = -0.01, y = 0.10, z = 0.07, xRot = -115.0, yRot = 0.0, zRot = 0.0, category = 'handguns', model = 'w_pi_vintage_pistol' },
    { name = 'WEAPON_HEAVYPISTOL', bone = 51826, x = -0.01, y = 0.10, z = 0.07, xRot = -115.0, yRot = 0.0, zRot = 0.0, category = 'handguns', model = 'w_pi_heavypistol' },
    { name = 'WEAPON_SNSPISTOL', bone = 58271, x = -0.01, y = 0.1, z = -0.07, xRot = -55.0, yRot = 0.10, zRot = 0.0, category = 'handguns', model = 'w_pi_sns_pistol' },
    { name = 'WEAPON_FLAREGUN', bone = 58271, x = -0.01, y = 0.1, z = -0.07, xRot = -55.0, yRot = 0.10, zRot = 0.0, category = 'handguns', model = 'w_pi_flaregun' },
    { name = 'WEAPON_MARKSMANPISTOL', bone = 58271, x = -0.01, y = 0.1, z = -0.07, xRot = -55.0, yRot = 0.10, zRot = 0.0, category = 'handguns', model = '' },
    { name = 'WEAPON_REVOLVER', bone = 58271, x = -0.01, y = 0.1, z = -0.07, xRot = -55.0, yRot = 0.10, zRot = 0.0, category = 'handguns', model = '' },
    { name = 'WEAPON_STUNGUN', bone = 58271, x = -0.01, y = 0.1, z = -0.07, xRot = -55.0, yRot = 0.10, zRot = 0.0, category = 'handguns', model = 'w_pi_stungun' },

    { name = 'WEAPON_MICROSMG', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'machine', model = 'w_sb_microsmg' },
    { name = 'WEAPON_SMG', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'machine', model = 'w_sb_smg' },
    { name = 'WEAPON_MG', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'machine', model = 'w_mg_mg' },
    { name = 'WEAPON_COMBATMG', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'machine', model = 'w_mg_combatmg' },
    { name = 'WEAPON_GUSENBERG', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'machine', model = 'w_sb_gusenberg' },
    { name = 'WEAPON_COMBATPDW', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'machine', model = '' },
    { name = 'WEAPON_MACHINEPISTOL', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'machine', model = '' },
    { name = 'WEAPON_ASSAULTSMG', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'machine', model = 'w_sb_assaultsmg' },
    { name = 'WEAPON_MINISMG', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'machine', model = '' },

    { name = 'WEAPON_ASSAULTRIFLE', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'assault', model = 'w_ar_assaultrifle' },
    { name = 'WEAPON_CARBINERIFLE', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'assault', model = 'w_ar_carbinerifle' },
    { name = 'WEAPON_ADVANCEDRIFLE', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'assault', model = 'w_ar_advancedrifle' },
    { name = 'WEAPON_SPECIALCARBINE', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'assault', model = 'w_ar_specialcarbine' },
    { name = 'WEAPON_BULLPUPRIFLE', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'assault', model = 'w_ar_bullpuprifle' },
    { name = 'WEAPON_COMPACTRIFLE', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'assault', model = '' },

    { name = 'WEAPON_PUMPSHOTGUN', bone = 24818, x = 0.1, y = -0.15, z = 0.0, xRot = 0.0, yRot = 135.0, zRot = 0.0, category = 'shotgun', model = 'w_sg_pumpshotgun' },
    { name = 'WEAPON_SAWNOFFSHOTGUN', bone = 24818, x = 0.1, y = -0.15, z = 0.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'shotgun', model = '' },
    { name = 'WEAPON_BULLPUPSHOTGUN', bone = 24818, x = 0.1, y = -0.15, z = 0.0, xRot = 0.0, yRot = 135.0, zRot = 0.0, category = 'shotgun', model = 'w_sg_bullpupshotgun' },
    { name = 'WEAPON_ASSAULTSHOTGUN', bone = 24818, x = 0.1, y = -0.15, z = 0.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'shotgun', model = 'w_sg_assaultshotgun' },
    { name = 'WEAPON_MUSKET', bone = 24818, x = 0.1, y = -0.15, z = 0.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'shotgun', model = 'w_ar_musket' },
    { name = 'WEAPON_HEAVYSHOTGUN', bone = 24818, x = 0.1, y = -0.15, z = 0.0, xRot = 0.0, yRot = 225.0, zRot = 0.0, category = 'shotgun', model = 'w_sg_heavyshotgun' },
    { name = 'WEAPON_DBSHOTGUN', bone = 24818, x = 0.1, y = -0.15, z = 0.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'shotgun', model = '' },
    { name = 'WEAPON_AUTOSHOTGUN', bone = 24818, x = 0.1, y = 0.15, z = 0.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'shotgun', model = '' },

    { name = 'WEAPON_SNIPERRIFLE', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'sniper', model = 'w_sr_sniperrifle' },
    { name = 'WEAPON_HEAVYSNIPER', bone = 24818, x = 0.1, y = -0.15, z = 0.0, xRot = 0.0, yRot = 135.0, zRot = 0.0, category = 'sniper', model = 'w_sr_heavysniper' },
    { name = 'WEAPON_MARKSMANRIFLE', bone = 24818, x = 0.1, y = -0.15, z = 0.0, xRot = 0.0, yRot = 135.0, zRot = 0.0, category = 'sniper', model = 'w_sr_marksmanrifle' },

    { name = 'WEAPON_REMOTESNIPER', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'none', model = '' },
    { name = 'WEAPON_STINGER', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'none', model = '' },

    { name = 'WEAPON_GRENADELAUNCHER', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'heavy', model = 'w_lr_grenadelauncher' },
    { name = 'WEAPON_RPG', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'heavy', model = 'w_lr_rpg' },
    { name = 'WEAPON_MINIGUN', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'heavy', model = 'w_mg_minigun' },
    { name = 'WEAPON_FIREWORK', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'heavy', model = 'w_lr_firework' },
    { name = 'WEAPON_RAILGUN', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'heavy', model = 'w_ar_railgun' },
    { name = 'WEAPON_HOMINGLAUNCHER', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'heavy', model = 'w_lr_homing' },
    { name = 'WEAPON_COMPACTLAUNCHER', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'heavy', model = '' },

    { name = 'WEAPON_STICKYBOMB', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'thrown', model = 'prop_bomb_01_s' },
    { name = 'WEAPON_MOLOTOV', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'thrown', model = 'w_ex_molotov' },
    { name = 'WEAPON_FIREEXTINGUISHER', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'thrown', model = 'w_am_fire_exting' },
    { name = 'WEAPON_PETROLCAN', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'thrown', model = 'w_am_jerrycan' },
    { name = 'WEAPON_PROXMINE', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'thrown', model = '' },
    { name = 'WEAPON_SNOWBALL', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'thrown', model = 'w_ex_snowball' },
    { name = 'WEAPON_BALL', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'thrown', model = 'w_am_baseball' },
    { name = 'WEAPON_GRENADE', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'thrown', model = 'w_ex_grenadefrag' },
    { name = 'WEAPON_SMOKEGRENADE', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'thrown', model = 'w_ex_grenadesmoke' },
    { name = 'WEAPON_BZGAS', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'thrown', model = 'w_ex_grenadesmoke' },

    { name = 'WEAPON_DIGISCANNER', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'others', model = 'w_am_digiscanner' },
    { name = 'WEAPON_DAGGER', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'others', model = 'prop_w_me_dagger' },
    { name = 'WEAPON_GARBAGEBAG', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'others', model = '' },
    { name = 'WEAPON_HANDCUFFS', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'others', model = '' },
    { name = 'WEAPON_BATTLEAXE', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'others', model = 'prop_tool_fireaxe' },
    { name = 'WEAPON_PIPEBOMB', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'others', model = '' },
    { name = 'WEAPON_POOLCUE', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'others', model = 'prop_pool_cue' },
    { name = 'WEAPON_WRENCH', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'others', model = 'w_me_hammer' },
    { name = 'GADGET_NIGHTVISION', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'others', model = '' },
    { name = 'GADGET_PARACHUTE', bone = 24818, x = 65536.0, y = 65536.0, z = 65536.0, xRot = 0.0, yRot = 0.0, zRot = 0.0, category = 'others', model = 'p_parachute_s' }
}

local Weapons = {}

-----------------------------------------------------------
-----------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        local playerPed = GetPlayerPed(-1)


        for i = 1, #Config.RealWeapons, 1 do

            local weaponHash = GetHashKey(Config.RealWeapons[i].name)

            if HasPedGotWeapon(playerPed, weaponHash, false) then
                local onPlayer = false

                for k, entity in pairs(Weapons) do
                    if entity then
                        if entity.weapon == Config.RealWeapons[i].name then
                            onPlayer = true
                            break
                        end
                    end
                end

                if not onPlayer and weaponHash ~= GetSelectedPedWeapon(playerPed) then
                    SetGear(Config.RealWeapons[i].name)
                elseif onPlayer and weaponHash == GetSelectedPedWeapon(playerPed) then
                    RemoveGear(Config.RealWeapons[i].name)
                end
            else
                RemoveGear(Config.RealWeapons[i].name)
            end
        end
        Wait(500)
    end
end)
-----------------------------------------------------------
-----------------------------------------------------------
RegisterNetEvent('removeWeapon')
AddEventHandler('removeWeapon', function(weaponName)
    RemoveGear(weaponName)
end)
RegisterNetEvent('removeWeapons')
AddEventHandler('removeWeapons', function()
    RemoveGears()
end)
-----------------------------------------------------------
-----------------------------------------------------------
-- Remove only one weapon that's on the ped
function RemoveGear(weapon)
    local _Weapons = {}

    for i, entity in pairs(Weapons) do
        if entity.weapon ~= weapon then
            _Weapons[i] = entity
        else
            DeleteWeapon(entity.obj)
        end
    end

    Weapons = _Weapons
end
-----------------------------------------------------------
-----------------------------------------------------------
-- Remove all weapons that are on the ped
function RemoveGears()
    for i, entity in pairs(Weapons) do
        DeleteWeapon(entity.obj)
    end
    Weapons = {}
end
-----------------------------------------------------------
-----------------------------------------------------------
function SpawnObject(model, coords, cb)

    local model = (type(model) == 'number' and model or GetHashKey(model))
    -- Thread: https://forum.fivem.net/t/low-fps-and-extremely-degradation-of-the-performance-overtime/99158/16
    if not IsModelInCdimage(model) then
        return 0
    end -- This might fix FPS/Memory issue
    Citizen.CreateThread(function()

        RequestModel(model)

        while not HasModelLoaded(model) do
            Citizen.Wait(0)
        end

        local obj = CreateObject(model, coords.x, coords.y, coords.z, true, true, true)

        if cb ~= nil then
            cb(obj)
        end

    end)

end

function DeleteWeapon(object)
    SetEntityAsMissionEntity(object, false, true)
    DeleteObject(object)
end
-- Add one weapon on the ped
function SetGear(weapon)
    local bone = nil
    local boneX = 0.0
    local boneY = 0.0
    local boneZ = 0.0
    local boneXRot = 0.0
    local boneYRot = 0.0
    local boneZRot = 0.0
    local playerPed = GetPlayerPed(-1)
    local model = nil
    local playerWeapons = getWeapons()

    for i = 1, #Config.RealWeapons, 1 do
        if Config.RealWeapons[i].name == weapon then
            bone = Config.RealWeapons[i].bone
            boneX = Config.RealWeapons[i].x
            boneY = Config.RealWeapons[i].y
            boneZ = Config.RealWeapons[i].z
            boneXRot = Config.RealWeapons[i].xRot
            boneYRot = Config.RealWeapons[i].yRot
            boneZRot = Config.RealWeapons[i].zRot
            model = Config.RealWeapons[i].model
            break
        end
    end

    SpawnObject(model, {
        x = x,
        y = y,
        z = z
    }, function(obj)
        local playerPed = GetPlayerPed(-1)
        local boneIndex = GetPedBoneIndex(playerPed, bone)
        local bonePos = GetWorldPositionOfEntityBone(playerPed, boneIndex)
        AttachEntityToEntity(obj, playerPed, boneIndex, boneX, boneY, boneZ, boneXRot, boneYRot, boneZRot, false, false, false, false, 2, true)
        table.insert(Weapons, { weapon = weapon, obj = obj })
    end)
end

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
    "WEAPON_SPECIALCARBINE",
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
    "WEAPON_FLARE",
    --"WEAPON_UNARMED",
    "WEAPON_BOTTLE",
    "WEAPON_ANIMAL",
    "WEAPON_KNUCKLE",
    "WEAPON_SNSPISTOL",
    "WEAPON_COUGAR",
    "WEAPON_KNIFE",
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
    "WEAPON_FLARE",
    "WEAPON_VEHICLE_ROCKET",
    "WEAPON_BARBED_WIRE",
    "WEAPON_DROWNING",
    "WEAPON_DROWNING_IN_VEHICLE",
    "WEAPON_BLEEDING",
    "WEAPON_ELECTRIC_FENCE",
    "WEAPON_EXPLOSION",
    "WEAPON_FALL",
    "WEAPON_HIT_BY_WATER_CANNON",
    "WEAPON_RAMMED_BY_CAR",
    "WEAPON_RUN_OVER_BY_CAR",
    "WEAPON_HELI_CRASH",
    "WEAPON_FIRE",
    "GADGET_NIGHTVISION",
    "GADGET_PARACHUTE",
    "WEAPON_HEAVYSHOTGUN",
    "WEAPON_MARKSMANRIFLE",
    "WEAPON_HOMINGLAUNCHER",
    "WEAPON_PROXMINE",
    "WEAPON_SNOWBALL",
    "WEAPON_FLAREGUN",
    "WEAPON_GARBAGEBAG",
    "WEAPON_HANDCUFFS",
    "WEAPON_COMBATPDW",
    "WEAPON_MARKSMANPISTOL",
    "WEAPON_HATCHET",
    "WEAPON_RAILGUN",
    "WEAPON_MACHETE",
    "WEAPON_MACHINEPISTOL",
    "WEAPON_AIR_DEFENCE_GUN",
    "WEAPON_SWITCHBLADE",
    "WEAPON_REVOLVER"
}

function getWeapons()
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

    return weapons
end

-----------------------------------------------------------
-----------------------------------------------------------
-- Add all the weapons in the xPlayer's loadout
-- on the ped
function SetGears()
    local bone = nil
    local boneX = 0.0
    local boneY = 0.0
    local boneZ = 0.0
    local boneXRot = 0.0
    local boneYRot = 0.0
    local boneZRot = 0.0
    local playerPed = GetPlayerPed(-1)
    local model = nil
    local playerWeapons = getWeapons()
    local weapon = nil

    for k, v in pairs(playerWeapons) do

        for j = 1, #Config.RealWeapons, 1 do
            if Config.RealWeapons[j].name == k then

                bone = Config.RealWeapons[j].bone
                boneX = Config.RealWeapons[j].x
                boneY = Config.RealWeapons[j].y
                boneZ = Config.RealWeapons[j].z
                boneXRot = Config.RealWeapons[j].xRot
                boneYRot = Config.RealWeapons[j].yRot
                boneZRot = Config.RealWeapons[j].zRot
                model = Config.RealWeapons[j].model
                weapon = Config.RealWeapons[j].name

                break

            end
        end

        local _wait = true

        SpawnObject(model, {
            x = x,
            y = y,
            z = z
        }, function(obj)

            local playerPed = GetPlayerPed(-1)
            local boneIndex = GetPedBoneIndex(playerPed, bone)
            local bonePos = GetWorldPositionOfEntityBone(playerPed, boneIndex)

            AttachEntityToEntity(obj, playerPed, boneIndex, boneX, boneY, boneZ, boneXRot, boneYRot, boneZRot, false, false, false, false, 2, true)

            table.insert(Weapons, { weapon = weapon, obj = obj })

            _wait = false

        end)

        while _wait do
            Wait(0)
        end
    end

end
