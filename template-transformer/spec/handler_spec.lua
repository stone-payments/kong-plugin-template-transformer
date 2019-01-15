local mock_body = '{ "data": "payload_data" }'
local mock_ngx_headers = { ["content-length"] = 123 }
local mock_query_args = "query_args"
local mock_req_headers =  { my_cool_header = "cool_header" }
local mock_resp_headers = { ['Content-Type'] = "application/json; charset=utf-8" }
local mock_router_matches = { group_one = "test_match" }

local ngx =  {
    req = {
        set_body_data = spy.new(function() end),
        get_body_data =  spy.new(function() return mock_body end),
        get_uri_args = spy.new(function() return { query = mock_query_args } end),
        set_header = spy.new(function() end),
        get_headers = spy.new(function() return mock_req_headers end),
        read_body = spy.new(function() end),
    },
    resp = {
        get_headers =  spy.new(function() return mock_resp_headers end)
    },
    header = mock_ngx_headers,
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
        router_matches = { uri_captures = mock_router_matches },
        custom_data = { important_stuff = 123 }
    },
    status = 200,
}
_G.ngx = ngx
local TemplateTransformerHandler = require('../handler')

describe("Test TemplateTransformerHandler constructor", function()
  it("should set object name correctly", function()
    TemplateTransformerHandler:new()
    assert.equal("template-transformer", TemplateTransformerHandler._name)
  end)
end)

describe("Test TemplateTransformerHandler header_filter", function()
  it("should not unset content-length header when there is no templates", function()
    TemplateTransformerHandler:new()
    local config = {}
    TemplateTransformerHandler:header_filter(config)
    assert.equal(mock_ngx_headers["content-length"], 123)
  end)

  it("should unset content-length header when there is only response_template", function()
    TemplateTransformerHandler:new()

    local config = {
        response_template = "hello im a template"
    }
    TemplateTransformerHandler:header_filter(config)
    assert.is_nil(mock_ngx_headers["content-length"])

    mock_ngx_headers["content-length"] = 123
  end)

  it("should not unset content-length header when there is no response_template", function()
    TemplateTransformerHandler:new()
    local config = {
        request_template = "hello im a template"
    }
    TemplateTransformerHandler:header_filter(config)
    assert.equal(mock_ngx_headers["content-length"], 123)
  end)

  it("should unset content-length header when there is response_template and request_template", function()
    TemplateTransformerHandler:new()

    local config = {
        request_template = "hello im a template",
        response_template = "hello im a template"
    }
    TemplateTransformerHandler:header_filter(config)
    assert.is_nil(mock_ngx_headers["content-length"])

    mock_ngx_headers["content-length"] = 123
  end)

end)

