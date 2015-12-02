require('controloverride')
require('cameramanager')
require('projectiles')
require('notifications')

print ('[BAREBONES] barebones.lua' )

ENABLE_HERO_RESPAWN = true              -- Should the heroes automatically respawn on a timer or stay dead until manually respawned
UNIVERSAL_SHOP_MODE = false             -- Should the main shop contain Secret Shop items as well as regular items
ALLOW_SAME_HERO_SELECTION = true        -- Should we let people select the same hero as each other

HERO_SELECTION_TIME = 30.0              -- How long should we let people select their hero?
PRE_GAME_TIME = 5.0                    -- How long after people select their heroes should the horn blow and the game start?
POST_GAME_TIME = 60.0                   -- How long should we let people look at the scoreboard before closing the server automatically?
TREE_REGROW_TIME = 60.0                 -- How long should it take individual trees to respawn after being cut down/destroyed?

GOLD_PER_TICK = 0                     -- How much gold should players get per tick?
GOLD_TICK_TIME = 5                      -- How long should we wait in seconds between gold ticks?

RECOMMENDED_BUILDS_DISABLED = false     -- Should we disable the recommened builds for heroes (Note: this is not working currently I believe)
CAMERA_DISTANCE_OVERRIDE = 1134.0        -- How far out should we allow the camera to go?  1134 is the default in Dota

MINIMAP_ICON_SIZE = 1                   -- What icon size should we use for our heroes?
MINIMAP_CREEP_ICON_SIZE = 1             -- What icon size should we use for creeps?
MINIMAP_RUNE_ICON_SIZE = 1              -- What icon size should we use for runes?

RUNE_SPAWN_TIME = 120                    -- How long in seconds should we wait between rune spawns?
CUSTOM_BUYBACK_COST_ENABLED = true      -- Should we use a custom buyback cost setting?
CUSTOM_BUYBACK_COOLDOWN_ENABLED = true  -- Should we use a custom buyback time?
BUYBACK_ENABLED = false                 -- Should we allow people to buyback when they die?

DISABLE_FOG_OF_WAR_ENTIRELY = true      -- Should we disable fog of war entirely for both teams?
--USE_STANDARD_DOTA_BOT_THINKING = false  -- Should we have bots act like they would in Dota? (This requires 3 lanes, normal items, etc)
USE_STANDARD_HERO_GOLD_BOUNTY = true    -- Should we give gold for hero kills the same as in Dota, or allow those values to be changed?

USE_CUSTOM_TOP_BAR_VALUES = true        -- Should we do customized top bar values or use the default kill count per team?
TOP_BAR_VISIBLE = true                  -- Should we display the top bar score/count at all?
SHOW_KILLS_ON_TOPBAR = true             -- Should we display kills only on the top bar? (No denies, suicides, kills by neutrals)  Requires USE_CUSTOM_TOP_BAR_VALUES

ENABLE_TOWER_BACKDOOR_PROTECTION = false-- Should we enable backdoor protection for our towers?
REMOVE_ILLUSIONS_ON_DEATH = false       -- Should we remove all illusions if the main hero dies?
DISABLE_GOLD_SOUNDS = false             -- Should we disable the gold sound when players get gold?

END_GAME_ON_KILLS = true                -- Should the game end after a certain number of kills?
KILLS_TO_END_GAME_FOR_TEAM = 200         -- How many kills for a team should signify an end of game?

USE_CUSTOM_HERO_LEVELS = true           -- Should we allow heroes to have custom levels?
MAX_LEVEL = 50                          -- What level should we let heroes get to?
USE_CUSTOM_XP_VALUES = true             -- Should we use custom XP values to level up heroes, or the default Dota numbers?

-- Fill this table up with the required XP per level if you want to change it
XP_PER_LEVEL_TABLE = {}
for i=1,MAX_LEVEL do
  XP_PER_LEVEL_TABLE[i] = i * 100
end

KILL_POINTS = 10
FLAG_POINTS = 35

-- Generated from template
if GameMode == nil then
    print ( '[BAREBONES] creating barebones game mode' )
    GameMode = class({})
end


--[[
  This function should be used to set up Async precache calls at the beginning of the game.  The Precache() function 
  in addon_game_mode.lua used to and may still sometimes have issues with client's appropriately precaching stuff.
  If this occurs it causes the client to never precache things configured in that block.

  In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.  These calls will be made
  after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
  be used to precache dynamically-added datadriven abilities instead of items.  PrecacheUnitByNameAsync will 
  precache the precache{} block statement of the unit and all precache{} block statements for every Ability# 
  defined on the unit.

  This function should only be called once.  If you want to/need to precache more items/abilities/units at a later
  time, you can call the functions individually (for example if you want to precache units in a new wave of
  holdout).
]]
function GameMode:PostLoadPrecache()
  print("[BAREBONES] Performing Post-Load precache")    
  --PrecacheItemByNameAsync("item_example_item", function(...) end)
  --PrecacheItemByNameAsync("example_ability", function(...) end)

  PrecacheUnitByNameAsync("npc_dota_hero_viper", function(...) end)
  PrecacheUnitByNameAsync("npc_dota_hero_enigma", function(...) end)
  --PrecacheUnitByNameAsync("npc_precache_everything", function(...) end)
end

--[[
  This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
  It can be used to initialize state that isn't initializeable in InitGameMode() but needs to be done before everyone loads in.
]]

shottime = 0.4
shotspeed = 3000
shotdamage = 20
shotradius = 100
wall = PROJECTILES_DESTROY
ground = PROJECTILES_DESTROY
tree = PROJECTILES_DESTROY
GRAVITY = 1200 --600
GROUND_FRICTION = .09
SLOPE_ANGLE = 45
AIR_DRAG = .02
FORWARD_OFFSET = 0 --200

function GameMode:Sota_Aim(msg)
  local pid = msg.PlayerID
  if not pid then return end

  local player = PlayerResource:GetPlayer(pid)
  local lookat = nil
  local dir = nil
  local hero = player:GetAssignedHero()

  if msg.x then
    lookat = Vector(msg.x, msg.y, msg.z)

    --DebugDrawCircle(lookat, Vector(0,255,0), 1, 10, true, .01)  
    dir = (lookat - (hero:GetAbsOrigin() + hero.shotOffset)):Normalized()
    local ang = player:GetAngles()
    local pfor = RotatePosition(Vector(0,0,0), QAngle(0, ang.y,0), Vector(1,0,0))
    if dir:Dot(pfor) < 0 then
      dir = RotatePosition(Vector(0,0,0), QAngle(ang.x - 18,ang.y,0), Vector(1,0,0))
      msg.index = nil
    end
  end
  if msg.index then
    local target = EntIndexToHScript(msg.index)
    if target then
      local height = target.height
      if height then 
        height = height / 2
      else
        height = 80
      end

      local torg = target:GetAbsOrigin() + Vector(0,0,height)
      local d = (torg - (hero:GetAbsOrigin() + hero.shotOffset)):Normalized()
      d = VectorToAngles(d)

      local ang = player:GetAngles()

      local tdir = RotatePosition(Vector(0,0,0), QAngle(d.x,ang.y,0), Vector(1,0,0))
      if not dir or VectorDistanceSq(lookat,torg) > 900 * 900 then
        dir = tdir
      end
    end
  end
  

  --print("lookat: ", lookat)
  --print(player:GetAngles(), player:GetAnglesAsVector())
  

  
  if dir == nil then
    local ang = player:GetAngles()
    dir = RotatePosition(Vector(0,0,0), QAngle(ang.x - 18,ang.y,0), Vector(1,0,0))
  end

  local ang = hero:GetAngles()
  --hero:SetAngles(ang.x, yaw, ang.z)
  hero:SetForwardVector(Vector(dir.x, dir.y, 0))

  --local forward = hero:GetForwardVector()
  --hero.camera:SetAbsOrigin(hero:GetAbsOrigin() + forward * FORWARD_OFFSET)

  --hero.aim = RotatePosition(Vector(0,0,0), QAngle(pitch - hero.aimPitchOffset,yaw,0), Vector(1,0,0))
  hero.aim = dir
  if hero.useReticle then
    local aimpos = hero:GetAbsOrigin() + hero.aim * hero.reticleDistance + hero.reticleOffset
    hero.reticle:SetAbsOrigin(aimpos)
  end
end

function GameMode:Sota_Set_Setting(msg)
  local pid = msg.PlayerID
  local name = msg.name
  local value = msg.value

  if name == "score_max" then
    KILLS_TO_END_GAME_FOR_TEAM = value
    CustomNetTables:SetTableValue("sotaui", "score_max", {value=KILLS_TO_END_GAME_FOR_TEAM})
  end
end

