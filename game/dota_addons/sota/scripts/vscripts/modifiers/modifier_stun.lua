modifier_stun = class({})

--[[function modifier_unselectable:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_MAX,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
    }

    return funcs
end]]

function modifier_stun:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
  }

  return funcs
end

--------------------------------------------------------------------------------

function modifier_stun:GetOverrideAnimation( params )
  return ACT_DOTA_DISABLED
end

function modifier_stun:CheckState()
  local state = {
    [MODIFIER_STATE_STUNNED] = true,
  }

  return state
end

function modifier_stun:IsHidden()
    return true
end