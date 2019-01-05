local player_called
local in_call = false

function tzRP.phoneCallWaiting(player, waiting)
  if waiting then
    player_called = player
  else
    player_called = nil
  end
end

function tzRP.phoneHangUp()
  tzRP.disconnectVoice("phone", nil)
end

-- phone channel behavior
tzRP.registerVoiceCallbacks("phone", function(player)
  print("(zRPvoice-phone) requested by "..player)
  if player == player_called then
    player_called = nil
    return true
  end
end,
function(player, is_origin)
  print("(zRPvoice-phone) connected to "..player)
  in_call = true
  tzRP.setVoiceState("phone", nil, true)
  tzRP.setVoiceState("world", nil, true)
end,
function(player)
  print("(zRPvoice-phone) disconnected from "..player)
  in_call = false
  if not tzRP.isSpeaking() then -- end world voice if not speaking
    tzRP.setVoiceState("world", nil, false)
  end
end)

AddEventHandler("zRP:NUIready", function()
  -- phone channel config
  tzRP.configureVoice("phone", cfg.phone_voice_config)
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(500)
    if in_call then -- force world voice if in a phone call
      tzRP.setVoiceState("world", nil, true)
    end
  end
end)

