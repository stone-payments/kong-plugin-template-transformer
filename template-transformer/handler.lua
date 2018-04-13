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
local sub = string.sub
local gsub = string.gsub
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
    ngx.log(ngx.DEBUG, string.format("Template :: %s", config.request_template))
    local compiled_template = template.compile(config.request_template)
    req_read_body()
    local body = req_get_body_data()
    local headers = req_get_headers()
    local query_string = req_get_uri_args()
    local transformed_body = compiled_template{query_string = query_string, headers = headers, body = body}
    ngx.log(ngx.DEBUG, string.format("Rendered Template :: %s", transformed_body))
    req_set_body_data(transformed_body)
    req_set_header(CONTENT_LENGTH, #transformed_body)
  end
  if config.response_template then
    ngx.ctx.buffer = ''
  end
end

function TemplateTransformerHandler:header_filter(config)
  if config.response_template then
    ngx.header["content-length"] = nil -- this needs to be for the content-length to be recalculated
  end
end

function TemplateTransformerHandler:body_filter(config)
  TemplateTransformerHandler.super.body_filter(self)
  if config.response_template then
    local chunk, eof = ngx.arg[1], ngx.arg[2]
    if not eof then
      -- sometimes the data comes in chunks and every chunk is a different call
      -- so we will buffer the chunks in the context
      if ngx.ctx.buffer and chunk then
        ngx.ctx.buffer = ngx.ctx.buffer .. chunk
      end
      ngx.arg[1] = nil
    else
      -- body is fully read
      ngx.log(ngx.DEBUG, string.format("Template :: %s", config.response_template))
      local compiled_template = template.compile(config.response_template)
      local body = read_json_body(ngx.ctx.buffer)
      ngx.log(ngx.DEBUG, string.format("Body :: %s", body))
      local headers = res_get_headers()
      local transformed_body = compiled_template{body = body, headers = headers}
      ngx.log(ngx.DEBUG, string.format("Transformed Body :: %s", transformed_body))
      local v = cjson_encode(transformed_body)
      if sub(v, 1, 1) == [["]] and sub(v, -1, -1) == [["]] then
        v = gsub(sub(v, 2, -2), [[\"]], [["]]) -- To prevent having double encoded quotes
      end
      v = gsub(v, [[\/]], [[/]]) -- To prevent having double encoded slashes
      ngx.log(ngx.DEBUG, string.format("Encoded Body :: %s", v))
      ngx.arg[1] = v
    end
  end
end

TemplateTransformerHandler.PRIORITY = 801

return TemplateTransformerHandler