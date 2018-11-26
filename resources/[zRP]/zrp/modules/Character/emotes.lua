
--TODO trocar para Character
-- this module define the emotes menu

local cfg = module("cfg/Modules/emotes")
local lang = zRP.lang

local emotes = cfg.emotes

local function ch_emote(player,choice)
  local emote = emotes[choice]
  if emote then
    zRPclient._playAnim(player,emote[1],emote[2],emote[3])
  end
end

-- add emotes menu to main menu

zRP.registerMenuBuilder("main", function(add, data)
  local choices = {}
  choices[lang.emotes.title()] = {function(player, choice)
    -- build emotes menu
    local menu = {name=lang.emotes.title(),css={top="75px",header_color="rgba(0,125,255,0.75)"}}
    local user_id = zRP.getUserId(player)

    if user_id then
      -- add emotes to the emote menu
      for k,v in pairs(emotes) do
        if zRP.hasPermissions(user_id, v.permissions or {}) then
          menu[k] = {ch_emote}
        end
      end
    end

    -- clear current emotes
    menu[lang.emotes.clear.title()] = {function(player,choice)
      zRPclient._stopAnim(player,true) -- upper
      zRPclient._stopAnim(player,false) -- full
    end, lang.emotes.clear.description()}

    zRP.openMenu(player,menu)
  end}
  add(choices)
end)
