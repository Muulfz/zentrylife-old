local rplayers = {} -- radio players that can be accepted

function tzRP.setupRadio(players)
  rplayers = players
end

function tzRP.disconnectRadio()
  rplayers = {}
  tzRP.disconnectVoice("radio", nil)
end

-- radio channel behavior
tzRP.registerVoiceCallbacks("radio", function(player)
  print("(zRPvoice-radio) requested by "..player)
  return (rplayers[player] ~= nil)
end,
function(player, is_origin)
  print("(zRPvoice-radio) connected to "..player)
end,
function(player)
  print("(zRPvoice-radio) disconnected from "..player)
end)

AddEventHandler("zRP:NUIready", function()
  -- radio channel config
  tzRP.configureVoice("radio", cfg.radio_voice_config)
end)

-- radio push-to-talk
local talking = false

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)

    local old_talking = talking
    talking = IsControlPressed(table.unpack(cfg.controls.radio))

    if old_talking ~= talking then
      tzRP.setVoiceState("world", nil, talking)
      tzRP.setVoiceState("radio", nil, talking)
    end
  end
end)
