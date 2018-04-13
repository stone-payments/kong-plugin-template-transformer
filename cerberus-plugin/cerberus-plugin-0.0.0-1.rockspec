package = "cerberus-plugin"
version = "0.0.0-1"
source = {
   url = "https://github.com/stone-payments/kong-middlewares/cerberus-plugin",
}
description = {
  summary = "A Kong plugin that enables services to act as middlewares for requests",
  license = "Apache License 2.0"
}
dependencies = {
  "lua >= 5.1",
  "lua-resty-http",
  "luaposix >= 34.0.4-1",
  "luafilesystem >= 1.7.0-2"
}
build = {
   type = "builtin",
   modules = {
    ["kong.plugins.cerberus-plugin.handler"] = "./handler.lua",
    ["kong.plugins.cerberus-plugin.utils"] = "./utils.lua",
    ["kong.plugins.cerberus-plugin.os"] = "./os.lua",
    ["kong.plugins.cerberus-plugin.schema"] = "./schema.lua"
   }
}
