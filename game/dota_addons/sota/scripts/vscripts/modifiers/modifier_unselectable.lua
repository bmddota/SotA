modifier_unselectable = class({})

--[[function modifier_unselectable:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_MAX,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
    }

    return funcs
end]]

function modifier_unselectable:CheckState()
  local state = {
    [MODIFIER_STATE_UNSELECTABLE] = true,
  }

  return state
end

function modifier_unselectable:IsHidden()
    return true
end