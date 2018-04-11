package = "cerberus-plugin"
version = "0.0.0-1"
source = {
   url = "https://github.com/stone-payments/kong-middlewares",
}
description = {
  summary = "A Kong plugin that enables services to act as middlewares for requests",
  license = "MIT"
}
dependencies = {
  "lua >= 5.1",
  "lua-resty-http",
  "copas"
}
build = {
   type = "builtin",
   modules = {
    ["kong.plugins.cerberus-plugin.handler"] = "./handler.lua",
    ["kong.plugins.cerberus-plugin.utils"] = "./utils.lua",
    ["kong.plugins.cerberus-plugin.schema"] = "./schema.lua"
   }
}
