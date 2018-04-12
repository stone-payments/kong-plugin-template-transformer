local BasePlugin = require "kong.plugins.base_plugin"
local cjson = require "cjson"
local http = require 'resty.http'
local utils = require "kong.plugins.cerberus-plugin.utils"
local os_utils = require "kong.plugins.cerberus-plugin.os"
local lfs = require "lfs"
local unistd = require 'posix.unistd'

local MiddlewareHandler = BasePlugin:extend()

MiddlewareHandler.PRIORITY = 1006

function MiddlewareHandler:new()
  MiddlewareHandler.super.new(self, "cerberus-plugin")
end

function MiddlewareHandler:access(config)
  MiddlewareHandler.super.access(self)

  ngx.log(ngx.NOTICE, "Building payload")

  local log_payload = {{
    AdditionalData = {{
      requestMethod = ngx.req.get_method(),
      requestHeaders = ngx.req.get_headers(),
      requestUriArgs = ngx.req.get_uri_args(),
      requestBodyData = ngx.req.get_body_data(),
    }},
    MachineName = utils.getHostname(),
    ManagedThreadId = tostring( {} ):sub(8),
    Message = "Log Request",
    NativeProcessId = unistd.getpid(),
    NativeThreadId = tostring( {} ):sub(8),
    OSFullName = os_utils.getOS(),
    ProcessName = "COROUTINE STUFF AGAIN",
    ProcessPath = lfs.currentdir(),
    ProductCompany = config.product_company,
    ProductName = config.product_name,
    ProductVersion = config.product_version,
    Severity = "Info",
    Tags = config.tags,
    Timestamp = os.date("!%Y-%m-%dT%H:%M:%S.0000000+00:00"),
    TypeName = "LogEntry"
  }}

  local headers = {}
  headers['Content-Type'] = "application/json"

  local string_payload = cjson.encode(log_payload)
  ngx.log(ngx.NOTICE, string.format("String payload: %s", string_payload))

  local log = function(premature, target_url, payload)
    if premature then
      return
    end

    ngx.log(ngx.NOTICE, "starting log-request")
    local httpc = http:new()

    httpc:request_uri(target_url, {
      method = "POST",
      ssl_verify = false,
      headers = headers,
      body = payload
    })

    ngx.log(ngx.NOTICE, "log-request done")
  end

  local ok, err = ngx.timer.at(0, log, config.url, string_payload)
  if not ok then
    ngx.log(ngx.NOTICE, "errou")
  end
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
