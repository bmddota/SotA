local HEROMODULE = {}

function HEROMODULE:InitializeClass(hero)
  require('heroes/default'):InitializeClass(hero)

  hero.weaponSet = {{knife=require('weapons/knife'):InitializeWeapon(hero)},
               {xbow=require('weapons/xbow'):InitializeWeapon(hero)},
           {power_shot=require('weapons/power_shot'):InitializeWeapon(hero)}}

  hero.activeWeapons = {hero.weaponSet[1]["knife"],
              hero.weaponSet[2]["xbow"],
              hero.weaponSet[3]["power_shot"]}

  hero.weapon = hero.activeWeapons[3]
  hero.activeWeaponSlot = 3

  hero.baseMoveSpeed = 700
  hero.speed = 700
  hero.jumps = 3
  hero.maxJumps = 3
  hero.jumpSpeed = 525
  hero.height = 190

  local MOVE_SKILL_SPEED = 1000
  local MOVE_SKILL_COST = 10
  local usingSkill = false
  local skillParticle = nil

  hero.moveSkillCooldown = 1.0

  function hero:OnMovementSkillKeyDown()
    --print('[HeroClass-Default] OnMovementSkillKeyDown')
    local gametime = GameRules:GetGameTime()

    if not hero:IsAlive() or hero.lastShift + hero.moveSkillCooldown > gametime or hero:GetMana() < MOVE_SKILL_COST then
      return
    end

    hero:SpendMana(MOVE_SKILL_COST, hero)
    hero.lastShift = gametime
    hero.dodgeProjectiles = true
    usingSkill = true

    hero:SetPhysicsAcceleration(Vector(0,0,0))
    local vel = hero:GetPhysicsVelocity()
    vel.z = 0
    hero:SetPhysicsVelocity(vel)

    skillParticle = ParticleManager:CreateParticle("particles/test_particle/jugg_walk.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
    ParticleManager:SetParticleControl(skillParticle, 1, hero.renderColor[hero:GetTeam()])
    
    hero.speed = MOVE_SKILL_SPEED
    hero:EmitSound('Ability.Windrun')

    hero.skillTimer = Timers:CreateTimer(.1, function()
      if not hero:IsAlive() or hero:GetMana() < MOVE_SKILL_COST then
        hero:OnMovementSkillKeyUp()
        return
      end

      hero:SpendMana(MOVE_SKILL_COST, hero)
      return .1
    end)
  end

  function hero:OnMovementSkillKeyUp()
    if not usingSkill then
      return
    end

    if hero.skillTimer then
      Timers:RemoveTimer(hero.skillTimer)
      hero.skillTimer = nil
    end

    if skillParticle then
      ParticleManager:DestroyParticle(skillParticle, false)
      skillParticle = nil
    end
    --print('[HeroClass-Default] OnMovementSkillKeyUp')
    local gametime = GameRules:GetGameTime()
    hero.lastShift = gametime

    hero:StopSound('Ability.Windrun')

    hero:SetPhysicsAcceleration(Vector(0,0,-1 * GRAVITY))
    hero.dodgeProjectiles = false
    hero.speed = hero.baseMoveSpeed
    usingSkill = false
  end

  function hero:OnJump()
    if not usingSkill then
      return
    end

    hero:OnMovementSkillKeyUp()
  end
end

return HEROMODULE