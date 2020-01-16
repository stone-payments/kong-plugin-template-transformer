local resty_template = require 'resty.template'
local cjson_encode = require('cjson').encode

_M = {}

_M.get_template = function(template)
    return resty_template.compile(template)
end

return _M
