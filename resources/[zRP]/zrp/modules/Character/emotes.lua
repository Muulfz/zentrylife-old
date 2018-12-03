
-- this module define the emotes menu

local cfg = module("cfg/Modules/emotes")
local lang = zRP.lang

local emotes = cfg.emotes

 function zRPMenu.player_emote(player,choice)
  local emote = emotes[choice]
  if emote then
    zRPclient._playAnim(player,emote[1],emote[2],emote[3])
  end
end

-- add emotes menu to main menu
