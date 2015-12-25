local HERODEFAULT = {}

function HERODEFAULT:InitializeClass(hero)
  hero.lastShift = GameRules:GetGameTime()
  hero.lastShot = GameRules:GetGameTime()

  local MOVE_SKILL_SPEED = 1600
  local MOVE_SKILL_COST = 75

  hero.baseMoveSpeed = 525
  hero.speed = 525
  hero.speedModifier = 1
  hero.baseCameraDistance = 325 --525
  hero.moveSkillCooldown = 1.8
  hero.jumps = 2
  hero.maxJumps = 2
  hero.jumpSpeed = 550
  hero.healthPickupAmount = 50
  hero.aimPitchOffset = 28
  hero.baseAimPitchOffset = 28
  hero.reticleOffset = Vector(0,0,0)
  hero.reticleDistance = 6000
  hero.height = 150
  hero.shotOffset = Vector(0,0,120)
  hero.zOffset = 0
  hero.projectileHitSound = "SOTA.HitSound"

  hero.fixPosition = nil
  hero.dodgeProjectiles = false

  hero.groundFrictionOverride = nil
  hero.airDragOverride = nil

  hero.renderColor = {[DOTA_TEAM_GOODGUYS] = Vector(125,125,255), 
                      [DOTA_TEAM_BADGUYS]  = Vector(255,125,125),
                      [DOTA_TEAM_CUSTOM_1] = Vector(125,125,255), 
                      [DOTA_TEAM_CUSTOM_2]  = Vector(255,125,125),
                      [DOTA_TEAM_CUSTOM_3] = Vector(125,125,255), 
                      [DOTA_TEAM_CUSTOM_4]  = Vector(255,125,125),
                      [DOTA_TEAM_CUSTOM_5] = Vector(125,125,255), 
                      [DOTA_TEAM_CUSTOM_6]  = Vector(255,125,125),
                      [DOTA_TEAM_CUSTOM_7] = Vector(125,125,255), 
                      [DOTA_TEAM_CUSTOM_8]  = Vector(255,125,125)}


  hero.weaponSet = {{default=require('weapons/default'):InitializeWeapon(hero)},
                    {default=require('weapons/default'):InitializeWeapon(hero)},
                    {default=require('weapons/default'):InitializeWeapon(hero)}}

  hero.activeWeapons = {hero.weaponSet[1]["default"],
                        hero.weaponSet[2]["default"],
                        hero.weaponSet[3]["default"]}

  hero.weapon = hero.activeWeapons[3]
  hero.activeWeaponSlot = 3

  function hero:OnHeroSelectedCamera(camera)
    --print('[HeroClass-Default] OnHeroSelectedCamera')
  end

  function hero:OnLand(onTrees)
    --print('[HeroClass-Default] OnLand')
  end

  function hero:OnTakeOff()
    --print('[HeroClass-Default] OnTakeOff')
  end

  function hero:OnFrame()
    --print('[HeroClass-Default] OnPhysicsFrame')
  end

  function hero:OnDeath()
    --print('[HeroClass-Default] OnDeath')
    hero:SetPhysicsVelocity(Vector(0,0,hero:GetPhysicsVelocity().z))
    hero:ClearStaticVelocity()
    hero:RemoveModifierByName('modifier_tutorial_forceanimation')
  end

  function hero:OnKillUnit(killedUnit)
    --print('[HeroClass-Default] OnKillUnit')
  end

  function hero:OnRespawn()
    print("ON RESPAWN")

    local invuln = ParticleManager:CreateParticle("particles/orb/shield.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, hero)
    ParticleManager:SetParticleControlEnt(invuln, 0, hero, PATTACH_POINT_FOLLOW, "attach_hitloc", hero:GetAbsOrigin(), true)
    hero.dodgeProjectiles = true
    hero.lastDamagedBy = nil
    Timers:CreateTimer(4, function()
      ParticleManager:DestroyParticle(invuln, false)
      hero.dodgeProjectiles = false
    end)

    for k,v in pairs(hero.activeWeapons) do
      v.ammo = v.baseAmmo
      v.ammoReserve = v.baseAmmoReserve
      v.isReloading = false
      v.isSwitching = false
      v.lastShot = GameRules:GetGameTime()

      if v.OnRespawn then
        v:OnRespawn()
      end
    end
  end

  function hero:OnActivateWeapon()
    
  end

  function hero:OnSwitchWeapon(slot)
    if slot == hero.activeWeaponSlot then
      return
    end

    if hero.activeWeapons[slot] then
      local lastWeapon = hero.weapon
      lastWeapon:OnSwitchOut()
      lastWeapon.isSwitching = true
      lastWeapon.isReloading = false
      if hero.reloadTimer then
        Timers:RemoveTimer(hero.reloadTimer)
        hero.reloadTimer = nil
      end

      if hero.switchTimer then
        Timers:RemoveTimer(hero.switchTimer)
        hero.switchTimer = nil
      end

      hero.weapon = hero.activeWeapons[slot]
      hero.weapon.isSwitching = true
      local player = hero:GetPlayerOwner()
      if player then
        CustomGameEventManager:Send_ServerToPlayer(player, "weapon_change", {weapon=hero.weapon.name, time=hero.weapon.switchTime} )
      end

      hero.switchTimer = Timers:CreateTimer(hero.weapon.switchTime, function()
        hero.weapon.isSwitching = false
        lastWeapon.isSwitching = false
      end)

      hero.activeWeaponSlot = slot
    end
  end

  function hero:OnReloadWeapon()
    local gametime = GameRules:GetGameTime()
    if hero.weapon.usesAmmo and hero.weapon.isReloadable and hero.weapon.ammo ~= hero.weapon.ammoCapacity and hero.weapon.ammoReserve > 0 
      and not hero.weapon.isReloading and not hero.weapon.isSwitching then
      -- do reload
      hero.weapon.isReloading = true
      local player = hero:GetPlayerOwner()
      if player then
        CustomGameEventManager:Send_ServerToPlayer(player, "weapon_reload", {time=hero.weapon.reloadTime} )
      end
      hero:EmitSound(hero.weapon.reloadSound)

      hero.reloadTimer = Timers:CreateTimer(hero.weapon.reloadTime,function()
        hero.weapon.isReloading = false
        local ammo = math.min(hero.weapon.ammoCapacity - hero.weapon.ammo, hero.weapon.ammoReserve)
        hero.weapon.ammo = hero.weapon.ammo + ammo
        hero.weapon.ammoReserve = hero.weapon.ammoReserve - ammo
      end)
    end
  end

  function hero:OnLeftClickDown()
    --print('[HeroClass-Default] OnLeftClickDown')

    if hero.weapon.isReloading or hero.weapon.isSwitching then
      return
    end

    if hero.weapon.usesAmmo and hero.weapon.ammo <= 0 then
      if hero.weapon.isReloadable then
        hero:OnReloadWeapon()
      end
      return
    end
    
    hero.weapon:OnLeftClickDown()
  end

  function hero:OnLeftClickUp()
    --print('[HeroClass-Default] OnLeftClickUp')

    hero.weapon:OnLeftClickUp()
  end

  function hero:OnMovementSkillKeyDown()
    --print('[HeroClass-Default] OnMovementSkillKeyDown')
    local gametime = GameRules:GetGameTime()

    if not hero:IsAlive() or hero.lastShift + hero.moveSkillCooldown > gametime or hero:GetMana() < MOVE_SKILL_COST then
      return
    end

    hero:SpendMana(MOVE_SKILL_COST, hero)
    hero.lastShift = gametime
    
    hero.speed = MOVE_SKILL_SPEED
    local particle = ParticleManager:CreateParticle("particles/test_particle/force_staff.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
    hero:EmitSound('DOTA_Item.ForceStaff.Activate2')

    Timers:CreateTimer(.6, function()
      ParticleManager:DestroyParticle(particle, false)
    end)

    if hero.skillTimer then
      Timers:RemoveTimer(hero.skillTimer)
      hero.skillTimer = nil
    end

    hero.skillTimer = Timers:CreateTimer(.3, function() 
      hero.speed = hero.baseMoveSpeed
    end)
  end

  function hero:OnMovementSkillKeyUp()
    --print('[HeroClass-Default] OnMovementSkillKeyUp')
  end

  function hero:OnJump()
    --print('[HeroClass-Default] OnJump')
  end
end

return HERODEFAULT