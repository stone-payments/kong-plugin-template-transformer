local BasePlugin = require 'kong.plugins.base_plugin'
local http = require 'resty.http'
local cjson = require 'cjson'
local template = require 'resty.template'

local req_read_body = ngx.req.read_body
local req_set_body_data = ngx.req.set_body_data
local req_get_body_data = ngx.req.get_body_data
local req_set_header = ngx.req.set_header
local log = ngx.log
local TemplateTransformerHandler = BasePlugin:extend()

TemplateTransformerHandler.PRIORITY = 1006

function TemplateTransformerHandler:new()
  TemplateTransformerHandler.super.new(self, 'template-transformer')
end

function TemplateTransformerHandler:access(config)
  TemplateTransformerHandler.super.access(self)
  log(ngx.NOTICE, string.format("Template :: %s", config.template))
  local compiled_template = template.compile(config.template)
  req_read_body()
  -- local body = req_get_body_data()
  local transformed_body = compiled_template{affiliationCode = "123456789" }
  log(ngx.NOTICE, string.format("Rendered Template :: %s", transformed_body))
  req_set_body_data(transformed_body)
  req_set_header(CONTENT_LENGTH, #transformed_body)
end

TemplateTransformerHandler.PRIORITY = 801

return TemplateTransformerHandler