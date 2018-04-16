local resty_template = require 'resty.template'

_M = {}

_M.transform = function(template, ...)
    ngx.log(ngx.DEBUG, string.format("Template :: %s", template))
    local compiled_template = resty_template.compile(template)
    local args = ...
    if not args then
        args = {}
    end
    local transformed_body = compiled_template{query_string = args.query_string, headers = args.headers, body = args.body}
    ngx.log(ngx.DEBUG, string.format("Rendered Template :: %s", transformed_body))
    return transformed_body
end

return _M