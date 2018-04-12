local ngx =  {
    req = {
        set_body_data = spy.new(function() end),
        get_body_data = spy.new(function() end),
        get_uri_args = spy.new(function() end),
        set_header = spy.new(function() end),
        get_headers = spy.new(function() end),
        read_body = spy.new(function() end),
    },
    config = {
        prefix = spy.new(function()
            return "mock"
        end)
    },
    location = {
        capture = spy.new(function() end)
    },
    get_phase = spy.new(function() end),
    log = spy.new(function() end)
}
_G.ngx = ngx
local TemplateTransformerHandler = require('handler')

describe("TestHandler", function()
  it("should test handler constructor", function()
    TemplateTransformerHandler:new()
    assert.equal("template-transformer", TemplateTransformerHandler._name)
  end)

  it("should test replace with template without variables", function()
    TemplateTransformerHandler:new()
    local config = {
        template = "hello im a template"
    }
    TemplateTransformerHandler:access(config)
    assert.spy(ngx.req.set_body_data).was_called_with(config.template)
  end)
end)