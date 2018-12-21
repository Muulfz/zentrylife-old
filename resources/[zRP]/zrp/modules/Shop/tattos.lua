---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Muulfz.
--- DateTime: 12/8/2018 6:29 PM
---
local cfg = module("cfg/Modules/Shop/tattos")
local lang = zRP.lang

-- build tattooshop menus
function zRP.openTattooshop(source, shop)
    local user_id = zRP.getUserId(source)
    local menudata = {
        name=lang.tattoos.title(),
        css={top = "75px", header_color="rgba(255,0,0,0.75)"}
    }

    -- build tattooshop items
    local kitems = {}
    local old_custom = zRPclient.getTattoos(source)

    -- item choice
    local tattoshop_choice = function(player,choice)
        local tattoo = cfg.tattoos[shop][choice][1]
        local price = cfg.tattoos[shop][choice][2]

        if tattoo then
            local applied = false
            if tattoo == "CLEAR" then
                zRPclient._notify(source,lang.tattoos.cleaned())
                zRPclient._cleanPlayer(source)
            else
                local custom = zRPclient._getTattoos(source)
                for k,v in pairs(custom) do
                    if k == tattoo then
                        applied = true
                    end
                end
                if not applied then
                    zRPclient._notify(source,lang.tattoos.added())
                    zRPclient._addTattoo(source, tattoo, shop, price)
                else
                    zRPclient._notify(source,lang.tattoos.removed())
                    zRPclient._delTattoo(source,tattoo)
                end
            end
        end
    end

    menudata.onclose = function(player)
        -- compute price
        local custom = zRPclient._getTattoos(source)
        local price = 0
        for k,v in pairs(custom) do
            local old = old_custom[k]
            if not old then price = price + v[2] end -- change of tattoo
        end

        if zRP.tryPayment(user_id,price) then
            zRP.setUData(user_id,"zRP:tattoos",json.encode(custom))
            if price > 0 then
                zRPclient._notify(source,lang.money.paid({price}))
            end
        else
            zRPclient._notify(source,lang.money.not_enough())
            -- revert changes
            zRPclient._setTattoos(source,old_custom)
        end
    end

    -- add item options
    for k,v in pairs(cfg.tattoos[shop]) do
        if k ~= "_config" then -- ignore config property
            menudata[k] = {tattoshop_choice,lang.garage.buy.info({v[2],v[3]})} -- add description
        end
    end

    zRP.openMenu(source,menudata)
end

local function build_client_tattooshops(source)
    local user_id = zRP.getUserId(source)
    if user_id ~= nil then
        for k,v in pairs(cfg.shops) do
            local shop,x,y,z = table.unpack(v)
            local group = cfg.tattoos[shop]

            if group then
                local gcfg = group._config

                local function tattooshop_enter(source)
                    local user_id = zRP.getUserId(source)
                    if user_id and zRP.hasPermissions(user_id,gcfg.permissions or {}) then
                        zRP.openTattooshop(source,shop)
                    end
                end

                local function tattooshop_leave(source)
                    zRP.closeMenu(source)
                end
                zRPclient._addBlip(source,x,y,z,gcfg.blipid,gcfg.blipcolor,gcfg.title)
                zRPclient._addMarker(source,x,y,z-1,0.7,0.7,0.5,0,255,125,125,150)

                zRP.setArea(source,"zRP:tattooshop"..k,x,y,z,1,1.5,tattooshop_enter,tattooshop_leave)
            end
        end
    end
end

AddEventHandler("zRP:playerSpawn",function(user_id, source, first_spawn)
    if first_spawn then
        build_client_tattooshops(source)
        local data = zRP.getUData(user_id,"zRP:tattoos")
        if data then
            local tattoos = json.decode(data)
            zRPclient._setTattoos(source,tattoos)
        end
    end
end)