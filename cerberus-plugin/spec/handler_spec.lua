-- Mock ngx
local ngx =  {
    req = {
        get_method = spy.new(function() end),
        get_body_data =  spy.new(function() end),
        get_uri_args = spy.new(function() end),
        get_headers = spy.new(function() end),
    },
    config = {
        ngx_lua_version = "1"
    },
    log = spy.new(function() end),
    timer = {
        at = spy.new(function() end)
    },
    re = {match = spy.new(function() end)},
    socket = {tcp = spy.new(function() end)},
    ctx = {}
}
_G.ngx = ngx

-- Mock http
local mock_client = {
        request_uri = spy.new(function() end)
}
local new_http_client =  spy.new(function() return mock_client end)

local LogRequestHandler = require('../handler')
_G.new_http_client = new_http_client

-- tests
describe("TestHandler", function()

  it("should test handler constructor", function()
    LogRequestHandler:new()
    assert.equal("cerberus-plugin", LogRequestHandler._name)
  end)

  it("should test call of ngx timer", function()
    LogRequestHandler:new()
    assert.equal("cerberus-plugin", LogRequestHandler._name)
    config = {
        url = "url",
        product_company = "productcompany",
        product_name = "productname",
        product_version = "product_version",
        tags = {}
    }
    LogRequestHandler:access(config)
    assert.spy(ngx.req.get_method).was_called_with()
    assert.spy(ngx.req.get_headers).was_called_with()
    assert.spy(ngx.req.get_uri_args).was_called_with()
    assert.spy(ngx.req.get_body_data).was_called_with()
    assert.spy(ngx.timer.at).was_called(1)
  end)

  it("should test log function does not executes http request", function()
    LogRequestHandler:new()
    send_log_request(1, "http://mock.com", "payload")
    assert.spy(mock_client.request_uri).was_called(0)
  end)

  it("should test log function executes http request", function()
    LogRequestHandler:new()
    send_log_request(nil, "http://mock.com", "payload")
    assert.spy(mock_client.request_uri).was_called(1)
  end)

end)
