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

local template_transformer = require 'kong.plugins.kong-plugin-template-transformer.template_transformer'
local utils = require 'kong.plugins.kong-plugin-template-transformer.utils'

function read_json_body(body)
  if body and body ~= "" then
    local status, res = pcall(cjson_decode, body)

    if status then
      return res
    end

    ngx.log(ngx.ERR, string.format("Error while decoding %s :: %s", body, res))
    return nil

  end
  return {}
end

function prepare_body(string_body)
  local v = string_body
  if sub(v, 1, 1) == [["]] and sub(v, -1, -1) == [["]] then
    v = gsub(sub(v, 2, -2), [[\"]], [["]]) -- To prevent having double encoded quotes
  end
  v = gsub(v, [[\/]], [[/]]) -- To prevent having double encoded slashes

  -- Resty-Template Escaped characters
  -- https://github.com/bungle/lua-resty-template#a-word-about-html-escaping
  v = gsub(v, "&amp;", "&")
  v = gsub(v, "&lt;", "<")
  v = gsub(v, "&gt;", ">")
  v = gsub(v, "&quot;", "\"")
  v = gsub(v, "&#39;", "\'")
  v = gsub(v, "&#47;", "/")
  v = gsub(v, "/;", "/")

  return v
end

function TemplateTransformerHandler:new()
  TemplateTransformerHandler.super.new(self, 'template-transformer')
end

function TemplateTransformerHandler:access(config)
  TemplateTransformerHandler.super.access(self)
  if config.request_template and config.request_template ~= "" then
    local body = nil

    req_read_body()
    local string_body = req_get_body_data()
    if string_body then
      body = cjson_decode(prepare_body(string_body))
    end

    local headers = req_get_headers()
    local query_string = req_get_uri_args()
    local router_matches = ngx.ctx.router_matches

    local transformed_body = template_transformer.get_template(config.request_template){query_string = query_string,
                                                                                        headers = headers,
                                                                                        body = body,
                                                                                        custom_data = ngx.ctx.custom_data,
                                                                                        route_groups = router_matches.uri_captures}
    transformed_body = prepare_body(transformed_body)

    req_set_body_data(transformed_body)
    req_set_header(CONTENT_LENGTH, #transformed_body)

    if transformed_body ~= "" then
      local json_transformed_body = cjson_decode(transformed_body)

      utils.hide_fields(json_transformed_body, config.hidden_fields)

      ngx.log(ngx.DEBUG, string.format("Transformed Body :: %s", cjson_encode(json_transformed_body)))
    end
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
  local hasResponseBodyTemplate = config.response_template and config.response_template ~= ""
  local hasResponseStatusTemplate = config.response_status_template and config.response_status_template ~= ""
  if hasResponseBodyTemplate or hasResponseStatusTemplate then
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
      local headers = res_get_headers()
      local body = read_json_body(ngx.ctx.buffer)
      if body == nil then
        return ngx.ERROR
      end

      if hasResponseBodyTemplate then
        local transformed_body = template_transformer.get_template(config.response_template){headers = headers,
                                                                                            body = body,
                                                                                            status = ngx.status}
        ngx.arg[1] = prepare_body(cjson_encode(transformed_body))

        local json_transformed_body = cjson_decode(transformed_body)
        utils.hide_fields(json_transformed_body, config.hidden_fields)

        ngx.log(ngx.DEBUG, string.format("Transformed Body :: %s", cjson_encode(json_transformed_body)))
      end

      if hasResponseStatusTemplate then
        local updatedStatus = template_transformer.get_template(config.response_status_template){headers = headers,
                                                                                            body = body,
                                                                                            status = ngx.status}
        ngx.log(ngx.DEBUG, string.format("Update status from :: %s to %s", ngx.status, updatedStatus))
        ngx.status = tonumber(updatedStatus);
      end

    end
  end
end

TemplateTransformerHandler.PRIORITY = 801

return TemplateTransformerHandler
