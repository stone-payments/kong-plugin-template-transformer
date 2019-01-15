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

describe("TestSchema", function()
    it("should initialize schema correctly", function()
      assert.is_true(schema.no_consumer)
      
      assert.not_nil(schema.fields.request_template)
      assert.not_nil(schema.fields.request_template.type, "string")
      assert.not_nil(schema.fields.request_template.required, false)
      
      assert.not_nil(schema.fields.response_template)
      assert.not_nil(schema.fields.response_template.type, "string")
      assert.not_nil(schema.fields.response_template.required, false)

      assert.not_nil(schema.fields.response_status_template)
      assert.not_nil(schema.fields.response_status_template.type, "string")
      assert.not_nil(schema.fields.response_status_template.required, false)

    end)

    it("should return false then the request template is invalid", function()
      local string_template = "hello im a wrong {{a['}} template"

      local valid = schema.self_check(nil, { request_template = string_template }, nil, nil)

      assert.is_false(valid)
    end)

    it("should return true then the request template is valid", function()
      local string_template = "hello im a correct {{a}} template"

      local valid = schema.self_check(nil, { request_template = string_template }, nil, nil)

      assert.is_true(valid)
    end)

    it("should return false then the response template is invalid", function()
      local string_template = "hello im a wrong {{a['}} template"

      local valid = schema.self_check(nil, { response_template = string_template }, nil, nil)

      assert.is_false(valid)
    end)

    it("should return true then the response template is valid", function()
      local string_template = "hello im a correct {{a}} template"

      local valid = schema.self_check(nil, { response_template = string_template }, nil, nil)

      assert.is_true(valid)
    end)

    it("should return false then the response status template is invalid", function()
      local string_template = "hello im a wrong {{a['}} template"

      local valid = schema.self_check(nil, { response_status_template = string_template }, nil, nil)

      assert.is_false(valid)
    end)

    it("should return true then the response template is valid", function()
      local string_template = "hello im a correct {{a}} template"

      local valid = schema.self_check(nil, { response_status_template = string_template }, nil, nil)

      assert.is_true(valid)
    end)
end)