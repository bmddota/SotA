local HEROMODULE = {}

function HEROMODULE:InitializeClass(hero)
  require('heroes/default'):InitializeClass(hero)

  hero.weaponSet = {{knife=require('weapons/knife'):InitializeWeapon(hero)},
               {pistol=require('weapons/pistol'):InitializeWeapon(hero)},
           {sword=require('weapons/sword'):InitializeWeapon(hero)}}

  hero.activeWeapons = {hero.weaponSet[1]["knife"],
              hero.weaponSet[2]["pistol"],
              hero.weaponSet[3]["sword"]}

  hero.weapon = hero.activeWeapons[3]
  hero.activeWeaponSlot = 3

  hero.baseMoveSpeed = 750
  hero.speed = 750
  hero.jumps = 3
  hero.maxJumps = 3
  hero.jumpSpeed = 490
  hero.height = 190

  local MOVE_SKILL_SPEED = 1200
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
    skillParticle = ParticleManager:CreateParticle("particles/test_particle/jugg_walk.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
    ParticleManager:SetParticleControl(skillParticle, 1, hero.renderColor[hero:GetTeam()])
    
    hero.speed = MOVE_SKILL_SPEED
    hero:EmitSound('Item.Maelstrom.Chain_Lightning')

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

    hero.dodgeProjectiles = false
    hero.speed = hero.baseMoveSpeed
    usingSkill = false
  end
end

return HEROMODULE