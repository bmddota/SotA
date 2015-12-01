local WEAPONMODULE = {}

function WEAPONMODULE:InitializeWeapon(hero)
	local WEAPON = require("weapons/default"):InitializeWeapon(hero)
	WEAPON.name = "Raze"
  
  WEAPON.shotSound = 'SOTA.RazeShot'
  WEAPON.shotHitSound = 'SOTA.Raze'
  WEAPON.effectName = "particles/sota_nevermore/nevermore_base_attack.vpcf"

	WEAPON.ammo = 3
	WEAPON.ammoCapacity = 3
	WEAPON.ammoReserve = 9
	WEAPON.ammoMax = 20
	WEAPON.ammoPerPickup = 5
	WEAPON.reloadTime = 1.8
  WEAPON.autoReload = true

  WEAPON.baseAmmo = WEAPON.ammo
  WEAPON.baseAmmoReserve = WEAPON.ammoReserve

	WEAPON.cooldown = .5
	WEAPON.distance = 5000
	WEAPON.radiusStart = 100
	WEAPON.radiusEnd = 100
	WEAPON.damageMin = 1
	WEAPON.damageMax = 80
	WEAPON.speed = 3000

	WEAPON.switchTime = 1.5

  WEAPON.groundBehavior = PROJECTILES_DESTROY

	WEAPON.lastShot = GameRules:GetGameTime()
	WEAPON.isReloading = false
	WEAPON.isSwitching = false

  local explosionRadius = 400
  local explosionForce = 1500

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
      fGroundOffset = 0,
      nChangeMax = 1,
      --draw = true,           --  draw = {alpha=1, color=Vector(200,0,0)},
      --iPositionCP = 0,
      --iVelocityCP = 1,
      --ControlPoints = {[5]=Vector(100,0,0), [10]=Vector(0,0,1)},
      --fRehitDelay = .3,
      --bGroundLock = false,
      --fChangeDelay = 1,
      --fRadiusStep = 10,

      UnitTest = function(self, unit) return unit:GetUnitName() ~= "npc_dummy_unit" and GameRules:IsEnemy(unit:GetTeamNumber(), hero:GetTeamNumber()) and unit.dodgeProjectiles ~= true; end,
      --OnUnitHit = function(self, unit) ... end,
      --OnTreeHit = function(self, tree) ... end,
      --OnWallHit = function(self, gnvPos) ... end,
      --OnGroundHit = function(self, groundPos) ... end,
      OnFinish = function(self, pos) 
        local ents = Entities:FindAllInSphere(pos, explosionRadius)
        --DebugDrawSphere(pos, Vector(255,0,0), .1, explosionRadius, true, .3)

        local hit = false
        local hitOther = false

        for i=1,#ents do
          local v = ents[i]

          if IsValidEntity(v) and v.GetUnitName and v:IsAlive() and (hero == v or self.UnitTest(self, v)) then
            local zOffset = v.zOffset or 0
            local height = (v.height or 150) + zOffset

            local org = v:GetAbsOrigin()
            local nozorg = Vector(org.x, org.y, 0)
            local nozpos = Vector(pos.x, pos.y, 0)
            local dist = (nozorg - nozpos):Length()
            local nozCheck = dist <= explosionRadius
            local zCheck = pos.z >= org.z + zOffset - explosionRadius/2 and pos.z <= org.z + height + explosionRadius/2

            if nozCheck and zCheck then
              if not hit then
                v:EmitSound(WEAPON.shotHitSound)

                if (pos-hero:GetAbsOrigin()):Length() > 2200 then
                  EmitSoundOnClient(WEAPON.shotHitSound, hero:GetPlayerOwner())
                end
              end
              hit = true
              local damageMod = 1
              if hero ~= v then
                hitOther = true
              elseif not hero:HasModifier('mana_regen_reduced') then
                damageMod = .5
              end

              local force = math.min(((explosionRadius - dist) / (explosionRadius * .75)), 1) * explosionForce
              local damageTable = {
                victim = v,
                attacker = hero,
                damage = damageMod * (((explosionRadius - dist) / explosionRadius) * WEAPON.damageMax),
                damage_type = DAMAGE_TYPE_PURE,
              }

              ApplyDamage(damageTable)
              if IsPhysicsUnit(v) then
                local dir = (org - pos):Normalized()
                --dir.z = dir.z / 2
                v:AddPhysicsVelocity(dir * force)
                if v.IsRealHero and v:IsRealHero() and force > 0 then
                  --GameRules:LerpCamera(v, force/2)
                end
              end
            end
          end
        end

        if hit then
          if hitOther then EmitSoundOnClient(hero.projectileHitSound, hero:GetPlayerOwner()) end
        else
          local dummy = CreateUnitByName('npc_dummy_unit', pos, false, nil, nil, DOTA_TEAM_NOTEAM)
          dummy:FindAbilityByName("reflex_dummy_unit"):SetLevel(1)
          dummy:EmitSound(WEAPON.shotHitSound)

          if (pos-hero:GetAbsOrigin()):Length() > 2200 then
            EmitSoundOnClient(WEAPON.shotHitSound, hero:GetPlayerOwner())
          end

          Timers:CreateTimer(.3, function() dummy:RemoveSelf() end)
        end


        local particle = ParticleManager:CreateParticle("particles/sota_nevermore/nevermore_shadowraze.vpcf", PATTACH_POINT, hero)
        ParticleManager:SetParticleControl(particle, 0, pos)
        ParticleManager:ReleaseParticleIndex(particle)
      end,
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