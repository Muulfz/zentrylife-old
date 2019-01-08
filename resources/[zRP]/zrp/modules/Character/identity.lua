local htmlEntities = module("lib/htmlEntities")

local cfg = module("cfg/Modules/identity")
local lang = zRP.lang

local sanitizes = module("cfg/Modules/sanitizes")

-- this module describe the identity system
-- api

-- return user identity
function zRP.getUserIdentity(user_id, cbr)
  local rows = zRP.query("zRP/get_user_identity", {user_id = user_id})
  zRP.user_tables[user_id]["identity"] = rows[1]
  return rows[1]
end

-- return user_id by registration or nil
function zRP.getUserByRegistration(registration, cbr)
  local rows = zRP.query("zRP/get_userbyreg", {registration = registration or ""})
  if #rows > 0 then
    return rows[1].user_id
  end
end

-- return user_id by phone or nil
function zRP.getUserByPhone(phone, cbr)
  local rows = zRP.query("zRP/get_userbyphone", {phone = phone or ""})
  if #rows > 0 then
    return rows[1].user_id
  end
end

function zRP.generateStringNumber(format) -- (ex: DDDLLL, D => digit, L => letter)
  local abyte = string.byte("A")
  local zbyte = string.byte("0")

  local number = ""
  for i=1,#format do
    local char = string.sub(format, i,i)
    if char == "D" then number = number..string.char(zbyte+math.random(0,9))
    elseif char == "L" then number = number..string.char(abyte+math.random(0,25))
    else number = number..char end
  end

  return number
end

function zRP.getUserIdentityForTable(user_id)
  return zRP.user_tables[user_id].identity
end


-- return a unique registration number
function zRP.generateRegistrationNumber(cbr)
  local user_id = nil
  local registration = ""
  -- generate registration number
  repeat
    registration = zRP.generateStringNumber("DDDLLL")
    user_id = zRP.getUserByRegistration(registration)
  until not user_id

  return registration
end

-- return a unique phone number (0DDDDD, D => digit)
function zRP.generatePhoneNumber(cbr)
  local user_id = nil
  local phone = ""

  -- generate phone number
  repeat
    phone = zRP.generateStringNumber(cfg.phone_format)
    user_id = zRP.getUserByPhone(phone)
  until not user_id

  return phone
end

-- events, init user identity at connection
AddEventHandler("zRP:playerJoin",function(user_id,source,name,last_login)
  if not zRP.getUserIdentity(user_id) then
    local registration = zRP.generateRegistrationNumber()
    local phone = zRP.generatePhoneNumber()
    zRP.execute("zRP/init_user_identity", {
      user_id = user_id,
      registration = registration,
      phone = phone,
      firstname = cfg.random_first_names[math.random(1,#cfg.random_first_names)],
      name = cfg.random_last_names[math.random(1,#cfg.random_last_names)],
      age = math.random(25,40)
    })
    zRP.getUserIdentity(user_id)
  end
end)

-- city hall menu

local cityhall_menu = {name=lang.cityhall.title(),css={top="75px", header_color="rgba(0,125,255,0.75)"}}

local function ch_identity(player,choice)
  local user_id = zRP.getUserId(player)
  if user_id ~= nil then
    local firstname = zRP.prompt(player,lang.cityhall.identity.prompt_firstname(),"")
    if string.len(firstname) >= 2 and string.len(firstname) < 50 then
      firstname = sanitizeString(firstname, sanitizes.name[1], sanitizes.name[2])
      local name = zRP.prompt(player,lang.cityhall.identity.prompt_name(),"")
      if string.len(name) >= 2 and string.len(name) < 50 then
        name = sanitizeString(name, sanitizes.name[1], sanitizes.name[2])
        local age = zRP.prompt(player,lang.cityhall.identity.prompt_age(),"")
        age = parseInt(age)
        if age >= 16 and age <= 150 then
          if zRP.tryPayment(user_id,cfg.new_identity_cost) then
            local registration = zRP.generateRegistrationNumber()
            local phone = zRP.generatePhoneNumber()

            zRP.execute("zRP/update_user_identity", {
              user_id = user_id,
              firstname = firstname,
              name = name,
              age = age,
              registration = registration,
              phone = phone
            })

            -- update client registration
            zRPclient._setRegistrationNumber(player,registration)
            zRPclient._notify(player,lang.money.paid({cfg.new_identity_cost}))
          else
            zRPclient._notify(player,lang.money.not_enough())
          end
        else
          zRPclient._notify(player,lang.common.invalid_value())
        end
      else
        zRPclient._notify(player,lang.common.invalid_value())
      end
    else
      zRPclient._notify(player,lang.common.invalid_value())
    end
  end
end

cityhall_menu[lang.cityhall.identity.title()] = {ch_identity,lang.cityhall.identity.description({cfg.new_identity_cost})}

local function cityhall_enter(source)
  local user_id = zRP.getUserId(source)
  if user_id ~= nil then
    zRP.openMenu(source,cityhall_menu)
  end
end

local function cityhall_leave(source)
  zRP.closeMenu(source)
end

local function build_client_cityhall(source) -- build the city hall area/marker/blip
  local user_id = zRP.getUserId(source)
  if user_id ~= nil then
    local x,y,z = table.unpack(cfg.city_hall)

    zRPclient._addBlip(source,x,y,z,cfg.blip[1],cfg.blip[2],lang.cityhall.title())
    zRPclient._addMarker(source,x,y,z-1,0.7,0.7,0.5,0,255,125,125,150)

    zRP.setArea(source,"zRP:cityhall",x,y,z,1,1.5,cityhall_enter,cityhall_leave)
  end
end

AddEventHandler("zRP:playerSpawn",function(user_id, source, first_spawn)
  -- send registration number to client at spawn
  local identity = zRP.getUserIdentity(user_id)
  if identity then
    zRPclient._setRegistrationNumber(source,identity.registration or "000AAA")
  end

  -- first spawn, build city hall
  if first_spawn then
    build_client_cityhall(source)
  end
end)

-- player identity menu