function GameMode:OnFirstPlayerLoaded()
  print("[BAREBONES] First Player has loaded")

  local mode = GameRules:GetGameModeEntity()
  --[[mode:SetHUDVisible(0,  false) --Clock
  mode:SetHUDVisible(1,  false)
  mode:SetHUDVisible(2,  false)
  mode:SetHUDVisible(6,  false)
  mode:SetHUDVisible(7,  false) 
  mode:SetHUDVisible(8,  false) 
  mode:SetHUDVisible(9,  false)
  mode:SetHUDVisible(11, false)
  mode:SetHUDVisible(12, false)

  mode:SetHUDVisible(3,  false) --Action Panel
  mode:SetHUDVisible(4,  false) --Minimap
  mode:SetHUDVisible(5,  false) --Inventory]]

  CustomNetTables:SetTableValue("sotaui", "radiant_score", {value=0})
  CustomNetTables:SetTableValue("sotaui", "dire_score", {value=0})
  CustomNetTables:SetTableValue("sotaui", "score_max", {value=KILLS_TO_END_GAME_FOR_TEAM})

  --allegiance stuff
  local allegiances = {[DOTA_TEAM_GOODGUYS] = 1,
                       [DOTA_TEAM_BADGUYS] = 2,
                       [DOTA_TEAM_CUSTOM_1] = 1,
                       [DOTA_TEAM_CUSTOM_2] = 2,
                       [DOTA_TEAM_CUSTOM_3] = 1,
                       [DOTA_TEAM_CUSTOM_4] = 2,
                       [DOTA_TEAM_CUSTOM_5] = 1,
                       [DOTA_TEAM_CUSTOM_6] = 2,
                       [DOTA_TEAM_CUSTOM_7] = 1,
                       [DOTA_TEAM_CUSTOM_8] = 2}

  function GameRules:GetPlayerID(p)
    if type(p) == "number" then
      return p
    elseif IsValidEntity(p) and p.GetPlayerID ~= nil then
      return p:GetPlayerID()
    elseif IsValidEntity(p) and p.GetPlayerOwner ~= nil then
      return p:GetPlayerOwner():GetPlayerID()
    end

    return nil
  end

  function GameRules:IsAlly(p1, p2)
    return allegiances[GameRules:GetPlayerID(p1)] == allegiances[GameRules:GetPlayerID(p2)]
  end

  function GameRules:IsEnemy(p1, p2)
    return not GameRules:IsAlly(p1, p2)
  end

  function GameRules:LerpCamera(hero, force)
    local time = force / GRAVITY
    local count = time * 60
    local height = force / 2 * time
    local step = height / count * 1.5
    CameraManager:LerpProperty(hero:GetPlayerID(),CAMERA_DISTANCE,nil,count ,step)

    if hero.lerpTimer then
      Timers:RemoveTimer(hero.lerpTimer)
    end
    hero.lerpTimer = Timers:CreateTimer(time, function()
      CameraManager:LerpProperty(hero:GetPlayerID(),CAMERA_DISTANCE,hero.baseCameraDistance ,count*2 , 0)---1*step)
    end)
  end


  local broadcastersCreated = {}

  Convars:RegisterCommand('sota_hero_selected', function(command, heroName)
    local cmdPlayer = Convars:GetCommandClient()
    print("sota_hero_selected")
    print(cmdPlayer:GetPlayerID())
    print(heroName)
    local playerID = cmdPlayer:GetPlayerID()

    if (PlayerResource:IsBroadcaster(playerID) or playerID >= 10) and broadcastersCreated[playerID] == nil then
      broadcastersCreated[playerID] = true

      --precache and create
      PrecacheUnitByNameAsync(heroName, function(...) 
        Timers:CreateTimer(1, function() CreateHeroForPlayer(heroName, cmdPlayer) end)
      end)
    end
  end, 'hero selected', 0)

  ControlOverride:KeyDownHandler(function(player, keycode, ctrl, shift, alt)
    local hero = player:GetAssignedHero()
    if keycode == KEY_W then
      hero.up = true
    elseif keycode == KEY_S then
      hero.down = true
    elseif keycode == KEY_A then
      hero.left = true
    elseif keycode == KEY_D then
      hero.right = true
    elseif keycode == KEY_SHIFT then
      hero:OnMovementSkillKeyDown()
    elseif keycode == KEY_R then
      hero:OnReloadWeapon()
    elseif keycode == KEY_1 then
      hero:OnSwitchWeapon(1)
    elseif keycode == KEY_2 then
      hero:OnSwitchWeapon(2)
    elseif keycode == KEY_3 then
      hero:OnSwitchWeapon(3)
    elseif keycode == KEY_4 then
      hero:OnSwitchWeapon(4)
    elseif keycode == KEY_5 then
      hero:OnSwitchWeapon(5)
    elseif keycode == KEY_6 then
      hero:OnSwitchWeapon(6)
    elseif keycode == KEY_SPACE then
      -- local gametime = GameRules:GetGameTime()

      if not hero:IsAlive() or hero.jumps <= 0 then --or (hero.lastShift ~= nil and hero.lastShift + .75 > gametime) then
        return
      end

      --hero.lastShift = gametime
      local vel = hero:GetPhysicsVelocity()

      if vel.z > hero.jumpSpeed then
        return
      end

      hero.jumps = hero.jumps - 1
      hero:SetPhysicsVelocity(Vector(vel.x,vel.y, hero.jumpSpeed))

      --GameRules:LerpCamera(hero, hero.jumpSpeed)

      hero:OnJump()
    end
  end)

  ControlOverride:KeyUpHandler(function(player, keycode, ctrl, shift, alt)
    local hero = player:GetAssignedHero()
    if keycode == KEY_W then
      hero.up = false
    elseif keycode == KEY_S then
      hero.down = false
    elseif keycode == KEY_A then
      hero.left = false
    elseif keycode == KEY_D then
      hero.right = false
    elseif keycode == KEY_SHIFT then
      hero:OnMovementSkillKeyUp()
    end
  end)

  ControlOverride:MouseDownHandler(function(player, leftClick)
    if not leftClick then
      CameraManager:SendConfig(player:GetPlayerID(), false)
      return
    end

    local hero = player:GetAssignedHero()
    hero:OnLeftClickDown()
  end)

  ControlOverride:MouseUpHandler(function(player, leftClick)
    if not leftClick then
      CameraManager:SendConfig(player:GetPlayerID(), true)
      return
    end

    local hero = player:GetAssignedHero()
    hero:OnLeftClickUp()
  end)

  CustomGameEventManager:RegisterListener("Sota_Aim", Dynamic_Wrap(GameMode, "Sota_Aim"))
  CustomGameEventManager:RegisterListener("Sota_Set_Setting", Dynamic_Wrap(GameMode, "Sota_Set_Setting"))

  CameraManager:CameraRotateHandler(function(player, yaw, pitch)
    print('camang: ' .. player:GetPlayerID(), yaw, pitch)
    print(player:GetAngles())
    local hero = player:GetAssignedHero()
    local ang = hero:GetAngles()
    hero:SetAngles(ang.x, yaw, ang.z)

    --local forward = hero:GetForwardVector()
    --hero.camera:SetAbsOrigin(hero:GetAbsOrigin() + forward * FORWARD_OFFSET)

    --[[hero.aim = RotatePosition(Vector(0,0,0), QAngle(pitch - hero.aimPitchOffset,yaw,0), Vector(1,0,0))
    if hero.useReticle then
      local aimpos = hero:GetAbsOrigin() + hero.aim * hero.reticleDistance + hero.reticleOffset
      hero.reticle:SetAbsOrigin(aimpos)
    end]]
  end)

  
  
  --[[local powerUps = Entities:FindAllByClassname("npc_dota_creature")
  for i=1,#powerUps do
    local pUp = powerUps[i]
    pUp.active = true
    print(pUp:Attribute_GetFloatValue("respawn", .9))
    pUp:SetForwardVector(RandomVector(1))

    pUp.particle = ParticleManager:CreateParticle("particles/test_particle/" .. pUp:GetUnitName() .. ".vpcf", PATTACH_ABSORIGIN_FOLLOW, pUp)
    ParticleManager:SetParticleControl(pUp.particle, 2, Vector(pUp:Attribute_GetFloatValue("scale", 1.0), 0, 0))
  end
  Timers:CreateTimer(function()
    for i=1,#powerUps do
      local pUp = powerUps[i]
      local forward = RotatePosition(Vector(0,0,0), QAngle(0,6,0), pUp:GetForwardVector())

      pUp:SetForwardVector(forward)
    end
    return .03
  end)]]


  -- ammo timer
  --[[local previousObj = {}
  local previousObj1 = {}
  local previousObj2 = {}
  local previousObj3 = {}
  Timers:CreateTimer(function()
    local obj = {}
    for i=0,9 do
      local player = PlayerResource:GetPlayer(i)
      local hero = nil
      if player then
        hero = player:GetAssignedHero()
      end
      if hero and hero.weapon and hero.weapon.usesAmmo and hero.weapon.ammo then
        obj['p' .. i] = hero.weapon.ammo
        obj['p' .. i .. 'reserve'] = hero.weapon.ammoReserve
      else
        obj['p' .. i] = -1
        obj['p' .. i .. 'reserve'] = -1
      end
    end

    local equal = true
    for k,v in pairs(obj) do
      if previousObj[k] ~= v then
        equal = false
        break
      end
    end
    if not equal then
      FireGameEvent('ammo_update', obj)
    end

    previousObj = obj

    return .1
  end)]]

  local previousObj = {}
  Timers:CreateTimer(function()
    local obj = {}
    for i=0,31 do
      local player = PlayerResource:GetPlayer(i)
      local hero = nil
      if player then
        hero = player:GetAssignedHero()
      end
      if hero and hero.weapon and hero.weapon.usesAmmo and hero.weapon.ammo then
        obj['p' .. i] = hero.weapon.ammo
        obj['p' .. i .. 'reserve'] = hero.weapon.ammoReserve
      else
        obj['p' .. i] = -1
        obj['p' .. i .. 'reserve'] = -1
      end

      if previousObj['p' .. i] ~= obj['p' .. i] or previousObj['p' .. i .. 'reserve'] ~= obj['p' .. i .. 'reserve'] then
        FireGameEvent('ammo_update_pid', {pid=i, ammo=obj['p' .. i], reserve=obj['p' .. i .. 'reserve']})
      end
    end

    previousObj = obj
    return .1
  end)

  GameRules.touchFilter = {}
  local ents = Entities:FindAllByClassname("npc_dota_creature")
  for i=1,#ents do
    GameRules.touchFilter[ents[i]:entindex()] = ents[i]
  end


  local globalUnit = CreateUnitByName('npc_dummy_unit', Vector(0,0,0), true, nil, nil, DOTA_TEAM_NOTEAM)
  globalUnit:AddAbility("modifier_applier")
  GameRules.ModApplier = globalUnit:FindAbilityByName("modifier_applier")
  GameRules.ModApplier:SetLevel(1)
  ApplyModifier(globalUnit, globalUnit, "no_health_bar", {})

  GameRules.radiantFlagSpawn = Entities:FindByName(nil, 'GOOD_FLAG_SPAWN')
  if GameRules.radiantFlagSpawn then
    GameRules.radiantFlag = CreateUnitByName('radiant_flag', GameRules.radiantFlagSpawn:GetAbsOrigin(), false, nil, nil, DOTA_TEAM_NOTEAM)
    GameRules.radiantFlag.dodgeProjectiles = true
    GameRules.radiantFlag.grabbable = true
    GameRules.radiantFlag.active = true
    GameRules.radiantFlag:SetForwardVector(GameRules.radiantFlagSpawn:GetForwardVector())

    GameRules.touchFilter[GameRules.radiantFlag:entindex()] = GameRules.radiantFlag
  end

  GameRules.direFlagSpawn = Entities:FindByName(nil, 'BAD_FLAG_SPAWN')
  if GameRules.direFlagSpawn then
    GameRules.direFlag = CreateUnitByName('dire_flag', GameRules.direFlagSpawn:GetAbsOrigin(), false, nil, nil, DOTA_TEAM_NOTEAM)
    GameRules.direFlag.dodgeProjectiles = true
    GameRules.direFlag.grabbable = true
    GameRules.direFlag.active = true
    GameRules.direFlag:SetForwardVector(GameRules.direFlagSpawn:GetForwardVector())
    
    GameRules.touchFilter[GameRules.direFlag:entindex()] = GameRules.direFlag
  end

  
