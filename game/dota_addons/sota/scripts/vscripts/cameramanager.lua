CAMERA_DISTANCE = 0

if CameraManager == nil then
  print ( '[CameraManager] creating CameraManager' )
  CameraManager = {}
  CameraManager.__index = CameraManager

  CameraManager.camAngCallback = nil;
  CameraManager.debug = false

  Convars:RegisterCommand('cam_ang', function(...)
    local arg = {...}
    table.remove(arg,1)

    local cmdPlayer = Convars:GetCommandClient()
    if CameraManager.debug then
      print("cam_ang: " .. cmdPlayer:GetPlayerID() .. " " .. table.concat(arg, ", "));
    end

    if CameraManager.camAngCallback then
      local status, ret = pcall(CameraManager.camAngCallback, cmdPlayer, tonumber(arg[1]), tonumber(arg[2]))
      if not status then
        print('[CameraManager] Camera angle failure: ' .. ret)
      end
    end
  end, 'cam_ang', 0)
end


function CameraManager:CameraRotateHandler(fun)
  CameraManager.camAngCallback = fun
end

function CameraManager:SendConfigToAll(activate, xSensitivity, ySensitivity)
  CameraManager:SendConfig(-1, activate, xSensitivity, ySensitivity)
end
function CameraManager:SendConfig(pid, activate, xSensitivity, ySensitivity)
  xSensitivity = xSensitivity or 0
  ySensitivity = ySensitivity or 0
  local obj = {pid=pid, activate=activate, xsensitivity=xSensitivity, ysensitivity=ySensitivity}
  FireGameEvent("camera_manager_config", obj)
end

function CameraManager:SetPropertyForAll(property, value)
  CameraManager:SetProperty(-1, property, value)
end
function CameraManager:SetProperty(pid, property, value)
  local obj = {pid=pid, property=property, value=value}
  FireGameEvent("camera_manager_set_property", obj)
end

function CameraManager:LerpPropertyForAll(property, to, count, step)
  CameraManager:LerpProperty(-1, property, to, count, step)
end
function CameraManager:LerpProperty(pid, property, to, count, step)
  local obj = {pid=pid, property=property, to=to, count=count, step=step}
  FireGameEvent("camera_manager_lerp_property", obj)
end