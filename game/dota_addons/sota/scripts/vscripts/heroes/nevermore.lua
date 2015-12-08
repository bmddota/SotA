local HEROMODULE = {}

function HEROMODULE:InitializeClass(hero)
	require('heroes/default'):InitializeClass(hero)

	hero.weaponSet = {{knife=require('weapons/knife'):InitializeWeapon(hero)},
	       			 {SMG=require('weapons/SMG'):InitializeWeapon(hero)},
					 {raze=require('weapons/raze'):InitializeWeapon(hero)}}

	hero.activeWeapons = {hero.weaponSet[1]["knife"],
						  hero.weaponSet[2]["SMG"],
						  hero.weaponSet[3]["raze"]}

    hero.renderColor = {[DOTA_TEAM_GOODGUYS] = Vector(0,0,255), 
                        [DOTA_TEAM_BADGUYS]  = Vector(255,0,0),
                        [DOTA_TEAM_CUSTOM_1] = Vector(0,0,255), 
                        [DOTA_TEAM_CUSTOM_2]  = Vector(255,0,0),
                        [DOTA_TEAM_CUSTOM_3] = Vector(0,0,255), 
                        [DOTA_TEAM_CUSTOM_4]  = Vector(255,0,0),
                        [DOTA_TEAM_CUSTOM_5] = Vector(0,0,255), 
                        [DOTA_TEAM_CUSTOM_6]  = Vector(255,0,0),
                        [DOTA_TEAM_CUSTOM_7] = Vector(0,0,255), 
                        [DOTA_TEAM_CUSTOM_8]  = Vector(255,0,0)}

	hero.weapon = hero.activeWeapons[3]
	hero.activeWeaponSlot = 3

    hero.baseCameraDistance = 325
    
    hero.baseMoveSpeed = 600
    hero.speed = 600
    hero.height = 215

    hero.flamesParticle = ParticleManager:CreateParticle("particles/test_particle/color_flames.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
    ParticleManager:SetParticleControl(hero.flamesParticle, 1, hero.renderColor[hero:GetTeam()])
end

return HEROMODULE