end

--[[
  This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
  It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]

function GameMode:OnAllPlayersLoaded()
  print("[BAREBONES] All Players have loaded into the game")
  GameMode:DrawPowerups()
end

function GameMode:DrawPowerups()
  GameMode.powerupsDrawn = true
  local powerUps = Entities:FindAllByClassname("npc_dota_creature")
  for i=1,#powerUps do
    local pUp = powerUps[i]
    if pUp.dodgeProjectiles == nil then
      -- first run
      pUp.active = true
      print(pUp:GetUnitName() .. ' -- ' .. pUp:Attribute_GetFloatValue("respawn", .9))
      pUp:SetForwardVector(RandomVector(1))
      pUp.dodgeProjectiles = true

      pUp.particle = ParticleManager:CreateParticle("particles/test_particle/" .. pUp:GetUnitName() .. ".vpcf", PATTACH_ABSORIGIN_FOLLOW, pUp)
      ParticleManager:SetParticleControl(pUp.particle, 2, Vector(pUp:Attribute_GetFloatValue("scale", 1.0), 0, 0))
    else
      if pUp.particle then
        ParticleManager:DestroyParticle(pUp.particle, true)
      end
      pUp.particle = ParticleManager:CreateParticle("particles/test_particle/" .. pUp:GetUnitName() .. ".vpcf", PATTACH_ABSORIGIN_FOLLOW, pUp)
      
      if pUp.active then
        ParticleManager:SetParticleControl(pUp.particle, 2, Vector(pUp:Attribute_GetFloatValue("scale", 1.0), 0, 0))
      else
        ParticleManager:SetParticleControl(pUp.particle, 2, Vector(pUp:Attribute_GetFloatValue("smallScale", .4), 0, 0))
      end
    end
  end
end

--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.

  The hero parameter is the hero entity that just spawned in
]]

direCount = 0
radiantCount = 0

