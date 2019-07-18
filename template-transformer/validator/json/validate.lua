local cjson_decode = require('cjson').decode

local sub = string.sub
local gsub = string.gsub

local template_transformer = require 'kong.plugins.kong-plugin-template-transformer.template_transformer'


function prepare_body(string_body)
    local v = string_body
    if sub(v, 1, 1) == [["]] and sub(v, -1, -1) == [["]] then
      v = gsub(sub(v, 2, -2), [[\"]], [["]]) -- To prevent having double encoded quotes
    end
    v = gsub(v, [[\/]], [[/]]) -- To prevent having double encoded slashes
  
    -- Resty-Template Escaped characters
    -- https://github.com/bungle/lua-resty-template#a-word-about-html-escaping
    v = gsub(v, "&amp;", "&")
    v = gsub(v, "&#9;", " ")
    v = gsub(v, "\t", " ")
    v = gsub(v, "&lt;", "<")
    v = gsub(v, "&gt;", ">")
    v = gsub(v, "&quot;", "\"")
    v = gsub(v, "&__escaped__quot;", '\\\"')
    v = gsub(v, "&__escaped__bar;", '\\\\')
    v = gsub(v, "&#39;", "\'")
    v = gsub(v, "&#47;", "/")
    v = gsub(v, "/;", "/")
  
    return v
  end

-- see if the file exists
function file_exists(file)
    local f = io.open(file, "rb")
    if f then
        f:close()
    end
    return f ~= nil
end
  
  -- get all lines from a file, returns an empty 
  -- list/table if the file does not exist
function read_file(file)
    if not file_exists(file) then
        return {}
    end
    lines = ""
    for line in io.lines(file) do 
      lines = lines .. line .. '\n'
    end
    return lines
end

function write_file(file, payload)
    -- Opens a file in append mode
    stream = io.open(file, "w+")

    -- sets the default output file
    io.output(stream)

    -- appends a word test to the last line of the file
    io.write(payload)

    -- closes the open file
    io.close(stream)
end
  
-- tests the functions above
local file = arg[2]
local transformed_body = template_transformer.get_template(arg[1]){body = cjson_decode(read_file(file))}

local prepared_body = prepare_body(transformed_body)
local json_transformed_body = cjson_decode(prepared_body)
write_file(arg[3], prepared_body)