local template = require 'resty.template'
local Errors = require "kong.dao.errors"

function check_template(schema, config, dao, is_updating)
  if config.request_template then
    local status, err = pcall(function ()
      template.precompile(config.request_template)
    end)

    if status ~= true then
      return false, Errors.schema(err)
    end

    return status, err
  end

  if config.response_template then
    local status, err = pcall(function ()
      template.precompile(config.response_template)
    end)

    if status ~= true then
      return false, Errors.schema(err)
    end

    return status, err
  end

  if config.response_status_template then
    local status, err = pcall(function ()
      template.precompile(config.response_status_template)
    end)

    if status ~= true then
      return false, Errors.schema(err)
    end

    return status, err
  end

  return true
end

return {
  no_consumer = true,
  fields = {
    request_template = {
      type = "string",
      required = false
    },
    response_template = {
      type = "string",
      required = false
    },
    response_status_template = {
      type = "string",
      required = false
    },
    hidden_fields = {
      type = "array",
      required = false
    }
  },
  self_check = check_template
}
