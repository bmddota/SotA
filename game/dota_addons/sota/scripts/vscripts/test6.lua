local hero = PlayerResource:GetPlayer(0):GetAssignedHero()
--hero.shotOffset = Vector(0,0,150)

if true then
  return
end


for _,hero in ipairs(HeroList:GetAllHeroes()) do

if hero.particle then
  ParticleManager:DestroyParticle(particle, true)
end

hero.particle = ParticleManager:CreateParticle("particles/test_particle/color_flames.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
ParticleManager:SetParticleControl(hero.particle, 1, hero.renderColor[hero:GetTeam()])

end