describe("Test TemplateTransformerHandler access", function()

  it("should not call set body data when there is no template", function()
    TemplateTransformerHandler:new()
    local config = {}
    TemplateTransformerHandler:access(config)
    assert.spy(ngx.req.set_body_data).was_not_called()
  end)

  it("should not call set body data when the template is an empty string", function()
    TemplateTransformerHandler:new()
    local config = {
      request_template = ""
    }
    TemplateTransformerHandler:access(config)
    assert.spy(ngx.req.set_body_data).was_not_called()
  end)

  it("should set the request body when there is a request template with no variables", function()
    TemplateTransformerHandler:new()
    local config = {
        request_template = "{\"hello\": \"im a template\"}"
    }
    TemplateTransformerHandler:access(config)
    assert.spy(ngx.req.set_body_data).was_called_with(config.request_template)
  end)

  it("should build the request body correctly when there is a request template with custom variables", function()
    TemplateTransformerHandler:new()
    local config = {
        request_template = "{ \"{{query_string['query']}}\": 1, \"{{body['data']}}\": 2, \"{{headers['my_cool_header']}}\": 3, \"{{route_groups['group_one']}}\": 4 }"
    }
    TemplateTransformerHandler:access(config)
    assert.spy(ngx.req.set_body_data).was_called_with("{ \"query_args\": 1, \"payload_data\": 2, \"cool_header\": 3, \"test_match\": 4 }")
  end)

  it("should build the request body without error when query args have special characters", function()
    local query_args = mock_query_args
    mock_query_args = "& < > \\\" ' / /"
    TemplateTransformerHandler:new()
    local config = {
        request_template = "{ \"query\": \"{{query_string['query']}}\" }"
    }
    TemplateTransformerHandler:access(config)
    assert.spy(ngx.req.set_body_data).was_called_with("{ \"query\": \"& < > \\\" ' / /\" }")
    mock_query_args = query_args
  end)

  it("should build the request body without error when query args are missing", function()
    local query_args = mock_query_args
    mock_query_args = ""
    TemplateTransformerHandler:new()
    local config = {
        request_template = "{ \"query\": \"{{query_string['query']}}\", \"data\": \"{{body['data']}}\", \"header\": \"{{headers['my_cool_header']}}\", \"matches\": \"{{route_groups['group_one']}}\" }"
    }
    TemplateTransformerHandler:access(config)
    assert.spy(ngx.req.set_body_data).was_called_with("{ \"query\": \"\", \"data\": \"payload_data\", \"header\": \"cool_header\", \"matches\": \"test_match\" }")
    mock_query_args = query_args
  end)

  it("should build the request body without error when header is missing", function()
    local old_headers = mock_req_headers
    mock_req_headers = {}
    TemplateTransformerHandler:new()
    local config = {
        request_template = "{ \"query\": \"{{query_string['query']}}\", \"data\": \"{{body['data']}}\", \"header\": \"{{headers['my_cool_header']}}\", \"matches\": \"{{route_groups['group_one']}}\" }"
    }
    TemplateTransformerHandler:access(config)
    assert.spy(ngx.req.set_body_data).was_called_with("{ \"query\": \"query_args\", \"data\": \"payload_data\", \"header\": \"\", \"matches\": \"test_match\" }")
    mock_req_headers = old_headers
  end)

  it("should build the request body without error when payload data is missing", function()
    local old_body = mock_body
    mock_body = '{}'
    TemplateTransformerHandler:new()
    local config = {
        request_template = "{ \"query\": \"{{query_string['query']}}\", \"data\": \"{{body['data']}}\", \"header\": \"{{headers['my_cool_header']}}\", \"matches\": \"{{route_groups['group_one']}}\" }"
    }
    TemplateTransformerHandler:access(config)
    assert.spy(ngx.req.set_body_data).was_called_with("{ \"query\": \"query_args\", \"data\": \"\", \"header\": \"cool_header\", \"matches\": \"test_match\" }")
    mock_body = old_body
  end)

  it("should build the request body with custom data", function()
    local old_body = mock_body
    mock_body = '{}'
    TemplateTransformerHandler:new()
    local config = {
        request_template = "{ \"custom_data\": \"{{custom_data['important_stuff']}}\", \"query\": \"{{query_string['query']}}\", \"data\": \"{{body['data']}}\", \"header\": \"{{headers['my_cool_header']}}\", \"matches\": \"{{route_groups['group_one']}}\" }"
    }
    TemplateTransformerHandler:access(config)
    assert.spy(ngx.req.set_body_data).was_called_with("{ \"custom_data\": \"123\", \"query\": \"query_args\", \"data\": \"\", \"header\": \"cool_header\", \"matches\": \"test_match\" }")
    mock_body = old_body
  end)

end)

