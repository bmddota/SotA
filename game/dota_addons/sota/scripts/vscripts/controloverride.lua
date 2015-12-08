KEY_W = 87
KEY_S = 83
KEY_A = 65
KEY_D = 68
KEY_SPACE = 32
KEY_SHIFT = 16
KEY_R = 82
KEY_B = 66
KEY_F1 = 112
KEY_F2 = 113
KEY_1 = 49
KEY_2 = 50
KEY_3 = 51
KEY_4 = 52
KEY_5 = 53
KEY_6 = 54
KEY_TAB = 9
KEY_BACKTICK = 192

if ControlOverride == nil then
  print ( '[ControlOverride] creating ControlOverride' )
  ControlOverride = {}
  ControlOverride.__index = ControlOverride

  ControlOverride.mouseUpCallback = nil;
  ControlOverride.mouseDownCallback = nil;
  ControlOverride.mouseMoveCallback = nil;
  ControlOverride.keyDownCallback = nil;
  ControlOverride.keyUpCallback = nil;
  ControlOverride.selectCallback = nil;
  ControlOverride.debug = false

  Convars:RegisterCommand('co_mouse_down', function(...)
    local arg = {...}
    table.remove(arg,1)

    local cmdPlayer = Convars:GetCommandClient()
    if ControlOverride.debug then
      print("co_mouse_down: " .. cmdPlayer:GetPlayerID() .. " " .. table.concat(arg, ", "));
    end

    if ControlOverride.mouseDownCallback then
      local status, ret = pcall(ControlOverride.mouseDownCallback, cmdPlayer, arg[1] == "0", tonumber(arg[2]), tonumber(arg[3]), Vector(tonumber(arg[4]),tonumber(arg[5]),tonumber(arg[6])))
      if not status then
        print('[ControlOverride] Mouse Down callback failure: ' .. ret)
      end
    end
  end, 'co_mouse_down', 0)

  Convars:RegisterCommand('co_mouse_up', function(...)
    local arg = {...}
    table.remove(arg,1)

    local cmdPlayer = Convars:GetCommandClient()
    if ControlOverride.debug then
      print("co_mouse_up: " .. cmdPlayer:GetPlayerID() .. " " .. table.concat(arg, ", "));
    end

    if ControlOverride.mouseUpCallback then
      local status, ret = pcall(ControlOverride.mouseUpCallback, cmdPlayer, arg[1] == "0", tonumber(arg[2]), tonumber(arg[3]), Vector(tonumber(arg[4]),tonumber(arg[5]),tonumber(arg[6])))
      if not status then
        print('[ControlOverride] Mouse Up callback failure: ' .. ret)
      end
    end
  end, 'co_mouse_up', 0)

  Convars:RegisterCommand('co_mouse_move', function(...)
    local arg = {...}
    table.remove(arg,1)

    local cmdPlayer = Convars:GetCommandClient()
    if ControlOverride.debug then
      print("co_mouse_move: " .. cmdPlayer:GetPlayerID() .. " " .. table.concat(arg, ", "));
    end

    if ControlOverride.mouseMoveCallback then
      local status, ret = pcall(ControlOverride.mouseMoveCallback, cmdPlayer, Vector(tonumber(arg[1]),tonumber(arg[2]),tonumber(arg[3])))
      if not status then
        print('[ControlOverride] Mouse move callback failure: ' .. ret)
      end
    end
  end, 'co_mouse_move', 0)

  Convars:RegisterCommand('co_key_down', function(...)
    local arg = {...}
    table.remove(arg,1)

    local cmdPlayer = Convars:GetCommandClient()
    if ControlOverride.debug then
      print("co_key_down: " .. cmdPlayer:GetPlayerID() .. " " .. table.concat(arg, ", "));
    end

    if ControlOverride.keyDownCallback then
      local status, ret = pcall(ControlOverride.keyDownCallback, cmdPlayer, tonumber(arg[1]), arg[2], arg[3], arg[4])
      if not status then
        print('[ControlOverride] Key Down callback failure: ' .. ret)
      end
    end
  end, 'co_key_down', 0)

  Convars:RegisterCommand('co_key_up', function(...)
    local arg = {...}
    table.remove(arg,1)

    local cmdPlayer = Convars:GetCommandClient()
    if ControlOverride.debug then
      print("co_key_up: " .. cmdPlayer:GetPlayerID() .. " " .. table.concat(arg, ", "));
    end

    if ControlOverride.keyUpCallback then
      local status, ret = pcall(ControlOverride.keyUpCallback, cmdPlayer, tonumber(arg[1]), arg[2], arg[3], arg[4])
      if not status then
        print('[ControlOverride] Key Up callback failure: ' .. ret)
      end
    end
  end, 'co_key_up', 0)

  Convars:RegisterCommand('co_select', function(...)
    local arg = {...}
    table.remove(arg,1)

    local cmdPlayer = Convars:GetCommandClient()
    if ControlOverride.debug then
      print("co_select: " .. cmdPlayer:GetPlayerID() .. " " .. table.concat(arg, ", "));
    end

    if ControlOverride.selectCallback then
      local status, ret = pcall(ControlOverride.selectCallback, cmdPlayer, tonumber(arg[1]))
      if not status then
        print('[ControlOverride] Selection callback failure: ' .. ret)
      end
    end
  end, 'co_select', 0)

  Convars:RegisterCommand('co_say_turnaround', function(...)
    local arg = {...}
    table.remove(arg,1)

    local cmdPlayer = Convars:GetCommandClient()
    keys = {}
    keys.ply = cmdPlayer
    keys.text = table.concat(arg, " ")

    Say(cmdPlayer, keys.text, false)

    --temporary command stuff
    local jump1 = string.match(keys.text, "^-jump%s+(%d+)")
    if jump1 ~= nil then
      jumpspeed = tonumber(jump1)
    end

    local rate1 = string.match(keys.text, "^-rate%s+(.+)")
    if rate1 ~= nil then
      shottime = tonumber(rate1)
    end

    local speed1 = string.match(keys.text, "^-speed%s+(.+)")
    if speed1 ~= nil then
      shotspeed = tonumber(speed1)
    end

    local wall1 = string.match(keys.text, "^-wall%s+(.+)")
    if wall1 ~= nil then
      wall = tonumber(wall1)
    end

    local tree1 = string.match(keys.text, "^-tree%s+(.+)")
    if tree1 ~= nil then
      tree = tonumber(tree1)
    end

    local ground1 = string.match(keys.text, "^-ground%s+(.+)")
    if ground1 ~= nil then
      ground = tonumber(ground1)
    end

    local damage1 = string.match(keys.text, "^-damage%s+(.+)")
    if damage1 ~= nil then
      shotdamage = tonumber(damage1)
    end

    local radius1 = string.match(keys.text, "^-radius%s+(.+)")
    if radius1 ~= nil then
      shotradius = tonumber(radius1)
    end

    local move1 = string.match(keys.text, "^-move%s+(.+)")
    if move1 ~= nil then
      MOVE_SPEED = tonumber(move1)
      for k,v in pairs(HeroList:GetAllHeroes()) do
        v.speed = MOVE_SPEED
      end
    end

  end, 'co_say_turnaround', 0)
