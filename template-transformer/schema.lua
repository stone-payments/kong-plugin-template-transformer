local typedefs = require "kong.db.schema.typedefs"
local template = require 'resty.template'

function check_template(schema, config, dao, is_updating)
  if config.request_template then
    local status, err = pcall(function ()
      template.precompile(config.request_template)
    end)

    if status ~= true then
      return false, err
    end

    return status, err
  end

  if config.response_template then
    local status, err = pcall(function ()
      template.precompile(config.response_template)
    end)

    if status ~= true then
      return false, err
    end

    return status, err
  end

  return true
end

local _M = {
  name = "kong-plugin-template-transformer",
  fields = {
    { consumer = typedefs.no_consumer, },
    {
      config = {
        type = "record",
        fields = {
          { request_template = { type = "string", required = false }, },
          { response_template = { type = "string", required = false }, },
          { hidden_fields = { type = "array", elements = { type = "string" }, required = false}, },
          { ignore_content_types = { type = "array", elements = { type = "string" }, required = false }, },
        }
      }
    }
  },
}

local function constructor()
  return setmetatable({
    self_check = check_template
  }, { __index = _M })
end

setmetatable(_M, { __call = constructor })

return _M
