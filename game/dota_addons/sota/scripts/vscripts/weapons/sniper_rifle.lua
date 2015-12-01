local WEAPONMODULE = {}

function WEAPONMODULE:InitializeWeapon(hero)
	local WEAPON = require("weapons/default"):InitializeWeapon(hero)
	WEAPON.name = "Sniper Rifle"

  WEAPON.effectName = "particles/test_particle/sniper_assassinate.vpcf"
  WEAPON.shotSound = 'SOTA.Assassinate'
  WEAPON.shotHitSound = 'SOTA.BigImpact'

	WEAPON.ammo = 1
	WEAPON.ammoCapacity = 1
	WEAPON.ammoReserve = 10
	WEAPON.ammoMax = 30
	WEAPON.ammoPerPickup = 5
	WEAPON.reloadTime = 1.4
  WEAPON.autoReload = true

  WEAPON.baseAmmo = WEAPON.ammo
  WEAPON.baseAmmoReserve = WEAPON.ammoReserve

	WEAPON.cooldown = 1.0
	WEAPON.distance = 8500
	WEAPON.radiusStart = 100
	WEAPON.radiusEnd = 100
	WEAPON.damageMin = 101
	WEAPON.damageMax = 101
	WEAPON.speed = 18000

	WEAPON.treeBehavior = PROJECTILES_NOTHING
  WEAPON.unitBehavior = PROJECTILES_NOTHING
  WEAPON.groundBehavior = PROJECTILES_DESTROY
  WEAPON.wallBehavior = PROJECTILES_DESTROY

	WEAPON.switchTime = 2.0

	WEAPON.lastShot = GameRules:GetGameTime()
	WEAPON.isReloading = false
	WEAPON.isSwitching = false

  WEAPON.chargeTime = GameRules:GetGameTime()
  WEAPON.charging = false

  local MOVE_SPEED = 200

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
      hero:EmitSound('SOTA.GunCock')
      FireGameEvent("sota_charge", {pid=hero:GetPlayerID(), time=3})
      --ControlOverride:SendCvar(hero:GetPlayerID(), "dota_camera_fov_max", "50")
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
    FireGameEvent("sota_charge", {pid=hero:GetPlayerID(), time=0})
    Timers:CreateTimer(.5, function()  
      --ControlOverride:SendCvar(hero:GetPlayerID(), "dota_camera_fov_max", "80")
      hero.speed = hero.baseMoveSpeed
      --hero.aimPitchOffset = hero.baseAimPitchOffset
    end)

    if not hero:IsAlive() then
      return
    end

    local gametime = GameRules:GetGameTime()

    local chargeTime = math.min(gametime - WEAPON.chargeTime, 3)

    local speed = ((2 + chargeTime) / 5) * WEAPON.speed
    local damageMult = ((2 + chargeTime) / 5)


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
      vVelocity = hero.aim * speed, -- RandomVector(1000),
      UnitBehavior = WEAPON.unitBehavior,
      bMultipleHits = false,
      bIgnoreSource = true,
      TreeBehavior = WEAPON.treeBehavior,--PROJECTILES_NOTHING,
      bCutTrees = true,
      WallBehavior = WEAPON.wallBehavior,--PROJECTILES_BOUNCE,
      GroundBehavior = WEAPON.groundBehavior,--PROJECTILES_BOUNCE,
      fGroundOffset = 50,
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
          damage = RandomInt(WEAPON.damageMin, WEAPON.damageMax) * damageMult,
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