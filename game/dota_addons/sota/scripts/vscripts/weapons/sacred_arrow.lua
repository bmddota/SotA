local WEAPONMODULE = {}

function WEAPONMODULE:InitializeWeapon(hero)
	local WEAPON = require("weapons/default"):InitializeWeapon(hero)
	WEAPON.name = "Sacred Arrow"

  WEAPON.effectName = "particles/sota_mirana/mirana_spell_arrow.vpcf"
  WEAPON.shotSound = 'SOTA.ArrowCast'
  WEAPON.shotHitSound = 'SOTA.BigImpact'

	WEAPON.ammo = 1
	WEAPON.ammoCapacity = 1
	WEAPON.ammoReserve = 8
	WEAPON.ammoMax = 16
	WEAPON.ammoPerPickup = 4
	WEAPON.reloadTime = 1.0
  WEAPON.autoReload = true

  WEAPON.baseAmmo = WEAPON.ammo
  WEAPON.baseAmmoReserve = WEAPON.ammoReserve

	WEAPON.cooldown = 1.0
	WEAPON.distance = 10000
	WEAPON.radiusStart = 110
	WEAPON.radiusEnd = 110
	WEAPON.damageMin = 40
	WEAPON.damageMax = 75
	WEAPON.speed = 5000

	WEAPON.treeBehavior = PROJECTILES_NOTHING
  WEAPON.unitBehavior = PROJECTILES_NOTHING
  WEAPON.groundBehavior = PROJECTILES_DESTROY
  WEAPON.wallBehavior = PROJECTILES_DESTROY

	WEAPON.switchTime = 1.0

	WEAPON.lastShot = GameRules:GetGameTime()
	WEAPON.isReloading = false
	WEAPON.isSwitching = false

  WEAPON.chargeTime = GameRules:GetGameTime()
  WEAPON.charging = false

  local MOVE_SPEED = 400
  local CHARGE_MAX = 1

	function WEAPON:OnLeftClickDown()
		local gametime = GameRules:GetGameTime()

    local start = 0.03

    if WEAPON.lastShot + WEAPON.cooldown > gametime then
      start = WEAPON.lastShot + WEAPON.cooldown - gametime
    end

    if WEAPON.shootTimer ~= nil then
      Timers:RemoveTimer(WEAPON.shootTimer)
    end
    WEAPON.shootTimer = Timers:CreateTimer(start, function()

      if not hero:IsAlive() then
        return
      end

      if WEAPON.ammo <= 0 or WEAPON.isReloading or WEAPON.isSwitching then
      	return
      end

      --hero.useReticle = true
      hero.reticleOffset = Vector(0,0,80)
      hero.speed = MOVE_SPEED
      WEAPON.charging = true
      hero:EmitSound('SOTA.PowershotPull')
      local player = hero:GetPlayerOwner()
      if player then
        CustomGameEventManager:Send_ServerToPlayer(player, "sota_charge", {time=CHARGE_MAX} )
      end
      --ControlOverride:SendCvar(hero:GetPlayerID(), "dota_camera_fov_max", "30")
      --hero.aimPitchOffset = 14

      WEAPON.chargeTime = GameRules:GetGameTime()
    end)
	end

	function WEAPON:OnLeftClickUp()
		if WEAPON.shootTimer then
      Timers:RemoveTimer(WEAPON.shootTimer)
      WEAPON.shootTimer = nil
    end

    if WEAPON.charging then
      WEAPON:Shoot()
    end
	end

  function WEAPON:Shoot()
    hero.useReticle = false
    hero.reticleOffset = Vector(0,0,0)
    WEAPON.charging = false
    hero:StopSound('SOTA.PowershotPull')
    local player = hero:GetPlayerOwner()
    if player then
      CustomGameEventManager:Send_ServerToPlayer(player, "sota_charge", {time=0} )
    end

    if not hero:IsAlive() then
      return
    end

    local gametime = GameRules:GetGameTime()

    local chargeTime = math.min(gametime - WEAPON.chargeTime, CHARGE_MAX)
    --if chargeTime < 1 then
      --return
    --end

    --ControlOverride:SendCvar(hero:GetPlayerID(), "dota_camera_fov_max", "80")
    Timers:CreateTimer(.5, function()  
      hero.speed = hero.baseMoveSpeed
      --hero.aimPitchOffset = hero.baseAimPitchOffset
    end)

    local speed = (chargeTime + 2)/3 * WEAPON.speed
    local totalDamage =  chargeTime * (WEAPON.damageMax - WEAPON.damageMin)  + WEAPON.damageMin
    local stunDur = chargeTime/3 + 1/3
    print(totalDamage, stunDur)


    local projectile = {
      --EffectName = "particles/test_particle/ranged_tower_good.vpcf",
      EffectName = WEAPON.effectName,
      --vSpawnOrigin = hero:GetAbsOrigin(),
      vSpawnOrigin = hero:GetAbsOrigin() + hero.shotOffset,--{unit=hero, attach="attach_attack1", offset=Vector(0,0,0)},
      fDistance = WEAPON.distance,
      fStartRadius = WEAPON.radiusStart,
      fEndRadius = WEAPON.radiusEnd,
      Source = hero,
      fExpireTime = 15.0,
      vVelocity = hero.aim * speed, -- RandomVector(1000),
      UnitBehavior = WEAPON.unitBehavior,
      bMultipleHits = false,
      bIgnoreSource = true,
      TreeBehavior = WEAPON.treeBehavior,--PROJECTILES_NOTHING,
      bCutTrees = true,
      WallBehavior = WEAPON.wallBehavior,--PROJECTILES_BOUNCE,
      GroundBehavior = WEAPON.groundBehavior,--PROJECTILES_BOUNCE,
      fGroundOffset = 0,
      nChangeMax = 1,
      bRecreateOnChange = false,
      --draw = true,           --  draw = {alpha=1, color=Vector(200,0,0)},
      --iPositionCP = 0,
      --iVelocityCP = 1,
      --ControlPoints = {[5]=Vector(100,0,0), [10]=Vector(0,0,1)},
      --fRehitDelay = .3,
      --bGroundLock = false,
      --fChangeDelay = 1,
      --fRadiusStep = 10,

      UnitTest = function(self, unit) return unit:GetUnitName() ~= "npc_dummy_unit" and GameRules:IsEnemy(unit:GetTeamNumber(), hero:GetTeamNumber()) and unit.dodgeProjectiles ~= true; end,
      OnUnitHit = function(self, unit) 
        local damageTable = {
          victim = unit,
          attacker = hero,
          damage = totalDamage,
          damage_type = DAMAGE_TYPE_PURE,
        }

        unit:AddNewModifier(hero, nil, "modifier_stun", {duration=stunDur})
        unit.fixPosition = function()
          --print('fixPos', self.pos - Vector(0,0,80))
          return self.pos - Vector(0,0,80)
        end

        Timers:CreateTimer(stunDur, function()
          unit.fixPosition = nil
          local org = unit:GetAbsOrigin()
          local ground = GetGroundPosition(org, unit)
          if ground.z > org.z then  
            unit:SetAbsOrigin(ground)
          end
        end)

        EmitSoundOnClient(hero.projectileHitSound, hero:GetPlayerOwner())
        unit:EmitSound(WEAPON.shotHitSound)

        ApplyDamage(damageTable)
      end,
      --OnTreeHit = function(self, tree) ... end,
      OnWallHit = function(self, gnvPos) 
        local endParticle = ParticleManager:CreateParticle("particles/sota_mirana/mirana_spell_arrow_end.vpcf", PATTACH_CUSTOMORIGIN, nil)
        local vel = self.vel:Normalized() * 75
        ParticleManager:SetParticleControl(endParticle, 0, self.pos + vel)
        ParticleManager:SetParticleControl(endParticle, 1, vel)

        Timers:CreateTimer(2, function()
          ParticleManager:DestroyParticle(endParticle, true)
        end)
      end,
      OnGroundHit = function(self, groundPos)
        local endParticle = ParticleManager:CreateParticle("particles/sota_mirana/mirana_spell_arrow_end.vpcf", PATTACH_CUSTOMORIGIN, nil)
        local vel = self.vel:Normalized() * 75
        ParticleManager:SetParticleControl(endParticle, 0, self.pos + vel)
        ParticleManager:SetParticleControl(endParticle, 1, vel)
        print(self.vel:Normalized())

        Timers:CreateTimer(2, function()
          ParticleManager:DestroyParticle(endParticle, true)
        end)
      end,
      --OnFinish = function(self, pos) ... end,
    }

    Projectiles:CreateProjectile(projectile)
    WEAPON.ammo = WEAPON.ammo - 1
    hero:EmitSound(WEAPON.shotSound)
    WEAPON.lastShot = gametime

    if WEAPON.ammo == 0 and WEAPON.autoReload then
      hero:OnReloadWeapon()
      return
    end
  end

  function WEAPON:OnSwitchOut()
    if WEAPON.shootTimer then
      Timers:RemoveTimer(WEAPON.shootTimer)
      WEAPON.shootTimer = nil
    end

    if WEAPON.charging then
      hero.useReticle = false
      hero.reticleOffset = Vector(0,0,0)
      WEAPON.charging = false
      Timers:CreateTimer(.5, function()  
        --ControlOverride:SendCvar(hero:GetPlayerID(), "dota_camera_fov_max", "80")
        hero.speed = hero.baseMoveSpeed
        --hero.aimPitchOffset = hero.baseAimPitchOffset
      end)
    end
  end

	return WEAPON
end

return WEAPONMODULE