function GameMode:OnHeroInGame(hero)
  print("[BAREBONES] Hero spawned in game for first time -- " .. hero:GetUnitName())

  if GameRules:IsAlly(hero:GetTeam(), DOTA_TEAM_GOODGUYS) then
    radiantCount = radiantCount + 1
  end

  if GameRules:IsAlly(hero:GetTeam(), DOTA_TEAM_BADGUYS) then
    direCount = direCount + 1
  end

  --KILLS_TO_END_GAME_FOR_TEAM = math.max(radiantCount, direCount) * 10  
  KILL_POINTS = math.ceil(10/math.max(radiantCount, direCount))

  hero:SetGold(0,true)
  hero:SetGold(0,false)

  -- remove some weird phantom abilities
  local ents = Entities:FindAllInSphere(hero:GetAbsOrigin(), 300)
  for i=1,#ents do
    local ent = ents[i]
    if ent:GetClassname() == "dota_base_ability" then
      --ent:RemoveSelf()
    end
  end

  hero.up = false
  hero.down = false
  hero.left = false
  hero.right = false
  hero.jumps = 2

  local pid = hero:GetPlayerID()
  Timers:CreateTimer(1, function()
    print('hero created, pid', pid, hero:GetPlayerID())
    --Notifications:Bottom(pid, {text="Left click your Enigma unit to begin!", duration=10, style={["font-size"]="40px"}})

    Notifications:Bottom(pid, {text="Use ", duration=4}) 
    Notifications:Bottom(pid, {image="file://{images}/custom_game/loading_screen/wasd.png", duration=4, continue=true})
    Notifications:Bottom(pid, {text="  to move!", duration=4, continue=true}) 
    Timers:CreateTimer(4, function() 
      Notifications:Bottom(pid, {text="Use ", duration=4}) 
      Notifications:Bottom(pid, {image="file://{images}/custom_game/loading_screen/leftclick.png", duration=4, continue=true})
      Notifications:Bottom(pid, {text="  to shoot!", duration=4, continue=true}) 
    end)
    Timers:CreateTimer(8, function() 
      Notifications:Bottom(pid, {text="Press ", duration=4}) 
      Notifications:Bottom(pid, {image="file://{images}/custom_game/loading_screen/space.png", duration=4, continue=true})
      Notifications:Bottom(pid, {text="  to Jump! Press again to double/triple jump!", duration=4, continue=true}) 
    end)
    Timers:CreateTimer(12, function() 
      Notifications:Bottom(pid, {text="Press ", duration=4}) 
      Notifications:Bottom(pid, {image="file://{images}/custom_game/loading_screen/shift.png", duration=4, continue=true})
      Notifications:Bottom(pid, {text="  to use your hero's Movement ability!", duration=4, continue=true}) 
    end)
    Timers:CreateTimer(16, function() 
      Notifications:Bottom(pid, {image="file://{images}/custom_game/loading_screen/rightclick.png", duration=4})
      Notifications:Bottom(pid, {text="  when you can't turn any more!", duration=4, continue=true}) 
    end)
    Timers:CreateTimer(20, function() 
      Notifications:Bottom(pid, {text="Use ", duration=4}) 
      Notifications:Bottom(pid, {image="file://{images}/custom_game/loading_screen/1key.png", duration=4, continue=true})
      Notifications:Bottom(pid, {image="file://{images}/custom_game/loading_screen/2key.png", duration=4, continue=true})
      Notifications:Bottom(pid, {image="file://{images}/custom_game/loading_screen/3key.png", duration=4, continue=true})
      Notifications:Bottom(pid, {text="  to switch weapons!", duration=4, continue=true}) 
    end)
    Timers:CreateTimer(24, function() 
      Notifications:Bottom(pid, {text="Use ", duration=4}) 
      Notifications:Bottom(pid, {image="file://{images}/custom_game/loading_screen/rkey.png", duration=4, continue=true})
      Notifications:Bottom(pid, {text="  to reload your weapon!", duration=4, continue=true}) 
    end)
    Timers:CreateTimer(28, function() 
      Notifications:Bottom(pid, {text="Wheel ", duration=4}) 
      Notifications:Bottom(pid, {image="file://{images}/custom_game/loading_screen/wheel.png", duration=4, continue=true})
      Notifications:Bottom(pid, {text="  to adjust camera height!", duration=4, continue=true}) 
    end)
  end)

  if PlayerResource:IsBroadcaster(pid) or pid >= 10 then
    --broadcaster player
    --FireGameEvent("sota_set_hero_index", {pid=pid, index=hero:entindex()})
  end

  --ControlOverride:SendCvar(pid, "dota_render_crop_height", "0") -- Renders the bottom part of the screen
  ControlOverride:SendCvar(pid, "dota_camera_z_interp_speed", "0")
  ControlOverride:SendCvar(pid, "dota_camera_disable_zoom", "1")
  ControlOverride:SendCvar(pid, "dota_camera_lock_lerp", "0")

  ControlOverride:SendConfig(pid, false, false, false, true)
  ControlOverride:SendKeyFilter(pid, {KEY_W, KEY_S, KEY_A, KEY_D, KEY_SPACE, KEY_SHIFT,
                                      KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6,
                                      KEY_R, KEY_B, KEY_F1})

  Physics:Unit(hero)
  hero:Stop()
  hero:SetPhysicsFriction(GROUND_FRICTION)
  hero:Hibernate(false)
  hero:FollowNavMesh(false)
  hero:SetNavGroundAngle(SLOPE_ANGLE)
  hero:AdaptiveNavGridLookahead(true)
  hero:SetAutoUnstuck(false)
  hero:SetPhysicsAcceleration(Vector(0,0,-1 * GRAVITY))

  hero:CutTrees(false)
  hero:SetStuckTimeout(600)
  hero:SetVelocityClamp(0)
  hero:SetNavCollisionType(PHYSICS_NAV_GROUND)
  hero:SetGroundBehavior(PHYSICS_GROUND_ABOVE)
  hero:SetBoundOverride(1)

  --hero:AddNewModifier(hero, nil, "modifier_ember_spirit_searing_chains", {})
  ApplyModifier(hero, hero, "no_health_bar", {})
  ApplyModifier(hero, hero, "rooted", {})

  print("hero stuff")
  --[[Timers:CreateTimer(.5, function()
    if hero:GetClassname() == "npc_dota_hero_nevermore" then
      --return
    end


    hero.camera = CreateUnitByName('npc_dummy_unit', hero:GetAbsOrigin() + (Vector(0,0,0) - hero:GetAbsOrigin()):Normalized() * 250, true, hero, hero, hero:GetTeamNumber())
    --hero.camera:FindAbilityByName("reflex_dummy_unit"):SetLevel(0)
    hero.camera:SetModel('models/heroes/enigma/enigma.vmdl')
    hero.camera:SetOriginalModel('models/heroes/enigma/enigma.vmdl');
    hero.camera:SetModelScale(.5)
    
    Timers:CreateTimer(.5, function()
      hero.camera:SetOwner(hero)
      hero.camera:SetControllableByPlayer(hero:GetPlayerID(), true)
    end)
    --Physics:Unit(hero.camera)
    print("CAMERA CREATED")
  end)]]



  hero.collider = hero:AddColliderFromProfile("blocker")
  hero.collider.radius = 80
  hero.collider.filter = GameRules.touchFilter
  hero.collider.test = function(self, collider, collided) return hero:IsAlive() and collided.active; end
  hero.collider.action = function(self, unit, v)
    if v:GetUnitName() == "radiant_flag" and v.grabbable then
      if GameRules:IsAlly(hero:GetTeam(), DOTA_TEAM_BADGUYS) then
        -- pick up flag
        FireGameEvent("show_center_message", {message="Radiant Flag Picked Up!", duration=2.9})
        v.particle = ParticleManager:CreateParticle( "particles/test_particle/flag.vpcf", PATTACH_ABSORIGIN_FOLLOW, v)
        ParticleManager:SetParticleControl(v.particle, 1, Vector( 55, 55, 255 ) )
        print('radiant flag picked up')
        v.grabbable = false
        ApplyModifier(hero,hero, 'mana_regen_reduced', {})

        EmitAnnouncerSoundForTeam("announcer_ann_custom_ctf_10", DOTA_TEAM_GOODGUYS)
        EmitAnnouncerSoundForTeam("announcer_ann_custom_ctf_16", DOTA_TEAM_BADGUYS)
        GameMode:PlayTeamSound('SOTA.FlagFail', 'SOTA.FlagSuccess')

        Timers:CreateTimer(function()
          if not IsValidEntity(hero) or not hero:IsAlive() then
            --Drop flag
            print("dropping radiant flag")
            v.grabbable = true
            local groundpos = GetGroundPosition(v:GetAbsOrigin(),v)
            v:SetAbsOrigin(groundpos)

            if v.flagReturnTimer then Timers:RemoveTimer(v.flagReturnTimer) end
            v.flagReturnTimer = Timers:CreateTimer(10, function()
              if v.grabbable and v:GetAbsOrigin() ~= GameRules.radiantFlagSpawn:GetAbsOrigin() then
                print("drop flag timeout, returning flag")
                FireGameEvent("show_center_message", {message="Radiant Flag Returned!", duration=2.9})
                GameMode:PlayTeamSound('SOTA.FlagSuccess', 'SOTA.FlagFail')

                if v.particle then
                  ParticleManager:DestroyParticle(v.particle, true)
                  v.particle = nil
                end
                v:SetAbsOrigin(GameRules.radiantFlagSpawn:GetAbsOrigin())
                v:SetForwardVector(GameRules.radiantFlagSpawn:GetForwardVector())
              end
            end)

            return
          end

          if GameRules.direFlag:GetAbsOrigin() == GameRules.direFlagSpawn:GetAbsOrigin() and VectorDistanceSq(v:GetAbsOrigin(), GameRules.direFlagSpawn:GetAbsOrigin()) < 100*100 then
            -- touching flag cap
            print('radiant flag captured')
            FireGameEvent("show_center_message", {message="Radiant Flag CAPTURED!", duration=2.9})
            v.grabbable = true
            if v.particle then
              ParticleManager:DestroyParticle(v.particle, true)
              v.particle = nil
            end
            v:SetAbsOrigin(GameRules.radiantFlagSpawn:GetAbsOrigin())
            v:SetForwardVector(GameRules.radiantFlagSpawn:GetForwardVector())
            hero:RemoveModifierByName('mana_regen_reduced')

            EmitAnnouncerSoundForTeam("announcer_ann_custom_ctf_09", DOTA_TEAM_GOODGUYS)
            EmitAnnouncerSoundForTeam("announcer_ann_custom_ctf_14", DOTA_TEAM_BADGUYS)
            GameMode:PlayTeamSound('SOTA.FlagCaptureBad', 'SOTA.FlagCaptureGood')

            GameMode.nDireKills = GameMode.nDireKills + FLAG_POINTS
            if SHOW_KILLS_ON_TOPBAR then
              CustomNetTables:SetTableValue("sotaui", "radiant_score", {value=GameMode.nRadiantKills})
              CustomNetTables:SetTableValue("sotaui", "dire_score", {value=GameMode.nDireKills})
            end

            if END_GAME_ON_KILLS and GameMode.nDireKills >= KILLS_TO_END_GAME_FOR_TEAM then
              GameRules:SetSafeToLeave( true )
              GameRules:SetGameWinner( DOTA_TEAM_BADGUYS )
              ControlOverride:SendConfigToAll(false, false, false, true)
              CameraManager:SendConfigToAll(false)
            end
            return
          end

          v:SetAbsOrigin(hero:GetAbsOrigin())
          v:SetForwardVector(hero:GetForwardVector())
          return .03
        end)

      elseif v:GetAbsOrigin() ~= GameRules.radiantFlagSpawn:GetAbsOrigin() then
        -- return flag
        FireGameEvent("show_center_message", {message="Radiant Flag Returned!", duration=2.9})
        GameMode:PlayTeamSound('SOTA.FlagSuccess', 'SOTA.FlagFail')

        if v.particle then
          ParticleManager:DestroyParticle(v.particle, true)
          v.particle = nil
        end
        v:SetAbsOrigin(GameRules.radiantFlagSpawn:GetAbsOrigin())
        v:SetForwardVector(GameRules.radiantFlagSpawn:GetForwardVector())

      end
    elseif v:GetUnitName() == "dire_flag" and v.grabbable then
      if GameRules:IsAlly(hero:GetTeam(), DOTA_TEAM_GOODGUYS) then
        -- pick up flag
        print('dire flag picked up')
        FireGameEvent("show_center_message", {message="Dire Flag Picked Up!", duration=2.9})
        v.particle = ParticleManager:CreateParticle( "particles/test_particle/flag.vpcf", PATTACH_ABSORIGIN_FOLLOW, v)
        ParticleManager:SetParticleControl(v.particle, 1, Vector( 255, 55, 55 ) )
        v.grabbable = false
        ApplyModifier(hero,hero, 'mana_regen_reduced', {})

        EmitAnnouncerSoundForTeam("announcer_ann_custom_ctf_16", DOTA_TEAM_GOODGUYS)
        EmitAnnouncerSoundForTeam("announcer_ann_custom_ctf_10", DOTA_TEAM_BADGUYS)
        GameMode:PlayTeamSound('SOTA.FlagSuccess', 'SOTA.FlagFail')

        Timers:CreateTimer(function()
          if not IsValidEntity(hero) or not hero:IsAlive() then
            --Drop flag
            print("dropping dire flag")
            v.grabbable = true
            local groundpos = GetGroundPosition(v:GetAbsOrigin(),v)
            v:SetAbsOrigin(groundpos)

            if v.flagReturnTimer then Timers:RemoveTimer(v.flagReturnTimer) end
            v.flagReturnTimer = Timers:CreateTimer(10, function()
              if v.grabbable and v:GetAbsOrigin() ~= GameRules.direFlagSpawn:GetAbsOrigin() then
                print("drop flag timeout, returning flag")
                FireGameEvent("show_center_message", {message="Dire Flag Returned!", duration=2.9})
                GameMode:PlayTeamSound('SOTA.FlagFail', 'SOTA.FlagSuccess')

                if v.particle then
                  ParticleManager:DestroyParticle(v.particle, true)
                  v.particle = nil
                end
                v:SetAbsOrigin(GameRules.direFlagSpawn:GetAbsOrigin())
                v:SetForwardVector(GameRules.direFlagSpawn:GetForwardVector())
              end
            end)
            
            return
          end

          if GameRules.radiantFlag:GetAbsOrigin() == GameRules.radiantFlagSpawn:GetAbsOrigin() and VectorDistanceSq(v:GetAbsOrigin(), GameRules.radiantFlagSpawn:GetAbsOrigin()) < 100*100 then
            -- touching flag cap
            print('dire flag captured')
            FireGameEvent("show_center_message", {message="Dire Flag CAPTURED!", duration=2.9})
            v.grabbable = true
            if v.particle then
              ParticleManager:DestroyParticle(v.particle, true)
              v.particle = nil
            end
            v:SetAbsOrigin(GameRules.direFlagSpawn:GetAbsOrigin())
            v:SetForwardVector(GameRules.direFlagSpawn:GetForwardVector())
            hero:RemoveModifierByName('mana_regen_reduced')

            EmitAnnouncerSoundForTeam("announcer_ann_custom_ctf_14", DOTA_TEAM_GOODGUYS)
            EmitAnnouncerSoundForTeam("announcer_ann_custom_ctf_09", DOTA_TEAM_BADGUYS)
            GameMode:PlayTeamSound('SOTA.FlagCaptureGood', 'SOTA.FlagCaptureBad')

            GameMode.nRadiantKills = GameMode.nRadiantKills + FLAG_POINTS
            if SHOW_KILLS_ON_TOPBAR then
              CustomNetTables:SetTableValue("sotaui", "radiant_score", {value=GameMode.nRadiantKills})
              CustomNetTables:SetTableValue("sotaui", "dire_score", {value=GameMode.nDireKills})
            end

            if END_GAME_ON_KILLS and GameMode.nRadiantKills >= KILLS_TO_END_GAME_FOR_TEAM then
              GameRules:SetSafeToLeave( true )
              GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )
              ControlOverride:SendConfigToAll(false, false, false, true)
              CameraManager:SendConfigToAll(false)
            end
            return
          end

          v:SetAbsOrigin(hero:GetAbsOrigin())
          v:SetForwardVector(hero:GetForwardVector())
          return .03
        end)

      elseif v:GetAbsOrigin() ~= GameRules.direFlagSpawn:GetAbsOrigin() then
        -- return flag
        FireGameEvent("show_center_message", {message="Dire Flag Returned!", duration=2.9})
        GameMode:PlayTeamSound('SOTA.FlagFail', 'SOTA.FlagSuccess')

        if v.particle then
          ParticleManager:DestroyParticle(v.particle, true)
          v.particle = nil
        end
        v:SetAbsOrigin(GameRules.direFlagSpawn:GetAbsOrigin())
        v:SetForwardVector(GameRules.direFlagSpawn:GetForwardVector())
      end
    end

    if v:GetUnitName() == "radiant_flag" or v:GetUnitName() == "dire_flag" then
      return
    end

    v.active = false
    local model = v:GetModelName()
    local scale = 1.0
    local respawn = v:Attribute_GetFloatValue("respawn", 15.0)

    --v:SetModel('models/development/invisiblebox.vmdl')
    --v:SetOriginalModel('models/development/invisiblebox.vmdl')
    --v:SetModelScale(.3)
    ParticleManager:SetParticleControl(v.particle, 2, Vector(v:Attribute_GetFloatValue("smallScale", .4), 0, 0))
    

    if v:GetUnitName() == "ammo_crate" then
      for i=1,#hero.activeWeapons do
        local weapon = hero.activeWeapons[i]
        if weapon.usesAmmo then
          weapon.ammoReserve = math.min(weapon.ammoReserve + weapon.ammoPerPickup, weapon.ammoMax)
        end
      end
    elseif v:GetUnitName() == "health_pickup" then
      hero:Heal(hero.healthPickupAmount or 50, hero)
    end

    local particle = ParticleManager:CreateParticle( "particles/items2_fx/veil_of_discord.vpcf", PATTACH_CUSTOMORIGIN, v )
    ParticleManager:SetParticleControl( particle, 0, v:GetAbsOrigin() - Vector(0,0,35))
    ParticleManager:SetParticleControl( particle, 1, Vector( 35, 35, 25 ) )
    ParticleManager:ReleaseParticleIndex(particle )

    Timers:CreateTimer(respawn, function() 
      Timers:CreateTimer(.5, function() v.active = true end)
      --v:SetModel(model)
      --v:SetOriginalModel(model)
      --v:SetModelScale(scale)
      ParticleManager:SetParticleControl(v.particle, 2, Vector(v:Attribute_GetFloatValue("scale", 1.0), 0, 0))
    end)
  end

  local heroClass = string.match(hero:GetClassname(), "npc_dota_hero_(.*)")

  local heroscript = nil
  local status,ret = pcall(function()
    heroscript = require('heroes/' .. heroClass)
    if heroscript ~= nil then
      heroscript:InitializeClass(hero)
    end
  end)

  if not status then
    print("HeroScript Creation Failed: " .. heroClass .. " -- " .. ret)
  end

  if heroscript == nil then
    print('No hero script found for hero class: ' .. heroClass)
    heroscript = require('heroes/default'):InitializeClass(hero)
  end

  Timers:CreateTimer(.5, function()
    local heroList = HeroList:GetAllHeroes()
    for i=1,#heroList do
      local h = heroList[i]
      if h.renderColor and h.renderColor[h:GetTeam()] then
        local color = h.renderColor[h:GetTeam()]
        h:SetRenderColor(color.x, color.y, color.z)

        local parent = h:GetRootMoveParent()
        local children = parent:GetChildren()
        for i=1,#children do
          local child = children[i]
          if child:GetClassname() == "dota_item_wearable" then
            local color = h.renderColor[h:GetTeam()]
            child:SetRenderColor(color.x, color.y, color.z)
          end
        end
      end
    end
  end)

  Timers:CreateTimer(function()
    local pid = hero:GetPlayerID()
    ControlOverride:SendConfig(pid, true, true, false, true)
    CameraManager:SendConfig(pid, true)

    ControlOverride:SendCvar(pid, "dota_camera_edgemove", "0")
    ControlOverride:SendCvar(pid, "dota_camera_fov_max", "80")
    ControlOverride:SendCvar(pid, "dota_camera_lock", "1")
    ControlOverride:SendCvar(pid, "dota_camera_pitch_max", "35")
    ControlOverride:SendCvar(pid, "dota_camera_lock_lerp", "0")
    ControlOverride:SendCvar(pid, "r_farz", "16000")

    ControlOverride:SendCvar(pid, "dota_camera_z_interp_speed", "0")
    --ControlOverride:SendCvar(pid, "dota_camera_z_interp_speed", "3")
    --ControlOverride:SendCvar(pid, "dota_camera_smooth_enable", "0")
    --ControlOverride:SendCvar(pid, "dota_camera_smooth_distance", "0")
    --ControlOverride:SendCvar(pid, "dota_camera_smooth_count", "0")

    --[[ControlOverride:SendCvar(pid, "dota_camera_z_interp_speed", "0")
    ControlOverride:SendCvar(pid, "dota_camera_smooth_enable", "0")
    ControlOverride:SendCvar(pid, "dota_camera_smooth_distance", "0")
    ControlOverride:SendCvar(pid, "dota_camera_smooth_count", "0")]]

    CameraManager:SetProperty(pid,CAMERA_DISTANCE,hero.baseCameraDistance)

    --hero.camera:FindAbilityByName("reflex_dummy_unit"):SetLevel(1)

    hero.reticle = CreateUnitByName('npc_dummy_unit', hero:GetAbsOrigin() + (Vector(0,0,0) - hero:GetAbsOrigin()):Normalized() * 250, true, hero, hero, hero:GetTeamNumber())
    hero.reticle:FindAbilityByName("reflex_dummy_unit"):SetLevel(1)
    --hero.reticle:StopetModelScale(.5)
    hero.useReticle = false

    -- This has to be done on a delay or there's a possible user crash
    -- [EDIT] Actually, I figured out the issue is related to the mouse cursor being over the model when it changes to invisible, which has no selection box and therefore blows up 
    -- when trying to paint the ghost particle.  Usings the wisp model mgith work better, but using a modelscale of 0 works just as well.
    --hero.camera:SetModelScale(0)
    Timers:CreateTimer(.3, function()
      --hero.camera:SetModel('models/development/invisiblebox.vmdl')
      --hero.camera:SetOriginalModel('models/development/invisiblebox.vmdl');
      --hero.camera:SetModelScale(0)
      hero:Stop()
    end)

    --hero:RemoveModifierByName("modifier_ember_spirit_searing_chains")
    hero:RemoveModifierByName("rooted")
    hero:Stop()

    hero.inAir = false

    hero:OnPhysicsFrame(function()
      if hero:IsAlive() then
        local pos = hero:GetAbsOrigin()
        local ground = GetGroundPosition(pos, hero)
        if pos.z - ground.z < 2 and Physics:CalcNormal(ground,hero,10).z > hero.fNavGroundAngle then
          hero.jumps = hero.maxJumps
          hero:SetPhysicsFriction(GROUND_FRICTION)
          if hero.inAir then
            hero:OnLand(false)
          end
          hero.inAir = false
          --hero:FollowNavMesh(true)
        elseif GridNav:IsNearbyTree(pos, 30, true) and ground.z + 340 == pos.z and hero:GetPhysicsVelocity().z == 0 then
          hero.jumps = hero.maxJumps
          hero:SetPhysicsFriction(GROUND_FRICTION)
          if hero.inAir then
            hero:OnLand(true)
          end
          hero.inAir = false
        else
          hero:SetPhysicsFriction(AIR_DRAG)
          if not hero.inAir then
            hero:OnTakeOff()
          end
          hero.inAir = true
        end

        local forward = hero:GetForwardVector()
        --hero.camera:SetAbsOrigin(hero:GetAbsOrigin() + forward * FORWARD_OFFSET)


        if hero.useReticle and not hero.laserParticle then
          hero.laserParticle = ParticleManager:CreateParticleForPlayer("particles/basic_rope/basic_rope.vpcf", PATTACH_POINT, hero, PlayerResource:GetPlayer(pid))
          ParticleManager:SetParticleControlEnt(hero.laserParticle, 0, hero, PATTACH_POINT_FOLLOW, "attach_attack1", hero:GetAbsOrigin(), true)
          ParticleManager:SetParticleControlEnt(hero.laserParticle, 1, hero.reticle, 1, "follow_origin", hero.reticle:GetAbsOrigin(), true)
          local aimpos = hero:GetAbsOrigin() + hero.aim * 3000
          hero.reticle:SetAbsOrigin(aimpos)
        elseif not hero.useReticle and hero.laserParticle then
          ParticleManager:DestroyParticle(hero.laserParticle, true)
          hero.laserParticle = nil
        end

        local dir = Vector(0,0,0)
        local rot = nil
        if hero.up then
          rot = 0
          if hero.right then
            rot = -45
          elseif hero.left then
            rot = 45
          end
        elseif hero.down then
          rot = 180
          if hero.right then
            rot = rot + 45
          elseif hero.left then
            rot = rot - 45
          end
        elseif not hero.up and not hero.down then
          if hero.right then
            rot = -90
          elseif hero.left then
            rot = 90
          end
        end

        if rot ~= nil then
          hero:AddNewModifier(hero, nil, 'modifier_tutorial_forceanimation', {loop=1, activity=ACT_DOTA_RUN})
          dir = RotatePosition(Vector(0,0,0), QAngle(0,rot,0), forward)
        else
          hero:RemoveModifierByName('modifier_tutorial_forceanimation')
        end

        local speedMod = hero.speedModifier or 1
        hero:SetStaticVelocity('move', hero.speed * speedMod * dir)

        hero:OnFrame()
      end
    end)

    --hero:OnHeroSelectedCamera(hero.camera)
  end)
