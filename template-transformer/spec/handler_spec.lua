local mock_body = '{ "data": "payload_data" }'
local mock_ngx_headers = { ["content-length"] = 123 }
local mock_query_args = "query_args"
local mock_req_headers =  { my_cool_header = "cool_header" }
local mock_resp_headers = { ['Content-Type'] = "application/json; charset=utf-8" }
local mock_router_matches = { group_one = "test_match" }
local cjson_encode = require('cjson').encode
local cjson_decode = require('cjson').decode

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

describe("Test TemplateTransformerHandler header_filter", function()
  it("should not unset content-length header when there is no templates", function()
    local config = {}
    TemplateTransformerHandler:header_filter(config)
    assert.equal(mock_ngx_headers["content-length"], 123)
  end)

  it("should unset content-length header when there is only response_template", function()
    local config = {
        response_template = "hello im a template"
    }
    TemplateTransformerHandler:header_filter(config)
    assert.is_nil(mock_ngx_headers["content-length"])

    mock_ngx_headers["content-length"] = 123
  end)

  it("should not unset content-length header when there is no response_template", function()
    local config = {
        request_template = "hello im a template"
    }
    TemplateTransformerHandler:header_filter(config)
    assert.equal(mock_ngx_headers["content-length"], 123)
  end)

  it("should unset content-length header when there is response_template and request_template", function()
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
    local config = {}
    TemplateTransformerHandler:access(config)
    assert.spy(ngx.req.set_body_data).was_not_called()
  end)

  it("should not call set body data when the template is an empty string", function()
    local config = {
      request_template = ""
    }
    TemplateTransformerHandler:access(config)
    assert.spy(ngx.req.set_body_data).was_not_called()
  end)

  it("should set the request body when there is a request template with no variables", function()
    local config = {
        request_template = "{\"hello\": \"im a template\"}"
    }
    TemplateTransformerHandler:access(config)
    assert.spy(ngx.req.set_body_data).was_called_with(config.request_template)
  end)

  it("should build the request body correctly when there is a request template with custom variables", function()
    local config = {
        request_template = "{ \"{{query_string['query']}}\": 1, \"{{body['data']}}\": 2, \"{{headers['my_cool_header']}}\": 3, \"{{route_groups['group_one']}}\": 4 }"
    }
    TemplateTransformerHandler:access(config)
    assert.spy(ngx.req.set_body_data).was_called_with("{ \"query_args\": 1, \"payload_data\": 2, \"cool_header\": 3, \"test_match\": 4 }")
  end)

  it("should build the request body without error when query args have special characters", function()
    local query_args = mock_query_args
    mock_query_args = "& < > \\\" ' / /"
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
    local config = {
        request_template = "{ \"query\": \"{{query_string['query']}}\", \"data\": \"{{body['data']}}\", \"header\": \"{{headers['my_cool_header']}}\", \"matches\": \"{{route_groups['group_one']}}\" }"
    }
    TemplateTransformerHandler:access(config)
    assert.spy(ngx.req.set_body_data).was_called_with("{ \"query\": \"\", \"data\": \"payload_data\", \"header\": \"cool_header\", \"matches\": \"test_match\" }")
    mock_query_args = query_args
  end)

  it("should build the request body when wrapping the original body", function()
    local config = {
        request_template = '{ "wrapped": {{ raw_body }} }'
    }
    TemplateTransformerHandler:access(config)
    assert.spy(ngx.req.set_body_data).was_called_with('{ "wrapped": { "data": "payload_data" } }')
  end)

  it("should build the request body without error when header is missing", function()
    local old_headers = mock_req_headers
    mock_req_headers = {}
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
    local config = {
        response_template = ""
    }
    _G.ngx.arg = {'{ "key" : "value" }', false}
    TemplateTransformerHandler:body_filter(config)
    assert.spy(ngx.resp.get_headers).was_not_called()
    assert.equal('{ "key" : "value" }', ngx.arg[1])
  end)

  it("should set first ngx arg to nil when body is not fully read", function()
    local config = {
        response_template = "hello im a template"
    }
    _G.ngx.arg = {'{ "key" : "value" }', false}
    TemplateTransformerHandler:body_filter(config)
    assert.is_nil(ngx.arg[1])
  end)

  it("should set first ngx arg to template when when body is fully read and there is no custom variables", function()
    local config = {
        response_template = "{ \"template\": 123 }"
    }
    _G.ngx.ctx.buffer = '{ "body"  : "sent" }'
    _G.ngx.arg = {'{ "key" : "value" }', true}
    TemplateTransformerHandler:body_filter(config)
    assert.equal(config.response_template, ngx.arg[1])
  end)

  it("should preserve empty arrays", function()
    local config = {
      response_template = "{ \"data\": {{ cjson_encode(body) }} }"
  }
  _G.ngx.ctx.buffer = '{"p2":"v1", "a":[]}'
  TemplateTransformerHandler:body_filter(config)
  assert.equal('{ "data": {"p2":"v1","a":[]} }', ngx.arg[1])
  end)

  it("should set first ngx arg to template when using raw_body in the template", function()
    local config = {
        response_template = "{ \"wrapper\": {{ raw_body }} }"
    }
    _G.ngx.ctx.buffer = '{ "name": "fred" }'
    TemplateTransformerHandler:body_filter(config)
    assert.equal("{ \"wrapper\": { \"name\": \"fred\" } }", ngx.arg[1])
  end)

  it("should set first ngx arg to template when using route_groups in the template", function()
    local config = {
      response_template = "{ \"foo\": \"{{route_groups['group_one']}}\" }"
    }
    _G.ngx.ctx.buffer = '{ "name": "fred" }'
    TemplateTransformerHandler:body_filter(config)
    assert.equal("{ \"foo\": \"test_match\" }", ngx.arg[1])
  end)

  it("Should return string with bars", function()
    local userName = cjson_encode('im a string with \\bar')
    local config = {
      response_template = "{{ raw_body }}"
    }
    _G.ngx.ctx.buffer = '{ "name": '..userName..' }'
    _G.ngx.arg = {'{ "key" : "value" }', true}
    TemplateTransformerHandler:body_filter(config)
    assert.equal("{ \"name\": \"im a string with \\\\bar\" }", ngx.arg[1])
  end)

  it("Should return string with carriages", function()
    local userName = cjson_encode('im a string with \\r\\n')
    local config = {
      response_template = "{{ raw_body }}"
    }
    _G.ngx.ctx.buffer = '{ "name": '..userName..' }'
    _G.ngx.arg = {'{ "key" : "value" }', true}
    TemplateTransformerHandler:body_filter(config)
    assert.equal("{ \"name\": \"im a string with \\\\r\\\\n\" }", ngx.arg[1])
  end)

  it("Should return string with scaped quotes", function()
    local userName = cjson_encode('Frango "Contudo" Dentro')
    local config = {
      response_template = "{{ raw_body }}"
    }
    _G.ngx.ctx.buffer = '{ "name": '..userName..' }'
    _G.ngx.arg = {'{ "key" : "value" }', true}
    TemplateTransformerHandler:body_filter(config)
    assert.equal("{ \"name\": \"Frango \\\"Contudo\\\" Dentro\" }", ngx.arg[1])
  end)

  it("lets you include json on the fly", function()
    local config = {
        response_template = "{% local cjson_encode = require('cjson').encode  %} { \"template\": {{cjson_encode(body.thing)}} }"
    }
    _G.ngx.ctx.buffer = '{ "thing"  : {"name": "sent"} }'
    _G.ngx.arg = {'{ "key" : "value" }', true}
    TemplateTransformerHandler:body_filter(config)
    assert.equal('{"template":{"name":"sent"}}', ngx.arg[1]:gsub("%s+", ""))
  end)

  it("should pass status code to template", function()
    local config = {
        response_template = "{ \"status\": {{status}} }"
    }
    TemplateTransformerHandler:body_filter(config)
    assert.equal("{ \"status\": 200 }", ngx.arg[1])
  end)

  it("should build first ngx arg correctly when body is fully read with custom variables", function()
    mock_resp_headers = {}
    _G.ngx.ctx.buffer = '{ "foo" : "bar" }'
    local config = {
        response_template = '{ "data" : "{{body.foo}}" }'
    }
    TemplateTransformerHandler:body_filter(config)
    assert.equal('{ "data" : "bar" }', ngx.arg[1])
  end)

  it("should build first ngx arg correctly when body is fully read with table body variables", function()
    mock_resp_headers = {}
    table_data = {
      foo = {
        bar = {"into_bar", 1, 2, 3},
        bar1 = "into_bar1"
      },
      fin = "finish"
    }

    json_data = cjson_encode(table_data)
    _G.ngx.ctx.buffer = json_data
    local config = {
        response_template = '{% json_body=cjson_encode(body) %}{"data":{{json_body}}}'
    }
    TemplateTransformerHandler:body_filter(config)

    result = ngx.arg[1]
    result = cjson_decode(result)
    table.sort(result)
    result = cjson_encode(result)

    table_data = {
      data = table_data
    }
    table.sort(table_data)
    table_data = cjson_encode(table_data)

    assert.equal(result, table_data)
  end)

  it("should build first ngx arg correctly when body is fully read with table any variables", function()
    mock_resp_headers = {}
    table_data = {
      foo = {
        bar = {"into_bar", 1, 2, 3},
        bar1 = "into_bar1"
      },
      fin = "finish"
    }

    json_data = cjson_encode(table_data)
    _G.ngx.ctx.buffer = json_data
    local config = {
        response_template = '{% json_foo = cjson_encode(body.foo) %}\
                             {% json_bar = cjson_encode(body.foo.bar) %}\
                             {"data":{"foo":{{ json_foo }},"bar":{{ json_bar }} }}'
    }
    TemplateTransformerHandler:body_filter(config)

    result = ngx.arg[1]
    result = cjson_decode(result)
    table.sort(result)
    result = cjson_encode(result)

    table_data = {
      data = {
        foo = {
          bar = {"into_bar", 1, 2, 3},
          bar1 = "into_bar1"
        },
        bar = {"into_bar", 1, 2, 3}
      }
    }
    table.sort(table_data)
    table_data = cjson_encode(table_data)

    assert.equal(result, table_data)
  end)

  it("should build first ngx arg correctly when template mapps to empty string", function()
    mock_resp_headers = {}
    _G.ngx.ctx.buffer = ''
    local config = {
        response_template = '{% if true then %}{% else %}error{% end %}'
    }
    TemplateTransformerHandler:body_filter(config)
    assert.equal('', ngx.arg[1])
  end)

  it("should call and return ngx error when body is ready and not JSON", function()
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

  it("should accept raw_body when data is not in JSON format", function()
    mock_resp_headers = { ["Content-Type"] = "text/csv" }
    _G.ngx.ctx.buffer = "bar;foo\r\n1;2"
    local config = {
      response_template =  '{ "bar" : "{{body.foo}}" }',
      ignore_content_types = {
        "text/csv"
      }
    }
    TemplateTransformerHandler:body_filter(config)
    assert.equal('bar;foo\r\n1;2', ngx.arg[1])
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

    prepared_body = prepare_body("&amp; &lt; &gt; &quot; &#39; &#47; /; \t \r\n")
    assert.equal(prepared_body, "& < > \" ' / /   \\\\r\\\\n")
  end)

end)

describe("Test prepare_content_type", function()
  it("should replace strings as expected", function()
    prepared_body = prepare_content_type("application/vnd.api+json")
    assert.equal(prepared_body, "application/vnd.api%+json")

    prepared_body = prepare_content_type("application/x-www-form-urlencoded")
    assert.equal(prepared_body, "application/x%-www%-form%-urlencoded")
  end)

end)