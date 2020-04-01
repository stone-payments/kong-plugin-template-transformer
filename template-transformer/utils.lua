_M = {}

function _M.has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function _M.hide_fields(table, hidden_fields)
  if hidden_fields ~= nil and next(hidden_fields) ~= nil then
    for key, value in pairs(table) do
      if _M.has_value(hidden_fields, key) then
          table[key] = "******"
      end

      if type(value) == "table" then
        _M.hide_fields(value, hidden_fields)
      end
    end
  end
end

function _M.mask_field(value, mask_ini, mask_fin, mask_char)
  if type(value) ~= "string" then
    return value
  end

  mask_char = type(mask_char) == "string" and mask_char:sub(0, 1) or "*"

  if (mask_ini and type(mask_ini) ~= 'number') or 
     (mask_fin and type(mask_fin) ~= 'number') then
    return string.rep(mask_char, #value)
  end

  mask_ini = (type(mask_ini) ~= "nil") and (mask_ini) or 0
  mask_fin = ((type(mask_fin) ~= "nil") and (mask_fin > 0)) and -(mask_fin) or 0
  mask_char = type(mask_char) == "string" and mask_char:sub(0, 1) or "*"
  
  str_ini = value:sub(0, mask_ini)
  if (mask_fin < 0) then
    str_fin = value:sub(mask_fin)
  else
    str_fin = ""
  end

  str_mask = value:sub(mask_ini + 1, (mask_fin - 1))
  str_mask = string.rep(mask_char:sub(0,1), #str_mask)

  if (#str_mask <= 0) or
     (#str_ini == #value) or
     (#str_fin == #value) or 
     (#str_ini + #str_mask + #str_fin) > #value then
    response = string.rep(mask_char, #value)
  else
    response = str_ini .. str_mask .. str_fin
  end

  return response
end
return _M