end

function GameMode:PlayTeamSound(radiantSound, direSound)
  for i=0,31 do
    local player = PlayerResource:GetPlayer(i)
    if player then
      if GameRules:IsAlly(player:GetTeam(), DOTA_TEAM_GOODGUYS) then
        EmitSoundOnClient(radiantSound, player)
      elseif GameRules:IsAlly(player:GetTeam(), DOTA_TEAM_BADGUYS) then
        EmitSoundOnClient(direSound, player)
      end
    end
  end
end

--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function GameMode:OnGameInProgress()
  print("[BAREBONES] The game has officially begun")

  --Notifications:Top(0, {text="GREEEENNNN", duration=9, style={color="green"}, continue=true})
  Notifications:TopToAll({text="First to <font color='#FF3455'>" .. KILLS_TO_END_GAME_FOR_TEAM .. "</font> Points Wins!", duration=5})
  Timers:CreateTimer(5, function()
    Notifications:TopToAll({text="Kills are worth <font color='#FF3455'>" .. KILL_POINTS .. "</font>", duration=5})
    Notifications:TopToAll({text="Flag captures are worth <font color='#FF3455'>" .. FLAG_POINTS .. "</font>", duration=5})
  end)
end




-- Cleanup a player when they leave
function GameMode:OnDisconnect(keys)
  print('[BAREBONES] Player Disconnected ' .. tostring(keys.userid))
  PrintTable(keys)

  local name = keys.name
  local networkid = keys.networkid
  local reason = keys.reason
  local userid = keys.userid