end



function ControlOverride:MouseDownHandler(fun)
  ControlOverride.mouseDownCallback = fun
end
function ControlOverride:MouseUpHandler(fun)
  ControlOverride.mouseUpCallback = fun
end
function ControlOverride:MouseMoveHandler(fun)
  ControlOverride.mouseMoveCallback = fun
end
function ControlOverride:KeyDownHandler(fun)
  ControlOverride.keyDownCallback = fun
end
function ControlOverride:KeyUpHandler(fun)
  ControlOverride.keyUpCallback = fun
end
function ControlOverride:SelectionHandler(fun)
  ControlOverride.selectCallback = fun
end


function ControlOverride:SendConfigToAll(clicks, keys, movement, selection)
  ControlOverride:SendConfig(-1, clicks, keys, movement, selection)
end
function ControlOverride:SendConfig(pid, clicks, keys, movement, selection)
  local obj = {pid=pid, clicks=clicks, keys=keys, movement=movement, selection=selection}
  FireGameEvent("control_override_config", obj)
end


function ControlOverride:SendKeyFilterToAll(filter)
  ControlOverride:SendKeyFilter(-1, filter)
end
function ControlOverride:SendKeyFilter(pid, filter)
  local obj = {pid=pid, filter=table.concat(filter, ",")}
  FireGameEvent("control_override_keyfilter", obj)
end


function ControlOverride:SendSelectionFilterToAll(filter)
  ControlOverride:SendSelectionFilter(-1, filter)
end
function ControlOverride:SendSelectionFilter(pid, filter)
  local obj = {pid=pid, filter=table.concat(filter, ",")}
  FireGameEvent("control_override_selectfilter", obj)
end


function ControlOverride:SendMouseFilterToAll(filter)
  ControlOverride:SendMouseFilter(-1, filter)
end
function ControlOverride:SendMouseFilter(pid, filter)
  local obj = {pid=pid, filter=table.concat(filter, ",")}
  FireGameEvent("control_override_mousefilter", obj)
end


function ControlOverride:SendCvarToAll(cvar, value)
  ControlOverride:SendCvar(-1, cvar, value)
end
function ControlOverride:SendCvar(pid, cvar, value)
  local obj = {pid=pid, cvar=cvar, value=value}
  FireGameEvent("control_override_cvar", obj)
end
