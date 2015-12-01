local WEAPONMODULE = {}

function WEAPONMODULE:InitializeWeapon(hero)
	local WEAPON = require("weapons/default"):InitializeWeapon(hero)
	WEAPON.name = "Knife"

  WEAPON.effectName = ""
  WEAPON.shotSound = 'Creep_Good_Melee.PreAttack'
  WEAPON.shotHitSound = 'Creep_Good_Melee.Attack'

  WEAPON.isReloadable = false
  WEAPON.usesAmmo = false

	WEAPON.ammo = 1
	WEAPON.ammoCapacity = 1
	WEAPON.ammoReserve = 1
	WEAPON.ammoMax = 1
	WEAPON.ammoPerPickup = 1
	WEAPON.reloadTime = 1.6
  WEAPON.autoReload = true

  WEAPON.baseAmmo = WEAPON.ammo
  WEAPON.baseAmmoReserve = WEAPON.ammoReserve

	WEAPON.cooldown = .4
	WEAPON.distance = 45
	WEAPON.radiusStart = 180
	WEAPON.radiusEnd = 180
	WEAPON.damageMin = 35
	WEAPON.damageMax = 35
	WEAPON.speed = 2000

	WEAPON.switchTime = 0.5

  WEAPON.wallBehavior = PROJECTILES_NOTHING
  WEAPON.groundBehavior = PROJECTILES_NOTHING
  WEAPON.treeBehavior = PROJECTILES_NOTHING
  WEAPON.unitBehavior = PROJECTILES_NOTHING

	WEAPON.lastShot = GameRules:GetGameTime()
	WEAPON.isReloading = false
	WEAPON.isSwitching = false

  local count = 0

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
    end)
	end

	function WEAPON:OnLeftClickUp()
		if WEAPON.shootTimer then
      Timers:RemoveTimer(WEAPON.shootTimer)
      WEAPON.shootTimer = nil
    end
	end

  function WEAPON:Shoot()
    local gametime = GameRules:GetGameTime()

    local projectile = {
      --EffectName = "particles/test_particle/ranged_tower_good.vpcf",
      EffectName = WEAPON.effectName,--particles/frostivus_gameplay/frostivus_skeletonking_hellfireblast.vpcf",
      --vSpawnOrigin = hero:GetAbsOrigin(),
      vSpawnOrigin = hero:GetAbsOrigin() + hero:GetForwardVector() * WEAPON.radiusStart/2 + hero.shotOffset,--{unit=hero, attach="attach_attack1", offset=Vector(0,0,0)},
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
      nChangeMax = 4,
      --draw = true,            -- draw = {alpha=1, color=Vector(200,0,0)},
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
          damage = RandomInt(WEAPON.damageMin, WEAPON.damageMax),
          damage_type = DAMAGE_TYPE_PURE,
        }

        unit:EmitSound(WEAPON.shotHitSound)

        ApplyDamage(damageTable)
      end,
      --OnTreeHit = function(self, tree) ... end,
      --OnWallHit = function(self, gnvPos) ... end,
      --OnGroundHit = function(self, groundPos) ... end,
      --OnFinish = function(self, pos) ... end,
    }

    Projectiles:CreateProjectile(projectile)
    hero:EmitSound(WEAPON.shotSound)
    WEAPON.lastShot = gametime

    if count == 0 then
      ParticleManager:ReleaseParticleIndex(ParticleManager:CreateParticle("particles/test_particle/sven_attack_blur.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero))
      count = 1
    elseif count == 1 then
      ParticleManager:ReleaseParticleIndex(ParticleManager:CreateParticle("particles/test_particle/sven_attack_blur_2.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero))
      count = 0
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