end
-- The overall game state has changed
function GameMode:OnGameRulesStateChange(keys)
  print("[BAREBONES] GameRules State Changed")
  PrintTable(keys)

  local newState = GameRules:State_Get()
  if newState == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
    self.bSeenWaitForPlayers = true
  elseif newState == DOTA_GAMERULES_STATE_INIT then
    Timers:RemoveTimer("alljointimer")
  elseif newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
    local et = 6
    if self.bSeenWaitForPlayers then
      et = .01
    end
    Timers:CreateTimer("alljointimer", {
      useGameTime = true,
      endTime = et,
      callback = function()
        if PlayerResource:HaveAllPlayersJoined() then
          GameMode:PostLoadPrecache()
          GameMode:OnAllPlayersLoaded()
          return 
        end
        return 1
      end
      })
  elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    GameMode:OnGameInProgress()
  end
end

-- An NPC has spawned somewhere in game.  This includes heroes
function GameMode:OnNPCSpawned(keys)
  --print("[BAREBONES] NPC Spawned")
  --PrintTable(keys)
  local npc = EntIndexToHScript(keys.entindex)

  if npc:IsRealHero() and npc.bFirstSpawned == nil then
    npc.bFirstSpawned = true
    GameMode:OnHeroInGame(npc)
  elseif npc:IsRealHero() and npc.bFirstSpawned ~= nil and npc.OnRespawn then
    npc:OnRespawn()
  end
end

-- An entity somewhere has been hurt.  This event fires very often with many units so don't do too many expensive
-- operations here
function GameMode:OnEntityHurt(keys)
  --print("[BAREBONES] Entity Hurt")
  --PrintTable(keys)
  local entCause = EntIndexToHScript(keys.entindex_attacker)
  local entVictim = EntIndexToHScript(keys.entindex_killed)
end

-- An item was picked up off the ground
function GameMode:OnItemPickedUp(keys)
  print ( '[BAREBONES] OnItemPurchased' )
  PrintTable(keys)

  local heroEntity = EntIndexToHScript(keys.HeroEntityIndex)
  local itemEntity = EntIndexToHScript(keys.ItemEntityIndex)
  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local itemname = keys.itemname
end

-- A player has reconnected to the game.  This function can be used to repaint Player-based particles or change
-- state as necessary
function GameMode:OnPlayerReconnect(keys)
  print ( '[BAREBONES] OnPlayerReconnect' )
  PrintTable(keys) 
  local pid = keys.PlayerID
end

-- An item was purchased by a player
function GameMode:OnItemPurchased( keys )
  print ( '[BAREBONES] OnItemPurchased' )
  PrintTable(keys)

  -- The playerID of the hero who is buying something
  local plyID = keys.PlayerID
  if not plyID then return end

  -- The name of the item purchased
  local itemName = keys.itemname 
  
  -- The cost of the item purchased
  local itemcost = keys.itemcost
  
end

-- An ability was used by a player
function GameMode:OnAbilityUsed(keys)
  print('[BAREBONES] AbilityUsed')
  PrintTable(keys)

  local player = EntIndexToHScript(keys.PlayerID)
  local abilityname = keys.abilityname
end

-- A non-player entity (necro-book, chen creep, etc) used an ability
function GameMode:OnNonPlayerUsedAbility(keys)
  print('[BAREBONES] OnNonPlayerUsedAbility')
  PrintTable(keys)

  local abilityname=  keys.abilityname
end

-- A player changed their name
function GameMode:OnPlayerChangedName(keys)
  print('[BAREBONES] OnPlayerChangedName')
  PrintTable(keys)

  local newName = keys.newname
  local oldName = keys.oldName
end

-- A player leveled up an ability
function GameMode:OnPlayerLearnedAbility( keys)
  print ('[BAREBONES] OnPlayerLearnedAbility')
  PrintTable(keys)

  local player = EntIndexToHScript(keys.player)
  local abilityname = keys.abilityname
end

-- A channelled ability finished by either completing or being interrupted
function GameMode:OnAbilityChannelFinished(keys)
  print ('[BAREBONES] OnAbilityChannelFinished')
  PrintTable(keys)

  local abilityname = keys.abilityname
  local interrupted = keys.interrupted == 1
end

-- A player leveled up
function GameMode:OnPlayerLevelUp(keys)
  print ('[BAREBONES] OnPlayerLevelUp')
  PrintTable(keys)

  local player = EntIndexToHScript(keys.player)
  local level = keys.level
end

-- A player last hit a creep, a tower, or a hero
function GameMode:OnLastHit(keys)
  print ('[BAREBONES] OnLastHit')
  PrintTable(keys)

  local isFirstBlood = keys.FirstBlood == 1
  local isHeroKill = keys.HeroKill == 1
  local isTowerKill = keys.TowerKill == 1
  local player = PlayerResource:GetPlayer(keys.PlayerID)
end

-- A tree was cut down by tango, quelling blade, etc
function GameMode:OnTreeCut(keys)
  --print ('[BAREBONES] OnTreeCut')
  --PrintTable(keys)

  local treeX = keys.tree_x
  local treeY = keys.tree_y
end

-- A rune was activated by a player
function GameMode:OnRuneActivated (keys)
  print ('[BAREBONES] OnRuneActivated')
  PrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local rune = keys.rune

  --[[ Rune Can be one of the following types
  DOTA_RUNE_DOUBLEDAMAGE
  DOTA_RUNE_HASTE
  DOTA_RUNE_HAUNTED
  DOTA_RUNE_ILLUSION
  DOTA_RUNE_INVISIBILITY
  DOTA_RUNE_MYSTERY
  DOTA_RUNE_RAPIER
  DOTA_RUNE_REGENERATION
  DOTA_RUNE_SPOOKY
  DOTA_RUNE_TURBO
  ]]
end

-- A player took damage from a tower
function GameMode:OnPlayerTakeTowerDamage(keys)
  print ('[BAREBONES] OnPlayerTakeTowerDamage')
  PrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local damage = keys.damage
end

-- A player picked a hero
function GameMode:OnPlayerPickHero(keys)
  print ('[BAREBONES] OnPlayerPickHero')
  PrintTable(keys)

  local heroClass = keys.hero
  local heroEntity = EntIndexToHScript(keys.heroindex)
  local player = EntIndexToHScript(keys.player)
end

-- A player killed another player in a multi-team context
function GameMode:OnTeamKillCredit(keys)
  print ('[BAREBONES] OnTeamKillCredit')
  PrintTable(keys)

  local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
  local victimPlayer = PlayerResource:GetPlayer(keys.victim_userid)
  local numKills = keys.herokills
  local killerTeamNumber = keys.teamnumber
end

