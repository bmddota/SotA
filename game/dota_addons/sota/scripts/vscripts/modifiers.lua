function SpeedChange(keys)
	if not keys.target.IsHero or not keys.target:IsHero() then
		return
	end

	keys.target.speedModifier = keys.target.speedModifier * keys.Amount
end

function SpeedChangeEnd(keys)
	if not keys.target.IsHero or not keys.target:IsHero() then
		return
	end

	keys.target.speedModifier = keys.target.speedModifier / keys.Amount
end