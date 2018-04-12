-- Mock ngx
local ngx =  {
    req = {
        set_body_data = spy.new(function() end),
        get_body_data =  spy.new(function() return { data = "oi2" } end),
        get_uri_args = spy.new(function() return { query = "oi1" } end),
        set_header = spy.new(function() end),
        get_headers = spy.new(function() return { my_cool_header = "oi3" } end),
        read_body = spy.new(function() end),
    },
    config = {
        prefix = spy.new(function()
            return "mock"
        end),
        ngx_lua_version = "1"
    },
    location = {
        capture = spy.new(function() end)
    },
    get_phase = spy.new(function() end),
    log = spy.new(function() end),
    timer = spy.new(function() end),
    re = spy.new(function() end),
    socket = spy.new(function() end)
}
_G.ngx = ngx
local LogRequestHandler = require('../handler')

-- tests
describe("TestHandler", function()
  it("should test handler constructor", function()
    LogRequestHandler:new()
    assert.equal("cerberus-plugin", LogRequestHandler._name)
  end)
end)