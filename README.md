# kong-middlewares
Kong API Gateway middlewares repository

- [template-transformer](./template-transformer) - Template transformer plugin to allow complex transformation of requests and responses
- [cerberus-plugin](./cerberus-plugin)  - Cerberus Logger plugin

# project structure

Each folder has a similar structure, and it should contain at least a `schema.lua` and a `handler.lua`, alongside with a `spec` folder and a `.rockspec` file specifying the current version of the package.

# rockspec format

The `.rockspec` file should follow [LuaRocks' conventions](https://github.com/luarocks/luarocks/wiki/Rockspec-format)