-- An entity died
function GameMode:OnEntityKilled( keys )
  --print( '[BAREBONES] OnEntityKilled Called' )
  --PrintTable( keys )
  
  -- The Unit that was Killed
  local killedUnit = EntIndexToHScript( keys.entindex_killed )
  -- The Killing entity
  local killerEntity = nil

  if keys.entindex_attacker ~= nil then
    killerEntity = EntIndexToHScript( keys.entindex_attacker )
  end

  if killedUnit:IsRealHero() then 
    killedUnit:SetTimeUntilRespawn(10)
    print ("KILLEDKILLER: " .. killedUnit:GetName() .. " -- " .. killerEntity:GetName())
    if GameRules:IsAlly(killedUnit:GetTeam(), DOTA_TEAM_BADGUYS) then --and GameRules:IsAlly(killerEntity:GetTeam(), DOTA_TEAM_GOODGUYS)  then
      self.nRadiantKills = self.nRadiantKills + KILL_POINTS
      if SHOW_KILLS_ON_TOPBAR then
        CustomNetTables:SetTableValue("sotaui", "radiant_score", {value=GameMode.nRadiantKills})
        CustomNetTables:SetTableValue("sotaui", "dire_score", {value=GameMode.nDireKills})
      end

      if END_GAME_ON_KILLS and self.nRadiantKills >= KILLS_TO_END_GAME_FOR_TEAM then
        GameRules:SetSafeToLeave( true )
        GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )
        ControlOverride:SendConfigToAll(false, false, false, true)
        CameraManager:SendConfigToAll(false)
      end
    elseif GameRules:IsAlly(killedUnit:GetTeam(), DOTA_TEAM_GOODGUYS) then -- and GameRules:IsAlly(killerEntity:GetTeam(), DOTA_TEAM_BADGUYS) then
      self.nDireKills = self.nDireKills + KILL_POINTS
      if SHOW_KILLS_ON_TOPBAR then
        CustomNetTables:SetTableValue("sotaui", "radiant_score", {value=GameMode.nRadiantKills})
        CustomNetTables:SetTableValue("sotaui", "dire_score", {value=GameMode.nDireKills})
      end

      if END_GAME_ON_KILLS and self.nDireKills >= KILLS_TO_END_GAME_FOR_TEAM then
        GameRules:SetSafeToLeave( true )
        GameRules:SetGameWinner( DOTA_TEAM_BADGUYS )
        ControlOverride:SendConfigToAll(false, false, false, true)
        CameraManager:SendConfigToAll(false)
      end
    end
  end

  if killedUnit.OnDeath then
    killedUnit:OnDeath()
  end
  if killerEntity.OnKillUnit then
    killerEntity:OnKillUnit(killedUnit)
  end
  -- Put code here to handle when an entity gets killed
end


-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function GameMode:InitGameMode()
  GameMode = self
  print('[BAREBONES] Starting to load Barebones gamemode...')

  -- Setup rules
  GameRules:SetHeroRespawnEnabled( ENABLE_HERO_RESPAWN )
  GameRules:SetUseUniversalShopMode( UNIVERSAL_SHOP_MODE )
  GameRules:SetSameHeroSelectionEnabled( ALLOW_SAME_HERO_SELECTION )
  GameRules:SetHeroSelectionTime( HERO_SELECTION_TIME )
  GameRules:SetPreGameTime( PRE_GAME_TIME)
  GameRules:SetPostGameTime( POST_GAME_TIME )
  GameRules:SetTreeRegrowTime( TREE_REGROW_TIME )
  GameRules:SetUseCustomHeroXPValues ( USE_CUSTOM_XP_VALUES )
  GameRules:SetGoldPerTick(GOLD_PER_TICK)
  GameRules:SetGoldTickTime(GOLD_TICK_TIME)
  GameRules:SetRuneSpawnTime(RUNE_SPAWN_TIME)
  GameRules:SetUseBaseGoldBountyOnHeroes(USE_STANDARD_HERO_GOLD_BOUNTY)
  GameRules:SetHeroMinimapIconScale( MINIMAP_ICON_SIZE )
  GameRules:SetCreepMinimapIconScale( MINIMAP_CREEP_ICON_SIZE )
  GameRules:SetRuneMinimapIconScale( MINIMAP_RUNE_ICON_SIZE )

  local name = GetMapName()
  if name == "caldera" then
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 6)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 6)
  else
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 12)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 12)
  end

  --GameRules:SetFirstBloodActive( ENABLE_FIRST_BLOOD )
  --GameRules:SetHideKillMessageHeaders( HIDE_KILL_BANNERS )

  SetTeamCustomHealthbarColor(DOTA_TEAM_GOODGUYS, 52, 85, 255)
  SetTeamCustomHealthbarColor(DOTA_TEAM_BADGUYS, 255, 52, 85)
  print('[BAREBONES] GameRules set')

  InitLogFile( "log/barebones.txt","")

  -- Event Hooks
  -- All of these events can potentially be fired by the game, though only the uncommented ones have had
  -- Functions supplied for them.  If you are interested in the other events, you can uncomment the
  -- ListenToGameEvent line and add a function to handle the event
  ListenToGameEvent('dota_player_gained_level', Dynamic_Wrap(GameMode, 'OnPlayerLevelUp'), self)
  ListenToGameEvent('dota_ability_channel_finished', Dynamic_Wrap(GameMode, 'OnAbilityChannelFinished'), self)
  ListenToGameEvent('dota_player_learned_ability', Dynamic_Wrap(GameMode, 'OnPlayerLearnedAbility'), self)
  ListenToGameEvent('entity_killed', Dynamic_Wrap(GameMode, 'OnEntityKilled'), self)
  ListenToGameEvent('player_connect_full', Dynamic_Wrap(GameMode, 'OnConnectFull'), self)
  ListenToGameEvent('player_disconnect', Dynamic_Wrap(GameMode, 'OnDisconnect'), self)
  ListenToGameEvent('dota_item_purchased', Dynamic_Wrap(GameMode, 'OnItemPurchased'), self)
  ListenToGameEvent('dota_item_picked_up', Dynamic_Wrap(GameMode, 'OnItemPickedUp'), self)
  ListenToGameEvent('last_hit', Dynamic_Wrap(GameMode, 'OnLastHit'), self)
  ListenToGameEvent('dota_non_player_used_ability', Dynamic_Wrap(GameMode, 'OnNonPlayerUsedAbility'), self)
  ListenToGameEvent('player_changename', Dynamic_Wrap(GameMode, 'OnPlayerChangedName'), self)
  ListenToGameEvent('dota_rune_activated_server', Dynamic_Wrap(GameMode, 'OnRuneActivated'), self)
  ListenToGameEvent('dota_player_take_tower_damage', Dynamic_Wrap(GameMode, 'OnPlayerTakeTowerDamage'), self)
  ListenToGameEvent('tree_cut', Dynamic_Wrap(GameMode, 'OnTreeCut'), self)
  ListenToGameEvent('entity_hurt', Dynamic_Wrap(GameMode, 'OnEntityHurt'), self)
  ListenToGameEvent('player_connect', Dynamic_Wrap(GameMode, 'PlayerConnect'), self)
  ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(GameMode, 'OnAbilityUsed'), self)
  ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(GameMode, 'OnGameRulesStateChange'), self)
  ListenToGameEvent('npc_spawned', Dynamic_Wrap(GameMode, 'OnNPCSpawned'), self)
  ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(GameMode, 'OnPlayerPickHero'), self)
  ListenToGameEvent('dota_team_kill_credit', Dynamic_Wrap(GameMode, 'OnTeamKillCredit'), self)
  ListenToGameEvent("player_reconnected", Dynamic_Wrap(GameMode, 'OnPlayerReconnect'), self)
  --ListenToGameEvent('player_spawn', Dynamic_Wrap(GameMode, 'OnPlayerSpawn'), self)
  --ListenToGameEvent('dota_unit_event', Dynamic_Wrap(GameMode, 'OnDotaUnitEvent'), self)
  --ListenToGameEvent('nommed_tree', Dynamic_Wrap(GameMode, 'OnPlayerAteTree'), self)
  --ListenToGameEvent('player_completed_game', Dynamic_Wrap(GameMode, 'OnPlayerCompletedGame'), self)
  --ListenToGameEvent('dota_match_done', Dynamic_Wrap(GameMode, 'OnDotaMatchDone'), self)
  --ListenToGameEvent('dota_combatlog', Dynamic_Wrap(GameMode, 'OnCombatLogEvent'), self)
  --ListenToGameEvent('dota_player_killed', Dynamic_Wrap(GameMode, 'OnPlayerKilled'), self)
  --ListenToGameEvent('player_team', Dynamic_Wrap(GameMode, 'OnPlayerTeam'), self)



  -- Commands can be registered for debugging purposes or as functions that can be called by the custom Scaleform UI
  Convars:RegisterCommand( "command_example", Dynamic_Wrap(GameMode, 'ExampleConsoleCommand'), "A console command example", 0 )
  
  -- Fill server with fake clients
  -- Fake clients don't use the default bot AI for buying items or moving down lanes and are sometimes necessary for debugging
  Convars:RegisterCommand('fake', function()
    -- Check if the server ran it
    if not Convars:GetCommandClient() then
      -- Create fake Players
      SendToServerConsole('dota_create_fake_clients')
        
      Timers:CreateTimer('assign_fakes', {
        useGameTime = false,
        endTime = Time(),
        callback = function(barebones, args)
          local userID = 20
          for i=0, 9 do
            userID = userID + 1
            -- Check if this player is a fake one
            if PlayerResource:IsFakeClient(i) then
              -- Grab player instance
              local ply = PlayerResource:GetPlayer(i)
              -- Make sure we actually found a player instance
              if ply then
                CreateHeroForPlayer('npc_dota_hero_axe', ply)
                self:OnConnectFull({
                  userid = userID,
                  index = ply:entindex()-1
                })

                ply:GetAssignedHero():SetControllableByPlayer(0, true)
              end
            end
          end
        end})
    end
  end, 'Connects and assigns fake Players.', 0)

  --[[This block is only used for testing events handling in the event that Valve adds more in the future
  Convars:RegisterCommand('events_test', function()
      GameMode:StartEventTest()
    end, "events test", 0)]]

  -- Change random seed
  local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
  math.randomseed(tonumber(timeTxt))

  -- Initialized tables for tracking state
  self.vUserIds = {}
  self.vSteamIds = {}
  self.vBots = {}
  self.vBroadcasters = {}

  self.vPlayers = {}
  self.vRadiant = {}
  self.vDire = {}

  self.nRadiantKills = 0
  self.nDireKills = 0

  self.bSeenWaitForPlayers = false

  print('[BAREBONES] Done loading Barebones gamemode!\n\n')
