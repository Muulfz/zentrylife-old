
description "zRP GHMattiMySQL db driver bridge"

dependencies{
  "zrp",
  "GHMattiMySQL"
}

-- server scripts
server_scripts{ 
  "@zrp/lib/utils.lua",
  "init.lua"
}
