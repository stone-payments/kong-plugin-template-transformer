# kong-middlewares
Kong API Gateway middlewares repository

- [template-transformer](./template-transformer) - Template transformer plugin to allow complex transformation of requests and responses
- [cerberus-plugin](./cerberus-plugin)  - Cerberus Logger plugin

# project structure

Each folder has a similar structure, and it should contain at least a `schema.lua` and a `handler.lua`, alongside with a `spec` folder and a `.rockspec` file specifying the current version of the package.

# rockspec format

The `.rockspec` file should follow [LuaRocks' conventions](https://github.com/luarocks/luarocks/wiki/Rockspec-format)

# testing

We're using [busted](http://olivinelabs.com/busted) to run our tests. Every test file should live in a `spec` folder and end with `_spec.lua`.

## running the tests

`make test PROJECT=your-plugin-folder` or `busted spec/` in the plugin folder should do the job.

remember to run it as super user if your current environment needs it.

## test coverage

If you're using our Makefile, just run `make coverage PROJECT=your-plugin-folder`.

With Busted, a `-c` flag will do the job.
It will generate a `luacov.stats.out` that you can use to generate coverage reports.
You can run `luacov` and it will generate a `luacov.report.out` containing a comprehensive coverage report.

## lint

`make lint PROJECT=your-plugin-folder` or `luacheck spec/` in the plugin folder should run the linter.
