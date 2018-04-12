local BasePlugin = require 'kong.plugins.base_plugin'
local template = require 'resty.template'

local req_set_body_data = ngx.req.set_body_data
local req_get_body_data = ngx.req.get_body_data
local req_get_uri_args = ngx.req.get_uri_args
local req_set_header = ngx.req.set_header
local req_get_headers = ngx.req.get_headers
local req_read_body = ngx.req.read_body
local TemplateTransformerHandler = BasePlugin:extend()

function TemplateTransformerHandler:new()
  TemplateTransformerHandler.super.new(self, 'template-transformer')
end

function TemplateTransformerHandler:access(config)
  TemplateTransformerHandler.super.access(self)
  ngx.log(ngx.NOTICE, string.format("Template :: %s", config.template))
  local compiled_template = template.compile(config.template)
  req_read_body()
  local body = req_get_body_data()
  local headers = req_get_headers()
  local query_string = req_get_uri_args()
  local transformed_body = compiled_template{query_string = query_string, headers = headers, body = body}
  ngx.log(ngx.NOTICE, string.format("Rendered Template :: %s", transformed_body))
  req_set_body_data(transformed_body)
  req_set_header(CONTENT_LENGTH, #transformed_body)
end

TemplateTransformerHandler.PRIORITY = 801

return TemplateTransformerHandler