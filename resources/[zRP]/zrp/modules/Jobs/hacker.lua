---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Muulfz.
--- DateTime: 12/4/2018 1:24 PM
---
local lang = zRP.lang
-- hack player

function zRPMenu.hacker_hack(player, choice)
    -- get nearest player
    local user_id = zRP.getUserId(player)
    if user_id ~= nil then
        local nplayer = zRPclient.getNearestPlayer(player,25)
        if nplayer ~= nil then
            local nuser_id = zRP.getUserId(nplayer)
            if nuser_id ~= nil then
                -- prompt number
                local nbank = zRP.getBankMoney(nuser_id)
                local amount = math.floor(nbank*0.01)
                local nvalue = nbank - amount
                if math.random(1,100) == 1 then
                    zRP.setBankMoney(nuser_id,nvalue)
                    zRPclient.notify(nplayer,lang.basic_menu.hacker.hacked({amount}))
                    zRP.giveInventoryItem(user_id,"dirty_money",amount,true)
                else
                    zRPclient.notify(nplayer,lang.basic_menu.hacker.failed.good())
                    zRPclient.notify(player,lang.basic_menu.hacker.failed.bad())
                end
            else
                zRPclient.notify(player,lang.common.no_player_near())
            end
        else
            zRPclient.notify(player,lang.common.no_player_near())
        end
    end
end