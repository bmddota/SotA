require('controloverride')
require('cameramanager')

if hero == nil then
  hero = PlayerResource:GetPlayer(0):GetAssignedHero()
  Physics:Unit(hero)
  --offset = 200
end

--CameraManager:SendConfigToAll(true, 1 / 4)
--hero:SetGroundBehavior(PHYSICS_GROUND_LOCK)

if lr == nil then
  lr = 0
  ud = 0
  ControlOverride:SendConfigToAll(false, true, false, true)
end

hero:Stop()
hero:SetPhysicsFriction(0)
hero:SetGroundBehavior(PHYSICS_GROUND_LOCK)
hero:Hibernate(false)
hero:FollowNavMesh(true)
hero:SetAutoUnstuck(false)
hero:SetPhysicsAcceleration(Vector(0,0,-300))

forwardoffset = 200

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

ControlOverride:MouseUpHandler(function(player, leftClick)
  if not leftClick then
    return
  end

  print('left click')
  local ability = hero:GetItemInSlot(0)

  print(ability:GetAbilityName())

  local info = {
    EffectName = "particles/test_particle/ranged_tower_good.vpcf",
    Ability = ability,
    vSpawnOrigin = hero:GetAbsOrigin() + Vector(0,0,80),
    fDistance = 1500,
    fStartRadius = 150,
    fEndRadius = 150,
    Source = hero,
    bHasFrontalCone = false,
    iMoveSpeed = 1800,
    bReplaceExisting = false,
    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
    iUnitTargetType = DOTA_UNIT_TARGET_ALL,
    fExpireTime = GameRules:GetGameTime() + 8.0,
  }
  
  --print ('0-------------0')
  --PrintTable(info)
  --print ('0--------------0')
  local speed = 1800
  
  info.vVelocity = hero:GetForwardVector() * speed
  ProjectileManager:CreateLinearProjectile( info )

  if ud == 0 and lr == 0 then
    print('animation')
    hero:RemoveModifierByName('modifier_tutorial_forceanimation')
    hero:AddNewModifier(hero, nil, 'modifier_tutorial_forceanimation', {loop=0, activity=ACT_DOTA_ATTACK})
  end
  
end)

ControlOverride:SelectionHandler(function(player, id)
  if id == camera:entindex() then
    ControlOverride:SendConfigToAll(true, true, false, true)
    CameraManager:SendConfigToAll(true)
    CameraManager:CameraRotateHandler(function(ply, yaw, pitch)
      local ang = hero:GetAngles()
      hero:SetAngles(ang.x, yaw, ang.z)

      local forward = hero:GetForwardVector()
      camera:SetAbsOrigin(hero:GetAbsOrigin() + forward * forwardoffset)
    end)

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

    local pid = player:GetPlayerID()
    ControlOverride:SendCvar(pid, "dota_render_crop_height", "0") -- Renders the bottom part of the screen
    ControlOverride:SendCvar(pid, "dota_camera_edgemove", "0")
    ControlOverride:SendCvar(pid, "dota_camera_fov_max", "80")
    ControlOverride:SendCvar(pid, "dota_camera_distance", "650")
    ControlOverride:SendCvar(pid, "dota_camera_lock", "1")
    ControlOverride:SendCvar(pid, "dota_camera_pitch_max", "35")
    ControlOverride:SendCvar(pid, "dota_camera_lock_lerp", ".80")
    ControlOverride:SendCvar(pid, "r_farz", "3500")
    camera:FindAbilityByName("reflex_dummy_unit"):SetLevel(1)
    camera:SetModel('models/development/invisiblebox.vmdl')
    camera:SetOriginalModel('models/development/invisiblebox.vmdl');
    hero:Stop()



    hero:OnPhysicsFrame(function()
      local forward = hero:GetForwardVector()
      camera:SetAbsOrigin(hero:GetAbsOrigin() + forward * forwardoffset)

      local dir = Vector(0,0,0)
      local rot = nil
      if ud == 1 then
        rot = 0
        if lr == 1 then
          rot = -45
        elseif lr == -1 then
          rot = 45
        end
      elseif ud == -1 then
        rot = 180
        if lr == 1 then
          rot = rot + 45
        elseif lr == -1 then
          rot = rot - 45
        end
      elseif ud == 0 then
        if lr == 1 then
          rot = -90
        elseif lr == -1 then
          rot = 90
        end
      end

      if rot ~= nil then
        hero:AddNewModifier(hero, nil, 'modifier_tutorial_forceanimation', {loop=1, activity=ACT_DOTA_RUN})
        dir = RotatePosition(Vector(0,0,0), QAngle(0,rot,0), forward)
      else
        hero:RemoveModifierByName('modifier_tutorial_forceanimation')
      end

      hero:SetPhysicsVelocity(400 * dir + Vector(0,0,hero:GetPhysicsVelocity().z))
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