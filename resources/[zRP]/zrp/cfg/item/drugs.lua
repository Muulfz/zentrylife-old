
local items = {}

local function play_drink(player)
  local seq = {
    {"mp_player_intdrink","intro_bottle",1},
    {"mp_player_intdrink","loop_bottle",1},
    {"mp_player_intdrink","outro_bottle",1}
  }

  zRPclient._playAnim(player,true,seq,false)
end

local pills_choices = {}
pills_choices["Take"] = {function(player,choice)
  local user_id = zRP.getUserId(player)
  if user_id then
    if zRP.tryGetInventoryItem(user_id,"pills",1) then
      zRPclient._varyHealth(player,25)
      zRPclient._notify(player,"~g~ Taking pills.")
      play_drink(player)
      zRP.closeMenu(player)
    end
  end
end}

items["pills"] = {"Pills","A simple medication.",function(args) return pills_choices end,0.1}

return items
