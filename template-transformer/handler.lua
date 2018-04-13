local BasePlugin = require 'kong.plugins.base_plugin'
local template = require 'resty.template'
local cjson_decode = require("cjson").decode
local cjson_encode = require("cjson").encode

local req_set_body_data = ngx.req.set_body_data
local req_get_body_data = ngx.req.get_body_data
local req_get_uri_args = ngx.req.get_uri_args
local req_set_header = ngx.req.set_header
local req_get_headers = ngx.req.get_headers
local req_read_body = ngx.req.read_body
local res_get_headers = ngx.resp.get_headers
local table_concat = table.concat
local TemplateTransformerHandler = BasePlugin:extend()

local function read_json_body(body)
  if body then
    local status, res = pcall(cjson_decode, body)
    if status then
      return res
    end
  end
end

function TemplateTransformerHandler:new()
  TemplateTransformerHandler.super.new(self, 'template-transformer')
end

function TemplateTransformerHandler:access(config)
  TemplateTransformerHandler.super.access(self)
  if config.request_template then
    ngx.log(ngx.NOTICE, string.format("Template :: %s", config.request_template))
    local compiled_template = template.compile(config.request_template)
    req_read_body()
    local body = req_get_body_data()
    local headers = req_get_headers()
    local query_string = req_get_uri_args()
    local transformed_body = compiled_template{query_string = query_string, headers = headers, body = body}
    ngx.log(ngx.NOTICE, string.format("Rendered Template :: %s", transformed_body))
    req_set_body_data(transformed_body)
    req_set_header(CONTENT_LENGTH, #transformed_body)
  end
  config.response_template = [[{"oi" : "oi"}]]
  if config.response_template then
    local ctx = ngx.ctx
    ctx.rt_body_chunks = {}
    ctx.rt_body_chunk_number = 1
  end
end

function TemplateTransformerHandler:body_filter(config)
  TemplateTransformerHandler.super.body_filter(self)
  config.response_template = [[{"stonecode" : "{{body.args.stonecode}}"}]]
  if config.response_template then
    local ctx = ngx.ctx
    local chunk, eof = ngx.arg[1], ngx.arg[2]
    if eof then
        ngx.log(ngx.NOTICE, string.format("Template :: %s", config.response_template))
        local compiled_template = template.compile(config.response_template)
        local body = read_json_body(table_concat(ctx.rt_body_chunks))
        ngx.log(ngx.NOTICE, string.format("Body :: %s", body))
        local headers = res_get_headers()
        local transformed_body = compiled_template{body = body, headers = headers}
        ngx.log(ngx.NOTICE, string.format("Transformed Body :: %s", transformed_body))
        ngx.arg[1] = cjson_encode(transformed_body)
    else
      ctx.rt_body_chunks[ctx.rt_body_chunk_number] = chunk
      ctx.rt_body_chunk_number = ctx.rt_body_chunk_number + 1
      ngx.log(ngx.NOTICE, string.format("rt_body_chunk_number :: %s", ctx.rt_body_chunk_number))
      ngx.arg[1] = nil
    end
  end
end

TemplateTransformerHandler.PRIORITY = 801

return TemplateTransformerHandler