
-- a basic ATM implementation

--TODO trocar para Character
local lang = zRP.lang
local cfg = module("cfg/Modules/atms")
local atms = cfg.atms

local function play_atm_enter(player)
  zRPclient._playAnim(player,false,{{"amb@prop_human_atm@male@enter","enter"},{"amb@prop_human_atm@male@idle_a","idle_a"}},false)
end

local function play_atm_exit(player)
  zRPclient._playAnim(player,false,{{"amb@prop_human_atm@male@exit","exit"}},false)
end

local function atm_choice_deposit(player,choice)
  play_atm_enter(player) --anim

  local v = zRP.prompt(source,lang.atm.deposit.prompt(),"")
  play_atm_exit(player)

  v = parseInt(v)

  if v > 0 then
    local user_id = zRP.getUserId(source)
    if user_id then
      if zRP.tryDeposit(user_id,v) then
        zRPclient._notify(source,lang.atm.deposit.deposited({v}))
      else
        zRPclient._notify(source,lang.money.not_enough())
      end
    end
  else
    zRPclient._notify(source,lang.common.invalid_value())
  end
end

local function atm_choice_withdraw(player,choice)
  play_atm_enter(player)

  local v = zRP.prompt(source,lang.atm.withdraw.prompt(),"")
  play_atm_exit(player) --anim

  v = parseInt(v)

  if v > 0 then
    local user_id = zRP.getUserId(source)
    if user_id then
      if zRP.tryWithdraw(user_id,v) then
        zRPclient._notify(source,lang.atm.withdraw.withdrawn({v}))
      else
        zRPclient._notify(source,lang.atm.withdraw.not_enough())
      end
    end
  else
    zRPclient._notify(source,lang.common.invalid_value())
  end
end

local atm_menu = {
  name=lang.atm.title(),
  css={top = "75px", header_color="rgba(0,255,125,0.75)"}
}

atm_menu[lang.atm.deposit.title()] = {atm_choice_deposit,lang.atm.deposit.description()}
atm_menu[lang.atm.withdraw.title()] = {atm_choice_withdraw,lang.atm.withdraw.description()}

local function atm_enter(source)
  local user_id = zRP.getUserId(source)
  if user_id then
    atm_menu[lang.atm.info.title()] = {function()end,lang.atm.info.bank({zRP.getBankMoney(user_id)})}
    zRP.openMenu(source,atm_menu)
  end
end

local function atm_leave(source)
  zRP.closeMenu(source)
end

local function build_client_atms(source)
  local user_id = zRP.getUserId(source)
  if user_id then
    for k,v in pairs(atms) do
      local x,y,z = table.unpack(v)

      zRPclient._addBlip(source,x,y,z,108,4,lang.atm.title())
      zRPclient._addMarker(source,x,y,z-1,0.7,0.7,0.5,0,255,125,125,150)

      zRP.setArea(source,"zRP:atm"..k,x,y,z,1,1.5,atm_enter,atm_leave)
    end
  end
end

AddEventHandler("zRP:playerSpawn",function(user_id,source,first_spawn)
  if first_spawn then
    build_client_atms(source)
  end
end)
