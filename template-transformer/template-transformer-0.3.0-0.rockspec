package = "template-transformer"
version = "0.3.0-0"
source = {
   url = "https://github.com/stone-payments/kong-plugin-template-transformer",
}
description = {
  summary = "A Kong plugin that enables template transforming",
  license = "Apache License 2.0"
}
dependencies = {
  "lua >= 5.1",
  "lua-resty-http",
  "lua-resty-template >= 1.9-1"
}
build = {
   type = "builtin",
   modules = {
    ["kong.plugins.template-transformer.handler"] = "./handler.lua",
    ["kong.plugins.template-transformer.schema"] = "./schema.lua",
    ["kong.plugins.template-transformer.template_transformer"] = "./template_transformer.lua"
   }
}
