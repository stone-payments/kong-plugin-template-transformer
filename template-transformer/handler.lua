local BasePlugin = require 'kong.plugins.base_plugin'
local cjson_decode = require('cjson').decode
local cjson_encode = require('cjson').encode

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

local template_transformer = require 'template_transformer'

local function read_json_body(body)
  if body then
    local status, res = pcall(cjson_decode, body)
    if status then
      return res
    end
  end
end

local function prepare_body(body)
  local v = cjson_encode(body)
  if sub(v, 1, 1) == [["]] and sub(v, -1, -1) == [["]] then
    v = gsub(sub(v, 2, -2), [[\"]], [["]]) -- To prevent having double encoded quotes
  end
  v = gsub(v, [[\/]], [[/]]) -- To prevent having double encoded slashes

  -- Resty-Template Escaped characters
  -- https://github.com/bungle/lua-resty-template#a-word-about-html-escaping
  v = gsub(v, "&amp", "&")
  v = gsub(v, "&lt", "<")
  v = gsub(v, "&gt", ">")
  v = gsub(v, "&quot", "\"")
  v = gsub(v, "&#39", "\'")
  v = gsub(v, "&#47", "/")
  v = gsub(v, "/;", "/")

  ngx.log(ngx.NOTICE, string.format("Encoded Body :: %s", v))
  return v
end

function TemplateTransformerHandler:new()
  TemplateTransformerHandler.super.new(self, 'template-transformer')
end

function TemplateTransformerHandler:access(config)
  TemplateTransformerHandler.super.access(self)
  if config.request_template then
    req_read_body()
    local body = req_get_body_data()
    local headers = req_get_headers()
    local query_string = req_get_uri_args()
    local router_matches = ngx.ctx.router_matches



    local transformed_body = template_transformer.get_template(config.request_template){query_string = query_string,
                                                                                        headers = headers,
                                                                                        body = body,
                                                                                        route_groups = router_matches.uri_captures}
    ngx.log(ngx.NOTICE, string.format("Transformed Body :: %s", transformed_body))
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
      ngx.log(ngx.NOTICE, string.format("Body :: %s", ngx.ctx.buffer))
      local body = read_json_body(ngx.ctx.buffer)
      local headers = res_get_headers()
      local transformed_body = template_transformer.get_template(config.response_template){headers = headers, body = body}
      ngx.log(ngx.NOTICE, string.format("Transformed Body :: %s", transformed_body))
      ngx.arg[1] = prepare_body(transformed_body)
    end
  end
end

TemplateTransformerHandler.PRIORITY = 801

return TemplateTransformerHandler