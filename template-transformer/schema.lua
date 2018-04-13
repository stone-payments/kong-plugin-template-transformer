local template = require 'resty.template'

function check_template(string_template)
  if string_template then
    local status, err = pcall(function () 
      template.precompile(string_template) 
    end)
    return status
  end
  return true
end

return {
  no_consumer = true,
  fields = {
    request_template = {
      type = "string", 
      required = false,
      self_check = function(schema, config, dao, is_updating)
        -- print(config.request_template)
        return check_template(config.request_template)
      end
    },
    response_template = {
      type = "string", 
      required = false,
      self_check = function(schema, config, dao, is_updating)
        return check_template(config.response_template)
      end
    }
  }
}