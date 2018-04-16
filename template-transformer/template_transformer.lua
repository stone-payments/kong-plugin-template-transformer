local resty_template = require 'resty.template'

_M = {}

_M.get_template = function(template, args)
    ngx.log(ngx.NOTICE, string.format("Template :: %s", template))
    local compiled_template = resty_template.compile(template)
    if not args then
        args = {}
    end
    return compiled_template
end

return _M