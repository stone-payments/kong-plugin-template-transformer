local resty_template = require 'resty.template'
local utils = require 'kong.plugins.kong-plugin-template-transformer.utils'
local cjson_decode = require('cjson').decode
local cjson_encode = require('cjson').encode

_M = {}

_M.get_template = function(template, body)
    if string.find(template, '"{{body}}"') then
        data = cjson_encode(body)
        template = string.gsub(template, "\"{{body}}\"", data)
        string.gsub(template, '"{{body}}"', data)
        return resty_template.compile(template)
    else
        return resty_template.compile(template)
    end
end

return _M
