local WEAPONMODULE = {}

function WEAPONMODULE:InitializeWeapon(hero)
	local WEAPON = require("weapons/default"):InitializeWeapon(hero)
	WEAPON.name = "SMG"

  WEAPON.reloadSound = 'SOTA.Rearm'
  WEAPON.shotHitSound = 'SOTA.BigImpact'

	WEAPON.ammo = 30
	WEAPON.ammoCapacity = 30
	WEAPON.ammoReserve = 60
	WEAPON.ammoMax = 120
	WEAPON.ammoPerPickup = 30
	WEAPON.reloadTime = 1.6
  WEAPON.autoReload = true

  WEAPON.baseAmmo = WEAPON.ammo
  WEAPON.baseAmmoReserve = WEAPON.ammoReserve

	WEAPON.cooldown = .5
	WEAPON.distance = 3200
	WEAPON.radiusStart = 100
	WEAPON.radiusEnd = 100
	WEAPON.damageMin = 11
	WEAPON.damageMax = 11
	WEAPON.speed = 4000

	WEAPON.switchTime = 1.4

  WEAPON.groundBehavior = PROJECTILES_FOLLOW

	WEAPON.lastShot = GameRules:GetGameTime()
	WEAPON.isReloading = false
	WEAPON.isSwitching = false

  WEAPON.chargeTime = GameRules:GetGameTime()
  WEAPON.charging = false

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

      WEAPON:Shoot()
      Timers:CreateTimer(.1, function() WEAPON:Shoot() end)
      Timers:CreateTimer(.2, function() WEAPON:Shoot() end)

      return WEAPON.cooldown
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
    if WEAPON.ammo <= 0 or WEAPON.isReloading or WEAPON.isSwitching then
      return
    end

    local gametime = GameRules:GetGameTime()

    local projectile = {
      --EffectName = "particles/test_particle/ranged_tower_good.vpcf",
      EffectName = WEAPON.effectName,
      --vSpawnOrigin = hero:GetAbsOrigin(),
      vSpawnOrigin = hero:GetAbsOrigin() + hero.shotOffset,--{unit=hero, attach="attach_attack1", offset=Vector(0,0,0)},
      fDistance = WEAPON.distance,
      fStartRadius = WEAPON.radiusStart,
      fEndRadius = WEAPON.radiusEnd,
      Source = hero,
      fExpireTime = 8.0,
      vVelocity = hero.aim * WEAPON.speed, -- RandomVector(1000),
      UnitBehavior = WEAPON.unitBehavior,
      bMultipleHits = false,
      bIgnoreSource = true,
      TreeBehavior = WEAPON.treeBehavior,--PROJECTILES_NOTHING,
      bCutTrees = true,
      WallBehavior = WEAPON.wallBehavior,--PROJECTILES_BOUNCE,
      GroundBehavior = WEAPON.groundBehavior,--PROJECTILES_BOUNCE,
      fGroundOffset = 50,
      nChangeMax = 1,
      --filter = TestFilter,
      --draw = true,            -- draw = {alpha=1, color=Vector(200,0,0)},
      --iPositionCP = 0,
      --iVelocityCP = 1,
      --ControlPoints = {[5]=Vector(100,0,0), [10]=Vector(0,0,1)},
      --fRehitDelay = .3,
      --bGroundLock = false,
      --fChangeDelay = 1,
      --fRadiusStep = 10,

      UnitTest = function(self, unit) 
        return unit:GetUnitName() ~= "npc_dummy_unit" and GameRules:IsEnemy(unit:GetTeamNumber(), hero:GetTeamNumber()) and unit.dodgeProjectiles ~= true; 
      end,
      OnUnitHit = function(self, unit) 
        local damageTable = {
          victim = unit,
          attacker = hero,
          damage = RandomInt(WEAPON.damageMin, WEAPON.damageMax),
          damage_type = DAMAGE_TYPE_PURE,
        }

        EmitSoundOnClient(hero.projectileHitSound, hero:GetPlayerOwner())
        unit:EmitSound(WEAPON.shotHitSound)

        ApplyDamage(damageTable)
      end,
      --OnTreeHit = function(self, tree) ... end,
      --OnWallHit = function(self, gnvPos) ... end,
      --OnGroundHit = function(self, groundPos) ... end,
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
  end

	return WEAPON
end

return WEAPONMODULE