local items = {}

local function bvest_choices(args)
  local choices = {}

  choices["Wear"] = {function(player, choice)
    local user_id = zRP.getUserId(player)
    if user_id then
      if zRP.tryGetInventoryItem(user_id, args[1], 1, true) then -- take vest
        zRPclient._setArmour(player, 100)
      end
    end
  end}

  return choices
end

items["bulletproof_vest"] = {"Bulletproof Vest", "A handy protection.", bvest_choices, 1.5}

return items