describe("Test TemplateTransformerHandler body_filter", function()

  it("should not run when response template is empty", function()
    TemplateTransformerHandler:new()
    local config = {
        response_template = ""
    }
    _G.ngx.arg = {'{ "key" : "value" }', false}
    TemplateTransformerHandler:body_filter(config)
    assert.spy(ngx.resp.get_headers).was_not_called()
    assert.equal('{ "key" : "value" }', ngx.arg[1])
    assert.equal(200, ngx.status)
  end)

  it("should set first ngx arg to nil when body is not fully read", function()
    TemplateTransformerHandler:new()
    local config = {
        response_template = "hello im a template"
    }
    _G.ngx.arg = {'{ "key" : "value" }', false}
    TemplateTransformerHandler:body_filter(config)
    assert.is_nil(ngx.arg[1])
    assert.equal(200, ngx.status)
  end)

  it("should set first ngx arg to template when when body is fully read and there is no custom variables", function()
    TemplateTransformerHandler:new()
    local config = {
        response_template = "{ \"template\": 123 }"
    }
    _G.ngx.ctx.buffer = '{ "body"  : "sent" }'
    _G.ngx.arg = {'{ "key" : "value" }', true}
    TemplateTransformerHandler:body_filter(config)
    assert.equal(config.response_template, ngx.arg[1])
    assert.equal(200, ngx.status)
  end)

  it("should set ngx status to status_template when body is fully read", function()
    TemplateTransformerHandler:new()
    local config = {
        response_status_template = "{{body.carrots}}"
    }
    _G.ngx.ctx.buffer = '{ "carrots" : "401" }'
    _G.ngx.arg = {'{ "key" : "value" }', true}
    TemplateTransformerHandler:body_filter(config)
    assert.equal(401, ngx.status)
  end)


  it("should pass status code to template", function()
    TemplateTransformerHandler:new()
    _G.ngx.status = 200
    local config = {
        response_template = "{ \"status\": {{status}} }"
    }
    TemplateTransformerHandler:body_filter(config)
    assert.equal("{ \"status\": 200 }", ngx.arg[1])
  end)

  it("should build first ngx arg correctly when body is fully read with custom variables", function()
    TemplateTransformerHandler:new()
    mock_resp_headers = {}
    _G.ngx.ctx.buffer = '{ "foo" : "bar" }'
    local config = {
        response_template = '{ "data" : "{{body.foo}}" }'
    }
    TemplateTransformerHandler:body_filter(config)
    assert.equal('{ "data" : "bar" }', ngx.arg[1])
  end)

  it("should call and return ngx error when body is ready and not JSON", function()
    TemplateTransformerHandler:new()
    mock_resp_headers = {}
    ngx.arg[1] = nil
    ngx.ERROR = "error"
    local config = {
        response_template = '{ "bar" : "{{body.foo}}" }'
    }
    _G.ngx.ctx.buffer = '<html>'
    actual = TemplateTransformerHandler:body_filter(config)
    assert.equal(ngx.ERROR, actual)
    assert.is_nil(ngx.arg[1])
  end)

  it("should leave empty string when there is no field in response", function()
    TemplateTransformerHandler:new()
    mock_resp_headers = {}
    ngx.arg[1] = nil
    ngx.ERROR = "error"
    local config = {
        response_template = '{ "bar" : "{{body.foo}}" }'
    }
    _G.ngx.ctx.buffer = nil
    TemplateTransformerHandler:body_filter(config)
    assert.equal('{ "bar" : "" }', ngx.arg[1])
  end)
end)

describe("Test read_json_body", function()
  it("should return nil when payload is not a JSON", function()
    actual = read_json_body("{ , }")
    assert.is_nil(actual)
  end)

  it("should return empty table when there is no payload", function()
    actual = read_json_body()
    assert.same(actual, {})
  end)

  it("should return empty table when the payload is an empty string", function()
    actual = read_json_body("")
    assert.same(actual, {})
  end)

  it("should return filled table when there is a JSON payload", function()
    actual = read_json_body("{\"abc\": 123}")
    assert.same(actual, {["abc"] = 123})
  end)
end)

describe("Test prepare_body", function()
  it("should replace strings as expected", function()
    prepared_body = prepare_body("&amp; &lt; &gt; &quot; &#39; &#47; /;")
    assert.equal(prepared_body, "& < > \" ' / /")
  end)

end)
