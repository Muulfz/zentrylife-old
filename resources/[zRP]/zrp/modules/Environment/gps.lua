---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Marmota.
--- DateTime: 1/7/2019 11:17 PM
---

local cfg = module("cfg/Modules/Environment/gps")

local gps_menu = {name="GPS",css={top="75px",header_color="rgba(0,125,255,0.75)"}}
local function setMarker(player,choice)
    zRPclient._setGPS(player,cfg.gps[choice][2],cfg.gps[choice][3])
end


for k, v in pairs(cfg.gps) do
    gps_menu[k] = {setMarker,cfg.gps[k][1]}
end

SetTimeout(10000, function()
    local menu = zRP.buildMenu("gps", {})
    for k,v in pairs(menu) do
        gps_menu[k] = v
    end
end)

function zRPMenu.gps()
    return gps_menu
end
