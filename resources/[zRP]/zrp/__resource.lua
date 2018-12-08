
description "RP module/framework"

ui_page "gui/index.html"

-- server scripts
server_scripts{ 
  "lib/utils.lua",
  "base.lua",
  "modules/Utils/ModuleLoader.lua",
  "modules/Interface/gui.lua",
  "modules/Character/group.lua",
  "modules/Admin/admin.lua",
  "modules/Character/survival.lua",
  "modules/Character/player_state.lua",
  "modules/Environment/map.lua",
  "modules/Economy/money.lua",
  "modules/Character/inventory.lua",
  "modules/Character/identity.lua",
  "modules/Economy/business.lua",
  "modules/Item/item_transformer.lua",
  "modules/Character/emotes.lua",
  "modules/Jobs/Government/police.lua",
  "modules/Properties/home.lua",
  "modules/Properties/home_components.lua",
  "modules/Jobs/mission.lua",
  "modules/Jobs/hacker.lua",
  "modules/Jobs/thief.lua",
  "modules/Character/player.lua",
  "modules/Character/aptitude.lua",
  "modules/Menu/main.lua",
  "modules/Menu/admin.lua",
  "modules/Menu/basic_phone.lua",
  "modules/Menu/basic_radio.lua",
  "modules/Menu/police.lua",

  -- basic implementations
  "modules/Character/basic_phone.lua",
  "modules/Economy/basic_atm.lua",
  "modules/Shop/basic_market.lua",
  "modules/Shop/basic_gunshop.lua",
  "modules/Shop/basic_garage.lua",
  "modules/Item/basic_items.lua",
  "modules/Shop/basic_skinshop.lua",
  "modules/Character/cloakroom.lua",
  "modules/Character/basic_radio.lua",
  "modules/Shop/adv_garages.lua",
  "modules/Shop/basic_armorshop.lua",
  "modules/Shop/basic_barbershop.lua",
  "modules/Shop/carwash.lua",
  "modules/Missions/basic_mission.lua",
}

-- client scripts
client_scripts{
  "lib/utils.lua",
  "client/base.lua",
  "client/Environment/iplloader.lua",
  "client/Interface/gui.lua",
  "client/Character/player_state.lua",
  "client/Character/survival.lua",
  "client/Environment/map.lua",
  "client/Character/identity.lua",
  "client/Shop/basic_garage.lua",
  "client/Jobs/Government/police.lua",
  "client/Admin/admin.lua",
  "client/Character/basic_phone.lua",
  "client/Character/basic_radio.lua",
  "client/Shop/adv_garage.lua",
  "client/Utils/NativesUtils.lua",
  "client/Character/armor.lua",
  "client/Character/custom.lua",
  "client/Shop/carwash.lua"
}

-- client files
files{
  "lib/Tunnel.lua",
  "lib/Proxy.lua",
  "lib/Debug.lua",
  "lib/Luaseq.lua",
  "lib/Tools.lua",
  "cfg/Client/base.lua",
  "cfg/lang/client/en.lua",
  "gui/index.html",
  "gui/design.css",
  "gui/main.js",
  "gui/Menu.js",
  "gui/ProgressBar.js",
  "gui/WPrompt.js",
  "gui/RequestManager.js",
  "gui/AnnounceManager.js",
  "gui/Div.js",
  "gui/dynamic_classes.js",
  "gui/AudioEngine.js",
  "gui/lib/libopus.wasm.js",
  "gui/images/voice_active.png",
  "gui/sounds/phone_dialing.ogg",
  "gui/sounds/phone_ringing.ogg",
  "gui/sounds/phone_sms.ogg",
  "gui/sounds/radio_on.ogg",
  "gui/sounds/radio_off.ogg"
}
