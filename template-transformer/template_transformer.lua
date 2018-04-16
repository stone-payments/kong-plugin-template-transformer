local resty_template = require 'resty.template'

_M = {}

_M.get_template = function(template)
    ngx.log(ngx.NOTICE, string.format("Template :: %s", template))
    local compiled_template = resty_template.compile(template)
    return compiled_template
end

return _M