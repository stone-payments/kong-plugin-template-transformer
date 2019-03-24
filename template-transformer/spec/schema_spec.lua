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

local schema = require('schema')
local typedefs = require "kong.db.schema.typedefs"

describe("TestSchema", function()
    it("should initialize schema correctly", function()
      local fields = schema.fields[3].config.fields;

      assert.are_same(typedefs.no_consumer, schema.fields[1].consumer)
      assert.are_same(typedefs.run_on_first, schema.fields[2].run_on)
      assert.not_nil(fields[1].request_template)
      assert.not_nil(fields[1].request_template.type, "string")
      assert.not_nil(fields[1].request_template.required, false)
      assert.not_nil(fields[2].response_template)
      assert.not_nil(fields[2].response_template.type, "string")
      assert.not_nil(fields[2].response_template.required, false)
      assert.not_nil(fields[3].hidden_fields)
      assert.not_nil(fields[3].hidden_fields.type, "array")
      assert.not_nil(fields[3].hidden_fields.required, false)
      assert.not_nil(fields[3].hidden_fields.elements.type, "string")
    end)

    it("should return false then the request template is invalid", function()
      local string_template = "hello im a wrong {{a['}} template"

      local valid = schema.fields[3].config.custom_validator({ request_template = string_template })

      assert.is_false(valid)
    end)

    it("should return true then the request template is valid", function()
      local string_template = "hello im a correct {{a}} template"

      local valid = schema.fields[3].config.custom_validator({ request_template = string_template })

      assert.is_true(valid)
    end)

    it("should return false then the response template is invalid", function()
      local string_template = "hello im a wrong {{a['}} template"

      local valid = schema.fields[3].config.custom_validator({ request_template = string_template })

      assert.is_false(valid)
    end)

    it("should return true then the response template is valid", function()
      local string_template = "hello im a correct {{a}} template"

      local valid = schema.fields[3].config.custom_validator({ request_template = string_template })

      assert.is_true(valid)
    end)
end)