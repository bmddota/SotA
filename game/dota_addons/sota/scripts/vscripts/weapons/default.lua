local WEAPONMODULE = {}

function WEAPONMODULE:InitializeWeapon(hero)
	local WEAPON = {}
	WEAPON.name = "Default"

	--WEAPON.effectName = "particles/frostivus_gameplay/frostivus_skeletonking_hellfireblast.vpcf"
  WEAPON.effectName = "particles/bullet/bullet.vpcf"
	WEAPON.shotSound = 'Hero_Sniper.attack2'
	WEAPON.shotHitSound = 'Hero_Sniper.ProjectileImpact2'
	WEAPON.reloadSound = 'SOTA.Reload'

	WEAPON.isReloadable = true
	WEAPON.usesAmmo = true

	WEAPON.ammo = 12
	WEAPON.ammoCapacity = 12
	WEAPON.ammoReserve = 36
	WEAPON.ammoMax = 140
	WEAPON.ammoPerPickup = 24
	WEAPON.reloadTime = 1.4
	WEAPON.autoReload = false

	WEAPON.baseAmmo = WEAPON.ammo
  WEAPON.baseAmmoReserve = WEAPON.ammoReserve

	WEAPON.cooldown = 0.2
	WEAPON.distance = 3000
	WEAPON.radiusStart = 100
	WEAPON.radiusEnd = 100
	WEAPON.damageMin = 20
	WEAPON.damageMax = 20
	WEAPON.speed = 3000

	WEAPON.wallBehavior = PROJECTILES_DESTROY
	WEAPON.groundBehavior = PROJECTILES_DESTROY
	WEAPON.treeBehavior = PROJECTILES_DESTROY
	WEAPON.unitBehavior = PROJECTILES_DESTROY

	WEAPON.switchTime = 1.0

	WEAPON.lastShot = GameRules:GetGameTime()
	WEAPON.isReloading = false
	WEAPON.isSwitching = false

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
        bRecreateOnChange = true,
        bZCheck = true,
        --draw = true,             draw = {alpha=1, color=Vector(200,0,0)},
        --bTreeFullCollision = false,
        --bGroundLock = false,
        --bProvidesVision = false,
        --iVisionRadius = 350,
        --iVisionTeamNumber = hero:GetTeam(),
        --bFlyingVision = false,
        --fVisionTickTime = .1,
        --fVisionLingerDuration = 1,
        --iPositionCP = 0,
        --iVelocityCP = 1,
        --ControlPoints = {[5]=Vector(100,0,0), [10]=Vector(0,0,1)},
        --ControlPointForwards = {[4]=hero:GetForwardVector() * -1},
        --ControlPointOrientations = {[1]={hero:GetForwardVector() * -1, hero:GetForwardVector() * -1, hero:GetForwardVector() * -1}},
        --[[ControlPointEntityAttaches = {[0]={
          unit = hero,
          pattach = PATTACH_ABSORIGIN_FOLLOW,
          attachPoint = "attach_attack1", -- nil
          origin = Vector(0,0,0)
        }},]]
        --fRehitDelay = .3,
        --fChangeDelay = 1,
        --fRadiusStep = 10,
        --bUseFindUnitsInRadius = false,

        UnitTest = function(self, unit) return unit:GetUnitName() ~= "npc_dummy_unit" and GameRules:IsEnemy(unit:GetTeamNumber(), hero:GetTeamNumber()) and unit.dodgeProjectiles ~= true; end,
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

      return WEAPON.cooldown
    end)
	end

	function WEAPON:OnLeftClickUp()
		if WEAPON.shootTimer then
      Timers:RemoveTimer(WEAPON.shootTimer)
      WEAPON.shootTimer = nil
    end
	end

	function WEAPON:OnSwitchOut()
		if WEAPON.shootTimer then
      Timers:RemoveTimer(WEAPON.shootTimer)
      WEAPON.shootTimer = nil
    end
	end

	function WEAPON:OnLand(onTrees)

	end

	function WEAPON:OnTakeOff()

	end

	function WEAPON:OnPhysicsFrame()

	end

	function WEAPON:OnDeath()

	end

	function WEAPON:OnKillHero()

	end

	function WEAPON:OnMovementSkillDown()

	end

	function WEAPON:OnMovementSkillUp()

	end

	function WEAPON:OnJump()

	end

	return WEAPON
end

return WEAPONMODULE