end

mode = nil

-- This function is called as the first player loads and sets up the GameMode parameters
function GameMode:CaptureGameMode()
  if mode == nil then
    -- Set GameMode parameters
    mode = GameRules:GetGameModeEntity()        
    mode:SetRecommendedItemsDisabled( RECOMMENDED_BUILDS_DISABLED )
    --mode:SetCameraDistanceOverride( CAMERA_DISTANCE_OVERRIDE )
    mode:SetCustomBuybackCostEnabled( CUSTOM_BUYBACK_COST_ENABLED )
    mode:SetCustomBuybackCooldownEnabled( CUSTOM_BUYBACK_COOLDOWN_ENABLED )
    mode:SetBuybackEnabled( BUYBACK_ENABLED )
    mode:SetTopBarTeamValuesOverride ( USE_CUSTOM_TOP_BAR_VALUES )
    mode:SetTopBarTeamValuesVisible( TOP_BAR_VISIBLE )
    mode:SetUseCustomHeroLevels ( USE_CUSTOM_HERO_LEVELS )
    mode:SetCustomHeroMaxLevel ( MAX_LEVEL )
    mode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )

    --mode:SetBotThinkingEnabled( USE_STANDARD_DOTA_BOT_THINKING )
    mode:SetTowerBackdoorProtectionEnabled( ENABLE_TOWER_BACKDOOR_PROTECTION )

    mode:SetFogOfWarDisabled(DISABLE_FOG_OF_WAR_ENTIRELY)
    mode:SetGoldSoundDisabled( DISABLE_GOLD_SOUNDS )
    mode:SetRemoveIllusionsOnDeath( REMOVE_ILLUSIONS_ON_DEATH )


    --mode:SetAnnouncerDisabled( DISABLE_ANNOUNCER )
    --mode:SetFixedRespawnTime( FIXED_RESPAWN_TIME ) 
    --mode:SetFountainConstantManaRegen( FOUNTAIN_CONSTANT_MANA_REGEN )
    --mode:SetFountainPercentageHealthRegen( FOUNTAIN_PERCENTAGE_HEALTH_REGEN )
    --mode:SetFountainPercentageManaRegen( FOUNTAIN_PERCENTAGE_MANA_REGEN )
    --mode:SetLoseGoldOnDeath( LOSE_GOLD_ON_DEATH )
    --mode:SetMaximumAttackSpeed( MAXIMUM_ATTACK_SPEED )
    --mode:SetMinimumAttackSpeed( MINIMUM_ATTACK_SPEED )
    --mode:SetStashPurchasingDisabled ( DISABLE_STASH_PURCHASING )

    --GameRules:GetGameModeEntity():SetThink( "Think", self, "GlobalThink", 2 )

    self:OnFirstPlayerLoaded()
  end 
end

-- This function is called 1 to 2 times as the player connects initially but before they 
-- have completely connected
function GameMode:PlayerConnect(keys)
  print('[BAREBONES] PlayerConnect')
  PrintTable(keys)
  
  if keys.bot == 1 then
    -- This user is a Bot, so add it to the bots table
    self.vBots[keys.userid] = 1
  end
end

local teamCount = 0
-- This function is called once when the player fully connects and becomes "Ready" during Loading
function GameMode:OnConnectFull(keys)
  print ('[BAREBONES] OnConnectFull')
  PrintTable(keys)
  GameMode:CaptureGameMode()
  
  local entIndex = keys.index+1
  -- The Player entity of the joining user
  local ply = EntIndexToHScript(entIndex)
  
  -- The Player ID of the joining player
  local playerID = ply:GetPlayerID()
  print(playerID)
  print('isbroad: ' .. tostring(PlayerResource:IsBroadcaster(playerID)))
  
  -- Update the user ID table with this user
  self.vUserIds[keys.userid] = ply

  -- Update the Steam ID table
  self.vSteamIds[PlayerResource:GetSteamAccountID(playerID)] = ply
  
  -- If the player is a broadcaster flag it in the Broadcasters table
  --[[if PlayerResource:IsBroadcaster(playerID) or playerID >= 10 then
    self.vBroadcasters[keys.userid] = 1
    --return

    local channel = PlayerResource:GetBroadcasterChannel(playerID)
    local slot = PlayerResource:GetBroadcasterChannelSlot(playerID)
    print('channel ' .. channel)
    print('slot ' .. slot)
    print('teamCount ' .. teamCount)
    ply:SetTeam(teamCount + DOTA_TEAM_CUSTOM_1)
    PlayerResource:SetCustomTeamAssignment(playerID, teamCount + DOTA_TEAM_CUSTOM_1)
    teamCount = teamCount + 1
    if teamCount >= 4 then
      teamCount = 0
    end
  end]]

  Timers:CreateTimer(1, function()
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    if hero ~= nil and GameRules:State_Get() > DOTA_GAMERULES_STATE_HERO_SELECTION and GameRules:State_Get() < DOTA_GAMERULES_STATE_POST_GAME then
      hero.reinitNextAim = true
      ControlOverride:SendCvar(playerID, "dota_camera_z_interp_speed", "0")
      ControlOverride:SendCvar(playerID, "dota_camera_disable_zoom", "1")
      ControlOverride:SendKeyFilter(playerID, {KEY_W, KEY_S, KEY_A, KEY_D, KEY_SPACE, KEY_SHIFT,
                                      KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6,
                                      KEY_R, KEY_B, KEY_F1})
      ControlOverride:SendConfig(playerID, true, true, false, true)
      CameraManager:SendConfig(playerID, true)

      ControlOverride:SendCvar(playerID, "dota_camera_edgemove", "0")
      ControlOverride:SendCvar(playerID, "dota_camera_fov_max", "80")
      ControlOverride:SendCvar(playerID, "dota_camera_lock", "1")
      ControlOverride:SendCvar(playerID, "dota_camera_pitch_max", "35")
      ControlOverride:SendCvar(playerID, "dota_camera_lock_lerp", ".20")
      ControlOverride:SendCvar(playerID, "r_farz", "16000")

      ControlOverride:SendCvar(playerID, "dota_camera_z_interp_speed", "0")
      --ControlOverride:SendCvar(playerID, "dota_camera_z_interp_speed", "3")
      --ControlOverride:SendCvar(playerID, "dota_camera_smooth_enable", "1")
      --ControlOverride:SendCvar(playerID, "dota_camera_smooth_distance", "0")
      --ControlOverride:SendCvar(playerID, "dota_camera_smooth_count", "15")

      --[[ControlOverride:SendCvar(playerID, "dota_camera_z_interp_speed", "0")
      ControlOverride:SendCvar(playerID, "dota_camera_smooth_enable", "0")
      ControlOverride:SendCvar(playerID, "dota_camera_smooth_distance", "0")
      ControlOverride:SendCvar(playerID, "dota_camera_smooth_count", "0")]]

      CameraManager:SetProperty(playerID,CAMERA_DISTANCE,hero.baseCameraDistance)
    end
  end)

  if GameMode.powerupsDrawn then
    GameMode:DrawPowerups()
  end
end

-- This is an example console command
function GameMode:ExampleConsoleCommand()
  print( '******* Example Console Command ***************' )
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      -- Do something here for the player who called this command
      PlayerResource:ReplaceHeroWith(playerID, "npc_dota_hero_viper", 1000, 1000)
    end
  end

  print( '*********************************************' )
end

--require('eventtest')
--GameMode:StartEventTest()

function getItemByName( hero, name )
  if not hero:HasItemInInventory ( name ) then
    return nil
  end
  
  --print ( '[REFLEX] find item in inventory' )
  -- Find item by slot
  for i=0,11 do
    --print ( '\t[REFLEX] finding item ' .. i)
    local item = hero:GetItemInSlot( i )
    --print ( '\t[REFLEX] item: ' .. tostring(item) )
    if item ~= nil then
      --print ( '\t[REFLEX] getting ability name' .. i)
      local lname = item:GetAbilityName()
      --print ( string.format ('[REFLEX] item slot %d: %s', i, lname) )
      if lname == name then
        return item
      end
    end
  end
  
  return nil
end

function ApplyModifier(source, target, name, args)
  GameRules.ModApplier:ApplyDataDrivenModifier(source, target, name, args)
end

-- handle reload
for _, hero in ipairs(HeroList:GetAllHeroes()) do
  local heroClass = string.match(hero:GetClassname(), "npc_dota_hero_(.*)")

  local heroscript = nil
  local status,ret = pcall(function()
    heroscript = require('heroes/' .. heroClass)
    if heroscript ~= nil then
      heroscript:InitializeClass(hero)
    end
  end)

  if not status then
    print("HeroScript Creation Failed: " .. heroClass .. " -- " .. ret)
  end

  if heroscript == nil then
    print('No hero script found for hero class: ' .. heroClass)
    heroscript = require('heroes/default'):InitializeClass(hero)
  end
end


GameRules.GameMode = GameMode
GameRules.ApplyModifier = ApplyModifier