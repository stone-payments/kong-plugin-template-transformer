local ngx =  {
    config = {
        prefix = spy.new(function()
            return "mock"
        end),
        nginx_configure = spy.new(function() return "" end)
    },
    re = {match = spy.new(function() end)},
    location = {
        capture = spy.new(function() end)
    },
    get_phase = spy.new(function() end),
}
_G.ngx = ngx

local schema = {
  name = "kong-plugin-template-transformer",
  fields = {
    { consumer = false, },
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

local template = require 'resty.template'

function self_check(config)
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

describe("Test #unit schema", function()
    it("should initialize schema correctly", function()
      assert.is_false(schema.fields[1].consumer)
      assert.not_nil(schema.fields[2].config.fields[1].request_template)
      assert.not_nil(schema.fields[2].config.fields[1].request_template.type, "string")
      assert.not_nil(schema.fields[2].config.fields[1].request_template.required, false)
      assert.not_nil(schema.fields[2].config.fields[1].request_template.type, "string")
      assert.not_nil(schema.fields[2].config.fields[1].request_template.required, false)
      assert.not_nil(schema.fields[2].config.fields[2].response_template)
    end)

    it("should return false then the request template is invalid", function()
      local string_template = "hello im a wrong {{a['}} template"

      local valid = self_check({ request_template = string_template })

      assert.is_false(valid)
    end)

    it("should return true then the request template is valid", function()
      local string_template = "hello im a correct {{a}} template"

      local valid = self_check({ request_template = string_template })

      assert.is_true(valid)
    end)

    it("should return false then the response template is invalid", function()
      local string_template = "hello im a wrong {{a['}} template"

      local valid = self_check({ response_template = string_template })

      assert.is_false(valid)
    end)

    it("should return true then the response template is valid", function()
      local string_template = "hello im a correct {{a}} template"

      local valid = self_check({ response_template = string_template })

      assert.is_true(valid)
    end)
end)