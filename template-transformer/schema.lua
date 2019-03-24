local typedefs = require "kong.db.schema.typedefs"
local template = require 'resty.template'

local function check_template(config)
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

return {
  name = "template-transformer",
  fields = {
    { consumer = typedefs.no_consumer },
    { run_on = typedefs.run_on_first },
    { config = {
        type = "record",
        fields = {
          { request_template = { type = "string", required = false }, },
          { response_template = { type = "string", required = false }, },
          { hidden_fields = { type = "array", required = false, elements = { type = "string" }, }, },
        },
        custom_validator = check_template,
      },
    },
  },
}
