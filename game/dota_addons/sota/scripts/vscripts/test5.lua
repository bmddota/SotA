package.loaded['projectiles'] = nil
require('projectiles')
package.loaded['physics'] = nil
require('physics')
package.loaded['heroes/default'] = nil
--PHYSICS_THINK = .5
local hero = PlayerResource:GetPlayer(0):GetAssignedHero()

local damageTable = {
            victim = hero,
            attacker = hero,
            damage = RandomInt(50, 70),
            damage_type = DAMAGE_TYPE_PURE,
          }

          --ApplyDamage(damageTable)

GROUND_FRICTION = .09
hero:Stop()

--ApplyModifier(hero,hero, 'mana_regen_reduced', {})
--hero:RemoveModifierByName('mana_regen_reduced')

package.loaded['weapons/raze'] = nil
hero.weapon = require('weapons/raze'):InitializeWeapon(hero)

if timer2 then
  Timers:RemoveTimer(timer2)
end
timer2 = Timers:CreateTimer(function() 
  local heroes = HeroList:GetAllHeroes()
  for i=1,#heroes do 
    --DebugDrawBox(heroes[i]:GetAbsOrigin(), Vector(-100,-100,heroes[i].zOffset or 0), Vector(100,100,heroes[i].height or 150), 255,0,0, .1, .03)
  end
  return .03 
end)

if true then
  return
end

for i=0, 9 do
  -- Check if this player is a fake one
  if PlayerResource:IsFakeClient(i) then
    -- Grab player instance
    print(i .. ' fake')
    local ply = PlayerResource:GetPlayer(i)
    -- Make sure we actually found a player instance
    --CreateHeroForPlayer('npc_dota_hero_nevermore', ply)
  end
end

local parent = hero:GetRootMoveParent()
local children = parent:GetChildren()
for i=1,#children do
  local child = children[i]
  if child:GetClassname() == "dota_item_wearable" then
    local color = hero.renderColor[hero:GetTeam()]
    child:SetRenderColor(color.x, color.y, color.z)
  end
end

package.loaded['weapons/SMG'] = nil
hero.weapon = require('weapons/SMG'):InitializeWeapon(hero)

if true then
  return
end
--particle = ParticleManager:CreateParticle("particles/test_particle/jugg_walk.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
--ParticleManager:SetParticleControl(particle, 1, hero.renderColor[DOTA_TEAM_BADGUYS])
--particle = ParticleManager:CreateParticle("particles/test_particle/ghost_model.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
--hero.baseCameraDistance = 500
--hero:SetModelScale(.70)
--hero:SpendMana(50,hero)

package.loaded['weapons/pistol'] = nil
hero.weapon = require('weapons/pistol'):InitializeWeapon(hero)
hero.baseCameraDistance = 600

if true then
  --return
end

Physics:Unit(hero)
hero:Stop()
hero:SetPhysicsFriction(GROUND_FRICTION)
hero:Hibernate(false)
hero:FollowNavMesh(false)
hero:SetNavGroundAngle(SLOPE_ANGLE)
hero:AdaptiveNavGridLookahead(true)
hero:SetAutoUnstuck(false)
hero:SetPhysicsAcceleration(Vector(0,0,-1 * GRAVITY))

hero:CutTrees(false)
hero:SetStuckTimeout(600)
hero:SetVelocityClamp(0)
hero:SetNavCollisionType(PHYSICS_NAV_GROUND)
hero:SetGroundBehavior(PHYSICS_GROUND_ABOVE)
hero:SetBoundOverride(1)

hero:OnPhysicsFrame(function()
        if hero:IsAlive() then
          local pos = hero:GetAbsOrigin()
          local ground = GetGroundPosition(pos, hero)
          if pos.z - ground.z < 2 and Physics:CalcNormal(ground,hero,10).z > hero.fNavGroundAngle then
            if hero.jumps ~= 2 then
              print('more jumps')
            end
            hero.jumps = 2
            hero:SetPhysicsFriction(GROUND_FRICTION)
            if hero.inAir then
              hero:OnLand(false)
            end
            hero.inAir = false
            --hero:FollowNavMesh(true)
          elseif GridNav:IsNearbyTree(pos, 30, true) and ground.z + 340 == pos.z and hero:GetPhysicsVelocity().z == 0 then
            if hero.jumps ~= 2 then
              print('tree top')
              hero.jumps = 2
            end
            hero:SetPhysicsFriction(GROUND_FRICTION)
            if hero.inAir then
              hero:OnLand(true)
            end
            hero.inAir = false
          else
            hero:SetPhysicsFriction(AIR_DRAG)
            if not hero.inAir then
              hero:OnTakeOff()
            end
            hero.inAir = true
          end

          local forward = hero:GetForwardVector()
          hero.camera:SetAbsOrigin(hero:GetAbsOrigin() + forward * FORWARD_OFFSET)

          local dir = Vector(0,0,0)
          local rot = nil
          if hero.up then
            rot = 0
            if hero.right then
              rot = -45
            elseif hero.left then
              rot = 45
            end
          elseif hero.down then
            rot = 180
            if hero.right then
              rot = rot + 45
            elseif hero.left then
              rot = rot - 45
            end
          elseif not hero.up and not hero.down then
            if hero.right then
              rot = -90
            elseif hero.left then
              rot = 90
            end
          end

          if rot ~= nil then
            hero:AddNewModifier(hero, nil, 'modifier_tutorial_forceanimation', {loop=1, activity=ACT_DOTA_RUN})
            dir = RotatePosition(Vector(0,0,0), QAngle(0,rot,0), forward)
          else
            hero:RemoveModifierByName('modifier_tutorial_forceanimation')
          end

          hero:SetStaticVelocity('move', hero.speed * dir)

          hero:OnFrame()
        end
      end)


if true then
  return
end

--local ents = Entities:FindAllInSphere(hero:GetAbsOrigin(), 300)

--[[for i=1,#ents do
  local ent = ents[i]
  if ent:GetClassname() == "dota_base_ability" then
    ent:RemoveSelf()
  end
end]]

-- reticle/screen cetner indicator
-- crash bug?
-- height boxes for testing/refinement (low priority)

--CameraManager:SetProperty(0,CAMERA_DISTANCE,650)
--CameraManager:LerpProperty(0,CAMERA_DISTANCE,650,nil,-200 / 60)
--hero.camera:FindAbilityByName("reflex_dummy_unit"):SetLevel(1)
--hero.camera:SetModel('models/heroes/enigma/enigma.vmdl')
--hero.camera:SetOriginalModel('models/heroes/enigma/enigma.vmdl');

--hero:SetAbsOrigin(GetGroundPosition(hero:GetAbsOrigin(), hero))
--GRAVITY = GRAVITY * 2

if timer3 then
  Timers:RemoveTimer(timer3)
end


timer3 = Timers:CreateTimer(.5, function()
  local pos = hero:GetAbsOrigin()
  local campos = hero.camera:GetAbsOrigin()
  if campos.z > pos.z then
    pos = campos
  end
  --local dist = pos.z - GetGroundPosition(pos, hero).z
  dist = pos.z
  --print(dist)
  local count = 1 * 30
  CameraManager:LerpProperty(0,CAMERA_DISTANCE,850+dist,count, 0)---1*step)

  local max = 14
  count = 0
  local startF = FORWARD_OFFSET
  local endF = 200 + dist/3
  Timers:CreateTimer(function()
    FORWARD_OFFSET = startF + (endF - startF) * count / max

    count = count + 1
    if count == max then
      return
    end
    return .03
  end)
  
  return .5
end)




function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end