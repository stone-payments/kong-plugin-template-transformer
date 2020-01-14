local resty_template = require 'resty.template'
local cjson_encode = require('cjson').encode

_M = {}

_M.get_template = function(template, body)
    fields = {}

    -- Obtem todos os campos do template
    for field in string.gmatch(template, '{{(.-)}}') do
        field = string.gsub(field, " ", "")
        table.insert(fields, field)
    end

    -- percorre campos template e substitui tags pelo objeto json caso seja do tipo table
    for idx, field in pairs(fields) do
        -- atribui a tabela inteira do body na variavel
        var = body

        -- somente substitui tags iniciadas em body para manter compatibilidade com resty templates
        x_body, y_body = string.find(field, "body")
        x_point, y_point = string.find(field, "body%.")
        x_total, y_total = string.find(field, "body.")

        if ((x_body == 1 and y_body == 4) and not x_point and not y_point and not x_total and not y_total) or
            ((x_body == 1 and y_body == 4) and (x_point == 1 and y_point == 5) and (x_total == 1 and y_total == 5)) then
            f = {}

            -- separa campos de cada tag contendo .
            for value in string.gmatch(field, '([^.]+)') do
                -- elimina o campo body dessa lista
                if not string.find(value, "body") then
                    table.insert(f, value)
                end
            end
            
            -- verifica se se expande body inteiro ou se filtra campos do body de acordo com a tag
            if #f > 0 then
                for i, d in pairs(f) do
                    var = var[d]
                end
            end

            if type(var) == 'table' then
                data = cjson_encode(var)
                template, ret = string.gsub(template, string.format('\"{{ %s }}\"', field), data)
            end
        end
    end
    return resty_template.compile(template)
end

return _M
