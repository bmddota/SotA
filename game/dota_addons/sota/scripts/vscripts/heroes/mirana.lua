local HEROMODULE = {}

function HEROMODULE:InitializeClass(hero)
  require('heroes/default'):InitializeClass(hero)

  hero.weaponSet = {{knife=require('weapons/knife'):InitializeWeapon(hero)},
               {xbow=require('weapons/xbow'):InitializeWeapon(hero)},
           {sacred_arrow=require('weapons/sacred_arrow'):InitializeWeapon(hero)}}

  hero.activeWeapons = {hero.weaponSet[1]["knife"],
              hero.weaponSet[2]["xbow"],
              hero.weaponSet[3]["sacred_arrow"]}

  hero.weapon = hero.activeWeapons[3]
  hero.activeWeaponSlot = 3

  hero.baseMoveSpeed = 600
  hero.speed = 600
  hero.jumps = 2
  hero.maxJumps = 2
  hero.jumpSpeed = 550
  hero.height = 190

  local MOVE_SKILL_SPEED = 1800
  local MOVE_SKILL_COST = 85

  hero.moveSkillCooldown = 3.0

  hero.baseCameraDistance = 325

  function hero:OnMovementSkillKeyDown()
    --print('[HeroClass-Default] OnMovementSkillKeyDown')
    local gametime = GameRules:GetGameTime()

    if not hero:IsAlive() or hero.lastShift + hero.moveSkillCooldown > gametime or hero:GetMana() < MOVE_SKILL_COST then
      return
    end

    hero:SpendMana(MOVE_SKILL_COST, hero)
    hero.lastShift = gametime
    
    hero:AddPhysicsVelocity(hero:GetForwardVector() * MOVE_SKILL_SPEED * 2/3 + Vector(0,0,MOVE_SKILL_SPEED * 1/3))
    local particle = ParticleManager:CreateParticle("particles/test_particle/force_staff.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
    hero:EmitSound('SOTA.Leap')

    Timers:CreateTimer(.6, function()
      ParticleManager:DestroyParticle(particle, false)
    end)
  end
end

return HEROMODULE