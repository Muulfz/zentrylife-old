
--TODO trocar para Character
-- module describing business system (company, money laundering)

local cfg = module("cfg/Modules/business")
local htmlEntities = module("lib/htmlEntities")
local lang = zRP.lang

local sanitizes = module("cfg/Modules/sanitizes")
-- api

-- return user business data or nil
function zRP.getUserBusiness(user_id, cbr)
  if user_id then
    local rows = zRP.query("zRP/get_business", {user_id = user_id})
    local business = rows[1]

    -- when a business is fetched from the database, check for update of the laundered capital transfer capacity
    if business and os.time() >= business.reset_timestamp+cfg.transfer_reset_interval*60 then
      zRP.execute("zRP/reset_transfer", {user_id = user_id, time = os.time()})
      business.laundered = 0
    end

    return business
  end
end

-- close the business of an user
function zRP.closeBusiness(user_id)
  zRP.execute("zRP/delete_business", {user_id = user_id})
end

-- business interaction

-- page start at 0
local function open_business_directory(player,page) -- open business directory with pagination system
  if page < 0 then page = 0 end

  local menu = {name=lang.business.directory.title().." ("..page..")",css={top="75px",header_color="rgba(240,203,88,0.75)"}}

  local rows = zRP.query("zRP/get_business_page", {b = page*10, n = 10})
  local count = 0
  for k,v in pairs(rows) do
    count = count+1
    local row = v

    if row.user_id ~= nil then
      -- get owner identity
      local identity = zRP.getUserIdentity(row.user_id)
      if identity then
        menu[htmlEntities.encode(row.name)] = {function()end, lang.business.directory.info({row.capital,htmlEntities.encode(identity.name),htmlEntities.encode(identity.firstname),identity.registration,identity.phone})}
      end

      -- check end, open menu
      count = count-1
      if count == 0 then
        menu[lang.business.directory.dnext()] = {function() open_business_directory(player,page+1) end}
        menu[lang.business.directory.dprev()] = {function() open_business_directory(player,page-1) end}

        zRP.openMenu(player,menu)
      end
    end
  end
end

local function business_enter(source)
  local source = source

  local user_id = zRP.getUserId(source)
  if user_id then
    -- build business menu
    local menu = {name=lang.business.title(),css={top="75px",header_color="rgba(240,203,88,0.75)"}}

    local business = zRP.getUserBusiness(user_id)
    if business then -- have a business
      -- business info
      menu[lang.business.info.title()] = {function(player,choice)
      end, lang.business.info.info({htmlEntities.encode(business.name), business.capital, business.laundered})}

      -- add capital
      menu[lang.business.addcapital.title()] = {function(player,choice)
        local amount = zRP.prompt(player,lang.business.addcapital.prompt(),"")
        amount = parseInt(amount)
        if amount > 0 then
          if zRP.tryPayment(user_id,amount) then
            zRP.execute("zRP/add_capital", {user_id = user_id, capital = amount})
            zRPclient._notify(player,lang.business.addcapital.added({amount}))
          else
            zRPclient._notify(player,lang.money.not_enough())
          end
        else
          zRPclient._notify(player,lang.common.invalid_value())
        end
      end,lang.business.addcapital.description()}

      -- money laundered
      menu[lang.business.launder.title()] = {function(player,choice)
        local business = zRP.getUserBusiness(user_id) -- update business data
        local launder_left = math.min(business.capital-business.laundered,zRP.getInventoryItemAmount(user_id,"dirty_money")) -- compute launder capacity
        local amount = zRP.prompt(player,lang.business.launder.prompt({launder_left}),""..launder_left)
        amount = parseInt(amount)
        if amount > 0 and amount <= launder_left then
          if zRP.tryGetInventoryItem(user_id,"dirty_money",amount,false) then
            -- add laundered amount
            zRP.execute("zRP/add_laundered", {user_id = user_id, laundered = amount})
            -- give laundered money
            zRP.giveMoney(user_id,amount)
            zRPclient._notify(player,lang.business.launder.laundered({amount}))
          else
            zRPclient._notify(player,lang.business.launder.not_enough())
          end
        else
          zRPclient._notify(player,lang.common.invalid_value())
        end
      end,lang.business.launder.description()}
    else -- doesn't have a business
      menu[lang.business.open.title()] = {function(player,choice)
        local name = zRP.prompt(player,lang.business.open.prompt_name({30}),"")
        if string.len(name) >= 2 and string.len(name) <= 30 then
          name = sanitizeString(name, sanitizes.business_name[1], sanitizes.business_name[2])
          local capital = zRP.prompt(player,lang.business.open.prompt_capital({cfg.minimum_capital}),""..cfg.minimum_capital)
          capital = parseInt(capital)
          if capital >= cfg.minimum_capital then
            if zRP.tryPayment(user_id,capital) then
              zRP.execute("zRP/create_business", {
                user_id = user_id,
                name = name,
                capital = capital,
                time = os.time()
              })

              zRPclient._notify(player,lang.business.open.created())
              zRP.closeMenu(player) -- close the menu to force update business info
            else
              zRPclient._notify(player,lang.money.not_enough())
            end
          else
            zRPclient._notify(player,lang.common.invalid_value())
          end
        else
          zRPclient._notify(player,lang.common.invalid_name())
        end
      end,lang.business.open.description({cfg.minimum_capital})}
    end

    -- business list
    menu[lang.business.directory.title()] = {function(player,choice)
      open_business_directory(player,0)
    end,lang.business.directory.description()}

    -- open menu
    zRP.openMenu(source,menu)
  end
end

local function business_leave(source)
  zRP.closeMenu(source)
end

local function build_client_business(source) -- build the city hall area/marker/blip
  local user_id = zRP.getUserId(source)
  if user_id then
    for k,v in pairs(cfg.commerce_chambers) do
      local x,y,z = table.unpack(v)

      zRPclient._addBlip(source,x,y,z,cfg.blip[1],cfg.blip[2],lang.business.title())
      zRPclient._addMarker(source,x,y,z-1,0.7,0.7,0.5,0,255,125,125,150)

      zRP.setArea(source,"zRP:business"..k,x,y,z,1,1.5,business_enter,business_leave)
    end
  end
end


AddEventHandler("zRP:playerSpawn",function(user_id, source, first_spawn)
  -- first spawn, build business
  if first_spawn then
    build_client_business(source)
  end
end)


