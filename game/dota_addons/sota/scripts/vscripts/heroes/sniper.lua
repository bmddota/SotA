local HEROMODULE = {}

function HEROMODULE:InitializeClass(hero)
	require('heroes/default'):InitializeClass(hero)

	local MOVE_SKILL_SPEED = 2000
	local MOVE_SKILL_COST = 85

	hero.weaponSet = {{knife=require('weapons/knife'):InitializeWeapon(hero)},
										{pistol=require('weapons/pistol'):InitializeWeapon(hero)},
										{sniper_rifle=require('weapons/sniper_rifle'):InitializeWeapon(hero)}}

	hero.activeWeapons = {hero.weaponSet[1]["knife"],
												hero.weaponSet[2]["pistol"],
												hero.weaponSet[3]["sniper_rifle"]}

	hero.weapon = hero.activeWeapons[3]
	hero.activeWeaponSlot = 3

  hero.baseCameraDistance = 290

	hero.baseMoveSpeed = 525
	hero.speed = 525
	hero.height = 160

	hero.moveSkillCooldown = .5

	FireGameEvent("weapon_change", {pid=hero:GetPlayerID(), weapon=hero.weapon.name, time=0})

	function hero:OnMovementSkillKeyDown()
		--print('[HeroClass-Default] OnMovementSkillKeyDown')
		local gametime = GameRules:GetGameTime()

    if not hero:IsAlive() or hero.lastShift + hero.moveSkillCooldown > gametime or hero:GetMana() < MOVE_SKILL_COST then
      return
    end

    hero:SpendMana(MOVE_SKILL_COST, hero)
    hero.lastShift = gametime
    
    hero:SetStaticVelocity("back", hero:GetForwardVector() * MOVE_SKILL_SPEED * -3/4)
    hero:AddPhysicsVelocity(Vector(0,0,MOVE_SKILL_SPEED * 1/4))
    local particle = ParticleManager:CreateParticle("particles/test_particle/force_staff.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
    hero:EmitSound('DOTA_Item.ForceStaff.Activate2')

    Timers:CreateTimer(.6, function()
      ParticleManager:DestroyParticle(particle, false)
    end)

    if hero.skillTimer then
    	Timers:RemoveTimer(hero.skillTimer)
    	hero.skillTimer = nil
    end

    hero.skillTimer = Timers:CreateTimer(.5, function() 
      hero:SetStaticVelocity("back", Vector(0,0,0))
    end)
	end
end

return HEROMODULE