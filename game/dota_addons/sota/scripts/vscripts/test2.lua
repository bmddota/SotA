require('controloverride')
require('cameramanager')

if hero == nil then
  hero = PlayerResource:GetPlayer(0):GetAssignedHero()
  Physics:Unit(hero)
  --offset = 200
end

if lr == nil then
  lr = 0
  ud = 0
  curyaw = 90
  camerapitch = 0
  targetyaw = 90
  ControlOverride:SendConfigToAll(false, true, false, true)
end

hero:Stop()
hero:SetPhysicsFriction(0)
hero:SetGroundBehavior(PHYSICS_GROUND_NOTHING)
hero:Hibernate(false)
hero:FollowNavMesh(false)
hero:SetAutoUnstuck(false)

forwardoffset = 500

--hero:Hibernate(false)
--hero:AddPhysicsVelocity(Vector(100,0,0))
--hero:OnPhysicsFrame(function()  hero:SetAbsOrigin(GetGroundPosition(hero:GetAbsOrigin(), hero) + Vector(0,0,offset)) end)


KEY_W = 87
KEY_S = 83
KEY_A = 65
KEY_D = 68

ControlOverride:KeyDownHandler(function(player, keycode, ctrl, shift, alt)
  if keycode == KEY_W then
    ud = 1
  elseif keycode == KEY_S then
    ud = -1
  elseif keycode == KEY_A then
    lr = -1
  elseif keycode == KEY_D then
    lr = 1
  end
end)

ControlOverride:KeyUpHandler(function(player, keycode, ctrl, shift, alt)
  if keycode == KEY_W then
    ud = 0
  elseif keycode == KEY_S then
    ud = 0
  elseif keycode == KEY_A then
    lr = 0
  elseif keycode == KEY_D then
    lr = 0
  end
end)

ControlOverride:SelectionHandler(function(player, id)
  if id == camera:entindex() then
    ControlOverride:SendConfigToAll(true, true, false, true)

    local mode = GameRules:GetGameModeEntity()
    mode:SetHUDVisible(0,  false) --Clock
    mode:SetHUDVisible(1,  false)
    mode:SetHUDVisible(2,  false)
    mode:SetHUDVisible(6,  false)
    mode:SetHUDVisible(7,  false) 
    mode:SetHUDVisible(8,  false) 
    mode:SetHUDVisible(9,  false)
    mode:SetHUDVisible(11, false)
    mode:SetHUDVisible(12, false)

    mode:SetHUDVisible(3,  false) --Action Panel
    mode:SetHUDVisible(4,  false) --Minimap
    mode:SetHUDVisible(5,  false) --Inventory

    Convars:SetInt("dota_render_crop_height", 0) -- Renders the bottom part of the screen
    Convars:SetInt("dota_camera_edgemove", 0)
    Convars:SetInt("dota_camera_fov_max", 80)
    Convars:SetInt("dota_camera_distance", 1200)
    Convars:SetInt("dota_camera_lock", 1)
    Convars:SetFloat("dota_camera_pitch_max", 35)
    Convars:SetFloat("dota_camera_lock_lerp", .80)
    Convars:SetInt("r_farz", 3500)
    camera:FindAbilityByName("reflex_dummy_unit"):SetLevel(1)
    camera:SetModel('models/development/invisiblebox.vmdl')
    camera:SetOriginalModel('models/development/invisiblebox.vmdl');
    hero:Stop()

    hero:OnPhysicsFrame(function()

      if ud ~= 0 then
        camerapitch = camerapitch + -.5 * ud
      end

      local angs = hero:GetAngles()
      angs.x = camerapitch
      hero:SetAngles(angs.x, angs.y, 0)

      local roll = 0

      if lr ~= 0 then
        roll = lr * 15
        hero:SetAngles(angs.x, angs.y, roll)
        hero:SetForwardVector(RotatePosition(Vector(0,0,0), QAngle(0, -4 * lr, 0), hero:GetForwardVector()))
      end
      local forward = RotatePosition(Vector(0,0,0), QAngle(camerapitch,0,0), hero:GetForwardVector())
      hero:SetPhysicsVelocity(forward * 1000)
      camera:SetAbsOrigin(hero:GetAbsOrigin() + forward * forwardoffset)
    end)

    if timername ~= nil then
      Timers:RemoveTimer(timername)
    end

    timername = Timers:CreateTimer(function()
      local angles = hero:GetAngles()

      targetyaw = angles.y
      --print(angles)

      local diff = targetyaw - curyaw
      if diff > 180 then
        print(diff)
        diff = diff - 360
        print(diff)
      elseif diff < -180 then
        print(diff)
        diff = diff + 360
        print(diff)
      end

      --print (diff)

      if math.abs(diff) < .5 then
        Convars:SetFloat("dota_camera_yaw", angles.y)
        curyaw = angles.y
      else
        local frameshift = diff / 30
        if math.abs(frameshift) < .5 then
          frameshift = .5 * math.abs(diff) / diff
        end
        curyaw = curyaw + frameshift
        Convars:SetFloat("dota_camera_yaw", curyaw)
      end

      --Convars:SetFloat("dota_camera_pitch_max", 15 + camerapitch)
      --Convars:SetFloat("dota_camera_yaw", angles.y)
      
      return .03
      --hero:SetAbsOrigin(GetGroundPosition(hero:GetAbsOrigin(), hero) + Vector(0,0,offset))
    end)
  end
end)

--GameRules:GetGameModeEntity():SetOverrideSelectionEntity(dummy)
--dummy:SetOwner(hero)
--dummy:SetControllableByPlayer(0, true)

if camera then
  return
end

--[[if true then
  boxcollider4 = Physics:AddCollider("aabox2", Physics:ColliderFromProfile("aaboxreflect"))
  boxcollider4.box = {Vector(-400,-800,0), Vector(-200,-200,500)}
  boxcollider4.draw = true
  boxcollider4.test = function(self, unit)
    return IsPhysicsUnit(unit)
  end
  return
end]]

    camera = CreateUnitByName('npc_dummy_unit', hero:GetAbsOrigin() + hero:GetForwardVector() * 500, true, hero, hero, hero:GetTeamNumber())
    camera:FindAbilityByName("reflex_dummy_unit"):SetLevel(0)
    camera:SetModel('models/heroes/enigma/enigma.vmdl')
    camera:SetOriginalModel('models/heroes/enigma/enigma.vmdl');
    camera:SetOwner(hero)
    camera:SetControllableByPlayer(0, true)
    Physics:Unit(camera)