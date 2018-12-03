
local lang = zRP.lang
local cfg = module("cfg/Modules/radio")

local cgroups = {}
local rusers = {}

-- build groups connect graph
for k,v in pairs(cfg.channels) do
  for _,g1 in pairs(v) do
    local group = cgroups[g1]
    if not group then
      group = {}
      cgroups[g1] = group
    end

    for _,g2 in pairs(v) do
      group[g2] = true
    end
  end
end

-- connect the user to the radio
function zRP.connectRadio(user_id)
  if not rusers[user_id] then
    local player = zRP.getUserSource(user_id)
    if player then
      -- send map of players to connect to for this radio
      local groups = zRP.getUserGroups(user_id)
      local players = {}
      for ruser,_ in pairs(rusers) do -- each radio user
        for k,v in pairs(groups) do -- each player group
          for cgroup,_ in pairs(cgroups[k] or {}) do -- each group from connect graph for this group
            if zRP.hasGroup(ruser, cgroup) then -- if in group
              local rplayer = zRP.getUserSource(ruser)
              if rplayer then
                players[rplayer] = true
              end
            end
          end
        end
      end

      zRPclient._playAudioSource(player, cfg.on_sound, 0.5)
      zRPclient.setupRadio(player, players)
      -- wait setup and connect all radio players to this new one
      for k,v in pairs(players) do
        zRPclient._connectVoice(k, "radio", player)
      end

      rusers[user_id] = true
    end
  end
end

-- disconnect the user from the radio
function zRP.disconnectRadio(user_id)
  if rusers[user_id] then
    rusers[user_id] = nil
    local player = zRP.getUserSource(user_id)
    if player then
      zRPclient._playAudioSource(player, cfg.off_sound, 0.5)
      zRPclient._disconnectRadio(player)
    end
  end
end


-- menu
function zRPMenu.basic_radio_cgroup()
  return cgroups
end

-- events

AddEventHandler("zRP:playerLeave",function(user_id, source)
  zRP.disconnectRadio(user_id)
end)

-- disconnect radio on group changes

AddEventHandler("zRP:playerLeaveGroup", function(user_id, group, gtype)
  zRP.disconnectRadio(user_id)
end)

AddEventHandler("zRP:playerJoinGroup", function(user_id, group, gtype)
  zRP.disconnectRadio(user_id)
end)
