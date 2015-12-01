function Teleport(trigger)
	if not trigger.activator.IsHero or not trigger.activator:IsHero() then
		return
	end

	local tpName = string.match(trigger.caller:GetName(), "tp_(.*)")

	local endpoint = Entities:FindByName(nil, tpName)
	if endpoint == nil then
		print("[Trigger-Teleport] Couldn't find endpoint '" .. tpName .. "'")
		return
	end

	local ground = GetGroundPosition(endpoint:GetAbsOrigin() + RandomVector(RandomFloat(20,100)), trigger.activator)
	trigger.activator:SetAbsOrigin(ground)
end

function SpeedChange(trigger)
	if not trigger.activator.IsHero or not trigger.activator:IsHero() or (trigger.activator.isTouching and trigger.activator.isTouching[trigger.caller:GetName()])then
		return
	end

	if not trigger.activator.isTouching then
		trigger.activator.isTouching = {}
	end

	--trigger.activator.isTouching[trigger.caller:GetName()] = true
	if not trigger.activator:HasModifier("sewer_slow") then
		--	
	end
	GameRules.ApplyModifier(trigger.activator, trigger.activator, "sewer_slow", {duration=.5})
end

function SpeedChangeEnd(trigger)
	if not trigger.activator.IsHero or not trigger.activator:IsHero() then
		return
	end

	--trigger.activator.isTouching[trigger.caller:GetName()] = true

	--trigger.activator:RemoveModifierByName('sewer_slow')
end

function LavaTouch(trigger)
	if not trigger.activator.IsHero or not trigger.activator:IsHero() then
		if trigger.activator.GetUnitName then
			if trigger.activator:GetUnitName() == "radiant_flag" then
				FireGameEvent("show_center_message", {message="Radiant Flag Returned!", duration=2.9})
        GameRules.GameMode:PlayTeamSound('SOTA.FlagSuccess', 'SOTA.FlagFail')

        if trigger.activator.particle then
          ParticleManager:DestroyParticle(trigger.activator.particle, true)
          trigger.activator.particle = nil
        end
        trigger.activator:SetAbsOrigin(GameRules.radiantFlagSpawn:GetAbsOrigin())
        trigger.activator:SetForwardVector(GameRules.radiantFlagSpawn:GetForwardVector())
			elseif trigger.activator:GetUnitName() == "dire_flag" then
				FireGameEvent("show_center_message", {message="Dire Flag Returned!", duration=2.9})
        GameRules.GameMode:PlayTeamSound('SOTA.FlagFail', 'SOTA.FlagSuccess')

        if trigger.activator.particle then
          ParticleManager:DestroyParticle(trigger.activator.particle, true)
          trigger.activator.particle = nil
        end
        trigger.activator:SetAbsOrigin(GameRules.direFlagSpawn:GetAbsOrigin())
        trigger.activator:SetForwardVector(GameRules.direFlagSpawn:GetForwardVector())
			end
		end
		return
	end

	if trigger.activator:IsAlive() then
		--trigger.activator:ForceKill(false)
		local damageTable = {
      victim = trigger.activator,
      attacker = trigger.activator,
      damage = 10000,
      damage_type = DAMAGE_TYPE_PURE,
    }

    ApplyDamage(damageTable)
	end
end