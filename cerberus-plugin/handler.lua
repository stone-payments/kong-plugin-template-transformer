local BasePlugin = require "kong.plugins.base_plugin"
local cjson = require "cjson"
local http = require "resty.http"
local lfs = require "lfs"
local os_utils = require "kong.plugins.cerberus-plugin.os"
local unistd = require "posix.unistd"
local utils = require "kong.plugins.cerberus-plugin.utils"

local LogRequestHandler = BasePlugin:extend()

LogRequestHandler.PRIORITY = 850

function new_http_client()
  return http:new()
end

function send_log_request(premature, target_url, payload)
  if premature then
    return
  end

  local headers = {}
  headers['Content-Type'] = "application/json"

  httpc = new_http_client()

  ngx.log(ngx.NOTICE, "Starting log-request")
  httpc:request_uri(target_url, {
    method = "POST",
    ssl_verify = false,
    headers = headers,
    body = payload
  })

  ngx.log(ngx.NOTICE, "Log-request done")
end

function build_log_payload(config)
  ngx.log(ngx.NOTICE, "Building log payload")

  return {{
    MachineName = utils.getHostname(),
    ManagedThreadId = tostring( {} ):sub(8),
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
end

function LogRequestHandler:new()
  LogRequestHandler.super.new(self, "cerberus-plugin")
end

function LogRequestHandler:access(config)
  LogRequestHandler.super.access(self)

  local log_payload = build_log_payload(config)

  log_payload[1]["AdditionalData"] = {{
      requestMethod = ngx.req.get_method(),
      requestHeaders = ngx.req.get_headers(),
      requestUriArgs = ngx.req.get_uri_args(),
      requestBodyData = ngx.req.get_body_data(),
      route = ngx.ctx.route,
      service = ngx.ctx.service,
      api = ngx.ctx.api,
  }}
  log_payload[1]["Message"] = "Log Kong Request"


  local string_payload = cjson.encode(log_payload)
  ngx.log(ngx.NOTICE, string.format("Log request payload: %s", string_payload))

  local ok, err = ngx.timer.at(0, send_log_request, config.url, string_payload)
  if not ok then
    ngx.log(ngx.NOTICE, err)
  end
end

function LogRequestHandler:log(conf)
  LogRequestHandler.super.log(self)

  local log_payload = build_log_payload(conf)

  log_payload[1]["AdditionalData"] = {{
      responseHeaders = ngx.header,
      responseStatus = ngx.status,
      responseBodyData = table.concat(ngx.ctx.rt_body_chunks),
      latencies = {
        kong = (ngx.ctx.KONG_ACCESS_TIME or 0) +
               (ngx.ctx.KONG_RECEIVE_TIME or 0) +
               (ngx.ctx.KONG_REWRITE_TIME or 0) +
               (ngx.ctx.KONG_BALANCER_TIME or 0),
        proxy = ngx.ctx.KONG_WAITING_TIME or -1,
        request = ngx.var.request_time * 1000
      },
  }}
  log_payload[1]["Message"] = "Log Kong Response"

  local string_payload = cjson.encode(log_payload)
  ngx.log(ngx.NOTICE, string.format("Log response payload: %s", string_payload))
  local ok, err = ngx.timer.at(0, send_log_request, conf.url, string_payload)
  if not ok then
    ngx.log(ngx.NOTICE, err)
  end
end

return LogRequestHandler
