-- client-side zRP configuration

local cfg = {}

cfg.lang = "en"

cfg.iplload = true

cfg.voice_proximity = 30.0 -- default voice proximity (outside)
cfg.voice_proximity_vehicle = 5.0
cfg.voice_proximity_inside = 9.0

cfg.audio_listener_rate = 15 -- audio listener position update rate

cfg.audio_listener_on_player = false -- set the listener position on the player instead of the camera

cfg.gui = {
  anchor_minimap_width = 260,
  anchor_minimap_left = 60,
  anchor_minimap_bottom = 213
}

-- gui controls (see https://wiki.fivem.net/wiki/Controls)
-- recommended to keep the default values and ask players to change their keys
cfg.controls = {
  phone = {
    -- PHONE CONTROLS
    up = {3,172},
    down = {3,173},
    left = {3,174},
    right = {3,175},
    select = {3,176},
    cancel = {3,177},
    open = {3,56}, -- INPUT_PHONE, open general menu
    quick_menu = {3,311}
  },
  request = {
    yes = {1,166}, -- Michael, F5
    no = {1,167} -- Franklin, F6
  },
  radio = {1,246} -- team chat (Y)
}

-- disable menu if handcuffed
cfg.handcuff_disable_menu = true

-- disable menu if handcuffed
cfg.handcuff_disable_quick_menu = true

-- when health is under the threshold, player is in coma
-- set to 0 to disable coma
cfg.coma_threshold = 120

-- maximum duration of the coma in minutes
cfg.coma_duration = 10

-- if true, a player in coma will not be able to open the main menu
cfg.coma_disable_menu = false

-- if true, a player in coma will not be able to open the main menu
cfg.coma_disable_quick_menu = false

-- see https://wiki.fivem.net/wiki/Screen_Effects
cfg.coma_effect = "DeathFailMPIn"

-- set to true to disable the default voice chat and use zRP voip instead (world channel)
cfg.zrp_voip = false

-- radius to establish VoIP connections
cfg.voip_proximity = 100

-- connect/disconnect interval in milliseconds
cfg.voip_interval = 5000

-- zRP.configureVoice settings
-- world
cfg.world_voice_config = {
  effects = {
    spatialization = { max_dist = cfg.voip_proximity }
  }
}

-- phone
cfg.phone_voice_config = {
}

-- radio
cfg.radio_voice_config = {
  effects = {
    biquad = { type = "bandpass", frequency = 1700, Q = 2, gain = 1.2 }
  }
}

cfg.peds_control = {
  density = {
    peds = 1.0,
    vehicles = 1.0
  },
  peds = { -- these peds wont show up anywhere, they will be removed and their vehicles deleted
    "s_m_y_cop_01",
    "s_f_y_sheriff_01",
    "s_m_y_sheriff_01",
    "s_m_y_hwaycop_01",
    "s_m_y_swat_01",
    "s_m_m_snowcop_01",
    "s_m_m_paramedic_01"
  },
  noguns = { -- these peds wont have any weapons
  },
  nodrops = { -- these peds wont drop their weapons when killed
  }
}


return cfg
