local BasePlugin = require "kong.plugins.base_plugin"
local copas = require "copas"
-- local http = require 'resty.http'
local asynchttp = require("copas.http").request
local cjson = require "cjson"
local utils = require "kong.plugins.cerberus-plugin.utils"

local MiddlewareHandler = BasePlugin:extend()

MiddlewareHandler.PRIORITY = 1006

function MiddlewareHandler:new()
  MiddlewareHandler.super.new(self, "cerberus-plugin")
end

local handler = function(host)
  res, err = asynchttp(host)
  print("Host done: "..host)
end

function MiddlewareHandler:access(config)
  MiddlewareHandler.super.access(self)

  -- local httpc = http:new()
  -- local req_headers = ngx.req.get_headers()

  local headers = {}
  headers['Content-Type'] = "application/json"

  ngx.log(ngx.NOTICE, "Building payload")
  local log_payload = {{
    AdditionalData = "data",
    ApplicationId = "data",
    MachineName = "data",
    ManagedThreadId = "data",
    ManagedThreadName = "data",
    Message = "data",
    NativeProcessId = "data",
    NativeThreadId = "data",
    OSFullName = "data",
    ProcessName = "data",
    ProcessPath = "data",
    ProductCompany = config.product_company,
    ProductName = config.product_name,
    ProductVersion = config.product_version,
    Severity = "Info",
    Tags = config.tags,
    Timestamp = os.date("!%Y-%m-%dT%H:%M:%S.0000000+00:00"),
    TypeName = "LogEntry"
  }}

  local string_payload = cjson.encode(log_payload)

  ngx.log(ngx.NOTICE, string.format("String payload: %s", string_payload))

  local handler = function(target_url)
    ngx.log(ngx.NOTICE, "starting log-request")
    asynchttp({
      url = target_url,
      method = "POST",
      ssl_verify = false,
      headers = headers,
      body = string_payload
    })
    ngx.log(ngx.NOTICE, "log-request done")
  end

  copas.addthread(handler, config.url)
  -- copas.step(5)
  copas.loop()
end

-- function MiddlewareHandler:log(config)
--   MiddlewareHandler.super.log(self)

--   local httpc = http:new()
--   local headers = {}
--   local req_headers = ngx.req.get_headers()

--   headers['Content-Type'] = "application/json"

--   -- Executa o request http http://dev-logger.stone.com.br:8733/v1/log
--   local url = config.url
--   ngx.log(ngx.DEBUG, "Executing out log-request")
--   local res, err = httpc:request_uri(config.url, {
--     method = "POST",
--     ssl_verify = false,
--     headers = headers,
--     body = string.format("{\"ApplicationKey\": %q, \"Token\": %q}", config.appKey, req_headers["token"])
--   })
-- end

return MiddlewareHandler
