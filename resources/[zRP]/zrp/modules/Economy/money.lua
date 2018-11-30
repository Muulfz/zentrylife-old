local lang = zRP.lang

-- Money module, wallet/bank API
-- The money is managed with direct SQL requests to prevent most potential value corruptions
-- the wallet empty itself when respawning (after death)

-- load config
local cfg = module("cfg/Modules/money")

-- API

-- get money
-- cbreturn nil if error
function zRP.getMoney(user_id)
  local tmp = zRP.getUserTmpTable(user_id)
  if tmp then
    return tmp.wallet or 0
  else
    return 0
  end
end

-- set money
function zRP.setMoney(user_id,value)
  local tmp = zRP.getUserTmpTable(user_id)
  if tmp then
    tmp.wallet = value
  end

  -- update client display
  local source = zRP.getUserSource(user_id)
  if source then
    zRPclient._setDivContent(source,"money",lang.money.display({value}))
  end
end

-- try a payment
-- return true or false (debited if true)
function zRP.tryPayment(user_id,amount)
  local money = zRP.getMoney(user_id)
  if amount >= 0 and money >= amount then
    zRP.setMoney(user_id,money-amount)
    return true
  else
    return false
  end
end

-- give money
function zRP.giveMoney(user_id,amount)
  if amount > 0 then
    local money = zRP.getMoney(user_id)
    zRP.setMoney(user_id,money+amount)
  end
end

-- get bank money
function zRP.getBankMoney(user_id)
  local tmp = zRP.getUserTmpTable(user_id)
  if tmp then
    return tmp.bank or 0
  else
    return 0
  end
end

-- set bank money
function zRP.setBankMoney(user_id,value)
  local tmp = zRP.getUserTmpTable(user_id)
  if tmp then
    tmp.bank = value
  end
end

-- give bank money
function zRP.giveBankMoney(user_id,amount)
  if amount > 0 then
    local money = zRP.getBankMoney(user_id)
    zRP.setBankMoney(user_id,money+amount)
  end
end

-- try a withdraw
-- return true or false (withdrawn if true)
function zRP.tryWithdraw(user_id,amount)
  local money = zRP.getBankMoney(user_id)
  if amount >= 0 and money >= amount then
    zRP.setBankMoney(user_id,money-amount)
    zRP.giveMoney(user_id,amount)
    return true
  else
    return false
  end
end

-- try a deposit
-- return true or false (deposited if true)
function zRP.tryDeposit(user_id,amount)
  if amount >= 0 and zRP.tryPayment(user_id,amount) then
    zRP.giveBankMoney(user_id,amount)
    return true
  else
    return false
  end
end

-- try full payment (wallet + bank to complete payment)
-- return true or false (debited if true)
function zRP.tryFullPayment(user_id,amount)
  local money = zRP.getMoney(user_id)
  if money >= amount then -- enough, simple payment
    return zRP.tryPayment(user_id, amount)
  else  -- not enough, withdraw -> payment
    if zRP.tryWithdraw(user_id, amount-money) then -- withdraw to complete amount
      return zRP.tryPayment(user_id, amount)
    end
  end

  return false
end

-- events, init user account if doesn't exist at connection
AddEventHandler("zRP:playerJoin",function(user_id,source,name,last_login)
  zRP.execute("zRP/money_init_user", {user_id = user_id, wallet = cfg.open_wallet, bank = cfg.open_bank})
  -- load money (wallet,bank)
  local tmp = zRP.getUserTmpTable(user_id)
  if tmp then
    local rows = zRP.query("zRP/get_money", {user_id = user_id})
    if #rows > 0 then
      tmp.bank = rows[1].bank
      tmp.wallet = rows[1].wallet
    end
  end
end)

-- save money on leave
AddEventHandler("zRP:playerLeave",function(user_id,source)
  -- (wallet,bank)
  local tmp = zRP.getUserTmpTable(user_id)
  if tmp and tmp.wallet and tmp.bank then
    zRP.execute("zRP/set_money", {user_id = user_id, wallet = tmp.wallet, bank = tmp.bank})
  end
end)

-- save money (at same time that save datatables)
AddEventHandler("zRP:save", function()
  for k,v in pairs(zRP.user_tmp_tables) do
    if v.wallet and v.bank then
      zRP.execute("zRP/set_money", {user_id = k, wallet = v.wallet, bank = v.bank})
    end
  end
end)

-- money hud
AddEventHandler("zRP:playerSpawn",function(user_id, source, first_spawn)
  if first_spawn then
    -- add money display
    zRPclient._setDiv(source,"money",cfg.display_css,lang.money.display({zRP.getMoney(user_id)}))
  end
end)

local function ch_give(player,choice)
  -- get nearest player
  local user_id = zRP.getUserId(player)
  if user_id then
    local nplayer = zRPclient.getNearestPlayer(player,10)
    if nplayer then
      local nuser_id = zRP.getUserId(nplayer)
      if nuser_id then
        -- prompt number
        local amount = zRP.prompt(player,lang.money.give.prompt(),"")
        local amount = parseInt(amount)
        if amount > 0 and zRP.tryPayment(user_id,amount) then
          zRP.giveMoney(nuser_id,amount)
          zRPclient._notify(player,lang.money.given({amount}))
          zRPclient._notify(nplayer,lang.money.received({amount}))
        else
          zRPclient._notify(player,lang.money.not_enough())
        end
      else
        zRPclient._notify(player,lang.common.no_player_near())
      end
    else
      zRPclient._notify(player,lang.common.no_player_near())
    end
  end
end

-- add player give money to main menu
zRP.registerMenuBuilder("main", function(add, data)
  local user_id = zRP.getUserId(data.player)
  if user_id then
    local choices = {}
    choices[lang.money.give.title()] = {ch_give, lang.money.give.description()}

    add(choices)
  end
end)
