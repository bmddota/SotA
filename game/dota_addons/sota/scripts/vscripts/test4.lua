function test4(keys)
  if keys.target and keys.target.GetUnitName and keys.target:GetUnitName() == "npc_dummy_unit" then
    return
  end

  local damageTable = {
    victim = keys.target,
    attacker = keys.caster,
    damage = 52,
    damage_type = DAMAGE_TYPE_PURE,
  }

  keys.target:EmitSound('Hero_Sniper.ProjectileImpact2')

  ApplyDamage(damageTable)
end