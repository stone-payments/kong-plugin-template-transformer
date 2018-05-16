local ngx =  {
    req = {
        set_body_data = spy.new(function() end),
        get_body_data =  spy.new(function() return '{ "data": "oi2" }' end),
        get_uri_args = spy.new(function() return { query = "oi1" } end),
        set_header = spy.new(function() end),
        get_headers = spy.new(function() return { my_cool_header = "oi3" } end),
        read_body = spy.new(function() end),
    },
    resp = {
        get_headers = spy.new(function() return { my_cool_header = "oi3" } end)
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
    log = spy.new(function() end),
    ctx = {
        router_matches = { uri_captures = {group_one = "oi4" } }
    },
    status = 200,
}
_G.ngx = ngx
local TemplateTransformerHandler = require('../handler')

describe("TestHandler", function()
  it("should test handler constructor", function()
    TemplateTransformerHandler:new()
    assert.equal("template-transformer", TemplateTransformerHandler._name)
  end)

  it("should not call set body data when there is no template", function()
    TemplateTransformerHandler:new()
    local config = {}
    TemplateTransformerHandler:access(config)
    assert.spy(ngx.req.set_body_data).was_called(0)
  end)

  it("should test replace with template without variables", function()
    TemplateTransformerHandler:new()
    local config = {
        request_template = "hello im a template"
    }
    TemplateTransformerHandler:access(config)
    assert.spy(ngx.req.set_body_data).was_called(1)
    assert.spy(ngx.req.set_body_data).was_called_with(config.request_template)
  end)

  it("should test replace with template with variables", function()
    TemplateTransformerHandler:new()
    local config = {
        request_template = "{{query_string['query']}} {{body['data']}} {{headers['my_cool_header']}} {{route_groups['group_one']}}"
    }
    TemplateTransformerHandler:access(config)
    assert.spy(ngx.req.set_body_data).was_called(2)
    assert.spy(ngx.req.set_body_data).was_called_with("oi1 oi2 oi3 oi4")
  end)

  it("should test body filter when body is not ready yet", function()
    TemplateTransformerHandler:new()
    local config = {
        response_template = "hello im a template"
    }
    _G.ngx.arg = {'{ "key" : "value" }', false}
    TemplateTransformerHandler:body_filter(config)
    assert.equal(ngx.arg[1], nil)
  end)

  it("should test body filter when body is ready", function()
    TemplateTransformerHandler:new()
    local config = {
        response_template = "hello i am a template"
    }
    _G.ngx.ctx.buffer = 'oi'
    _G.ngx.arg = {'{ "key" : "value" }', true}
    TemplateTransformerHandler:body_filter(config)
    assert.equal(config.response_template, ngx.arg[1])
  end)

  it("should prepare_body as expected", function()
    prepared_body = prepare_body("&amp &lt &gt &quot &#39 &#47 /;")
    assert.equal(prepared_body, "& < > \" ' / /")
  end)

  it("should pass status code to template", function()
    TemplateTransformerHandler:new()
    local config = {
        response_template = "template with status = {{status}}"
    }
    TemplateTransformerHandler:body_filter(config)
    assert.equal("template with status = 200", ngx.arg[1])
  end)

end)
