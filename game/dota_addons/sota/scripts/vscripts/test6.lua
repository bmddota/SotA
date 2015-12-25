local hero = PlayerResource:GetPlayer(0):GetAssignedHero()

if particle then
  ParticleManager:DestroyParticle(particle, false)
end
particle = ParticleManager:CreateParticle("particles/ice_trail.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)

if true then
  return
end


--hero.shotOffset = Vector(0,0,150)
require("libraries/animations")

local pos = Entities:FindByName(nil, "angel_position")
if IsValidEntity(angel) then
  angel:RemoveSelf()
end
angel = CreateUnitByName("npc_angel", pos:GetAbsOrigin(), false, nil, nil, DOTA_TEAM_NEUTRALS)

Timers:CreateTimer(function()
  angel:SetAbsOrigin(pos:GetAbsOrigin())
end)

if angelTimer then Timers:RemoveTimer(angelTimer) end
angelTimer = Timers:CreateTimer(function()
  StartAnimation(angel, {duration=35, activity=ACT_DOTA_CAST_ABILITY_4, rate=0.2})
  return 35
end)
  

if true then
  return
end

debug.sethook(function(...)
  local info = debug.getinfo(2)
  local src = tostring(info.short_src)
  local name = tostring(info.name)
  if name ~= "__index" then
    print("Call: " .. tostring(info.short_src) .. " -- " .. tostring(info.name))
  end
end, "c")

if true then
  return
end

require("libraries/attachments")

if IsValidEntity(prop) then
  prop:RemoveSelf()
end

--hero:SetModel("models/heroes/shadow_fiend/shadow_fiend.vmdl")
--hero:SetOriginalModel("models/heroes/shadow_fiend/shadow_fiend.vmdl")

Attachments.attachDB = LoadKeyValues("scripts/attachments.txt")
prop = Attachments:AttachProp(hero, "attach_hitloc", "models/items/furion/hat_holiday_1.vmdl")


if true then
  return
end

if not asdf then
  asdf = hero:GetAbsOrigin()
else
  hero:SetAbsOrigin(asdf)
end
hero:SetPhysicsAcceleration(Vector(0,0,-3000))
--GROUND_FRICTION = .09
--AIR_DRAG = .02
GROUND_FRICTION = .01
AIR_DRAG = .001
hero:SetNavGroundAngle(25)

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