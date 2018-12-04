
-- mission system module
local lang = zRP.lang
local cfg = module("cfg/Modules/mission")

-- start a mission for a player
--- mission_data: 
---- name: Mission name
---- steps: ordered list of
----- text
----- position: {x,y,z}
----- onenter(player,area)
----- onleave(player,area) (optional)
----- blipid, blipcolor (optional)
function zRP.startMission(player, mission_data)
  local user_id = zRP.getUserId(player)
  if user_id then
    local tmpdata = zRP.getUserTmpTable(user_id)
    
    zRP.stopMission(player)
    if #mission_data.steps > 0 then
      tmpdata.mission_step = 0
      tmpdata.mission_data = mission_data
      zRPclient._setDiv(player,"mission",cfg.display_css,"")
      zRP.nextMissionStep(player) -- do first step
    end
  end
end

-- end the current player mission step
function zRP.nextMissionStep(player)
  local user_id = zRP.getUserId(player)
  if user_id then
    local tmpdata = zRP.getUserTmpTable(user_id)
    if tmpdata.mission_step then -- if in a mission
      -- increase step
      tmpdata.mission_step = tmpdata.mission_step+1
      if tmpdata.mission_step > #tmpdata.mission_data.steps then -- check mission end
        zRP.stopMission(player)
      else -- mission step
        local step = tmpdata.mission_data.steps[tmpdata.mission_step]
        local x,y,z = table.unpack(step.position)
        local blipid = 1
        local blipcolor = 5
        local onleave = function(player, area) end
        if step.blipid then blipid = step.blipid end
        if step.blipcolor then blipcolor = step.blipcolor end
        if step.onleave then onleave = step.onleave end

        -- display
        zRPclient._setDivContent(player,"mission",lang.mission.display({tmpdata.mission_data.name,tmpdata.mission_step-1,#tmpdata.mission_data.steps,step.text}))

        -- blip/route
        local id = zRPclient._setNamedBlip(player, "zRP:mission", x,y,z, blipid, blipcolor, lang.mission.blip({tmpdata.mission_data.name,tmpdata.mission_step,#tmpdata.mission_data.steps}))
        zRPclient._setBlipRoute(player,id)

        -- map trigger
        zRPclient._setNamedMarker(player,"zRP:mission", x,y,z-1,0.7,0.7,0.5,255,226,0,125,150)
        zRP.setArea(player,"zRP:mission",x,y,z,1,1.5,step.onenter,step.onleave)
      end
    end
  end
end

-- stop the player mission
function zRP.stopMission(player)
  local user_id = zRP.getUserId(player)
  if user_id then
    local tmpdata = zRP.getUserTmpTable(user_id)
    tmpdata.mission_step = nil
    tmpdata.mission_data = nil

    zRPclient._removeNamedBlip(player,"zRP:mission")
    zRPclient._removeNamedMarker(player,"zRP:mission")
    zRPclient._removeDiv(player,"mission")
    zRP.removeArea(player,"zRP:mission")
  end
end

-- check if the player has a mission
function zRP.hasMission(player)
  local user_id = zRP.getUserId(player)
  if user_id then
    local tmpdata = zRP.getUserTmpTable(user_id)
    if tmpdata.mission_step then
      return true
    end
  end

  return false
end

function zRPMenu.mission_services(player, choice)
  local user_id = zRP.getUserId(player)
  local service = lang.service.group()
  if user_id ~= nil then
    if zRP.hasGroup(user_id,service) then
      zRP.removeUserGroup(user_id,service)
      if zRP.hasMission(player) then
        zRP.stopMission(player)
      end
      zRPclient.notify(player,lang.basic_menu.service.off())
    else
      zRP.addUserGroup(user_id,service)
      zRPclient.notify(player,lang.basic_menu.service.on())
    end
  end
end