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

function _M.field_mask(value, mask_ini, mask_fin, mask_char)
  if type(value) ~= "string" then
    return value
  end

  mask_ini = (type(mask_ini) == "number") and (mask_ini) or 0
  print('mask_ini=' .. mask_ini)
  mask_fin = ((type(mask_fin) == "number") and (mask_fin > 0)) and -(mask_fin) or 0
  print('mask_fin=' .. mask_fin)
  mask_char = type(mask_char) == "string" and mask_char:sub(0, 1) or "*"
  print('mask_char=' .. mask_char)

  str_ini = value:sub(0, mask_ini)
  print('str_ini=' .. str_ini)

  str_fin = value:sub(mask_fin)
  print('str_fin=' .. str_fin)

  str_mask = value:sub(mask_ini + 1, (mask_fin - 1))
  print('str_mask=' .. str_mask)

  str_mask = string.rep(mask_char:sub(0,1), #str_mask)
  print('str_mask=' .. str_mask)

  if (#str_mask <= 0) or
     (#str_ini == #value) or
     (#str_fin == #value) or 
     (#str_ini + #str_mask + #str_fin) > #value then
    response = string.rep(mask_char, #value)
  else
    response = str_ini .. str_mask .. str_fin
  end
  
  print('response=' .. response)
  return response
end
return _M
