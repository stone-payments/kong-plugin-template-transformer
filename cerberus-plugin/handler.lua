local BasePlugin = require "kong.plugins.base_plugin"
local cjson = require "cjson"
local http = require "resty.http"
local lfs = require "lfs"
local os_utils = require "kong.plugins.cerberus-plugin.os"
local unistd = require "posix.unistd"
local utils = require "kong.plugins.cerberus-plugin.utils"

local LogRequestHandler = BasePlugin:extend()

LogRequestHandler.PRIORITY = 850

function log(premature, target_url, payload, httpc)
  if premature then
    return
  end

  local headers = {}
  headers['Content-Type'] = "application/json"

  ngx.log(ngx.NOTICE, "Starting log-request")
  httpc:request_uri(target_url, {
    method = "POST",
    ssl_verify = false,
    headers = headers,
    body = payload
  })

  ngx.log(ngx.NOTICE, "Log-request done")
end

function LogRequestHandler:new()
  LogRequestHandler.super.new(self, "cerberus-plugin")
  self._httpc = http:new()
end

function LogRequestHandler:access(config)
  LogRequestHandler.super.access(self)

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
    ProcessName = "kong-cerberus-plugin",
    ProcessPath = lfs.currentdir(),
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

  local ok, err = ngx.timer.at(0, log, config.url, string_payload, self._httpc)
  if not ok then
    ngx.log(ngx.NOTICE, err)
  end
end

return LogRequestHandler
