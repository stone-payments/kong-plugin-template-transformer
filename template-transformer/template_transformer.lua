local resty_template = require 'resty.template'

_M = {}

_M.get_template = function(template)
    ngx.log(ngx.NOTICE, string.format("Template :: %s", template))
    return resty_template.compile(template)
end

return _M