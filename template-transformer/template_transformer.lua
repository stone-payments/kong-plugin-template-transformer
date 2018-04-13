local template = require 'resty.template'

_M = {}

_M.transform = function(template, args)
    ngx.log(ngx.DEBUG, string.format("Template :: %s", template))
    local compiled_template = template.compile(template)
    local transformed_body = compiled_template{args}
    ngx.log(ngx.DEBUG, string.format("Rendered Template :: %s", transformed_body))
    return transformed_body
end

return _M