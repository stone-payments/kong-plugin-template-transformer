local BasePlugin = require "kong.plugins.base_plugin"
local http = require 'resty.http'
local cjson = require "cjson"

local Handler = BasePlugin:extend()

Handler.PRIORITY = 1006

function Handler:new()
  Handler.super.new(self, "template-transformer")
end

function Handler:access(config)
  Handler.super.access(self)
end

return Handler