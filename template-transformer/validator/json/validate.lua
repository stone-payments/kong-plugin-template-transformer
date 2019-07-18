-- http://lua-users.org/wiki/FileInputOutput

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
local file = arg[1]
write_file(arg[2], read_file(file))