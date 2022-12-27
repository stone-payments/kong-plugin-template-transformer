# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

## [1.3.0](https://github.com/stone-payments/kong-plugin-template-transformer/compare/v1.2.0...v1.3.0) (2022-12-27)


### Features

* Adds ability to bypass when proxy cache plugin has a hit ([b9ae165](https://github.com/stone-payments/kong-plugin-template-transformer/commit/b9ae16594d6a732525a46dddf528c9b49992e3ec))

## [1.2.0](https://github.com/stone-payments/kong-plugin-template-transformer/compare/v1.1.0...v1.2.0) (2022-10-03)


### Features

* Ensures compatibility with kong 3.0 ([122f628](https://github.com/stone-payments/kong-plugin-template-transformer/commit/122f628331f1960c90fc8d42593f66f8e6217bdb))

## [1.1.0](https://github.com/stone-payments/kong-plugin-template-transformer/compare/v1.0.0...v1.1.0) (2022-08-03)


### Features

* Add route_groups to the response template ([a611ce4](https://github.com/stone-payments/kong-plugin-template-transformer/commit/a611ce498a1bf4e252a7660e56ca4537c10f283d))


### Bug Fixes

* Set content length header name ([6d13a24](https://github.com/stone-payments/kong-plugin-template-transformer/commit/6d13a24b6001fecdba3196907121b3841154d002))

## [1.0.1](https://github.com/stone-payments/kong-plugin-template-transformer/compare/v1.0.0...v1.0.1) (2021-12-21)


### Bug Fixes

* Fix set content-length header.

## [1.0.0](https://github.com/stone-payments/kong-plugin-template-transformer/compare/v0.17.1...v1.0.0) (2021-12-21)


### Features

* Upgrades plugin to be kong >= 2.6.0 compatible.
* Allows non json templates.

## [0.17.2](https://github.com/stone-payments/kong-plugin-template-transformer/compare/v0.17.1...v0.17.2) (2020-12-29)


### Bug Fixes

* Fix lua-cjson version

## [0.17.1](https://github.com/stone-payments/kong-plugin-template-transformer/compare/v0.17.0...v0.17.1) (2020-12-29)


### Bug Fixes

* Body Transformer must preserve empty arrays from original JSON response body

## [0.17.0](https://github.com/stone-payments/kong-plugin-template-transformer/compare/v0.16.0...v0.17.0) (2020-12-29)


### Features

* Add request query string access from response template

## [0.16.0](https://github.com/stone-payments/kong-plugin-template-transformer/compare/v0.15.0...v0.16.0) (2020-09-22)


### Features

* Add hidden_fields in context

## [0.15.0](https://github.com/stone-payments/kong-plugin-template-transformer/compare/v0.11.1...v0.15.0) (2020-04-09)


### Features

* Allow other payload formats besides JSON ([19dffd4](https://github.com/stone-payments/kong-plugin-template-transformer/commit/19dffd448307d506ff2265d1f261dc040e868646))

## [0.14.0](https://github.com/stone-payments/kong-plugin-template-transformer/tree/v0.14.0) - 2020-04-02

### Features

* Field Mask Function on template

## [0.13.0](https://github.com/stone-payments/kong-plugin-template-transformer/tree/v0.13.0) - 2020-01-17

### Features

* Allow json objects in template

## [0.12.3](https://github.com/stone-payments/kong-plugin-template-transformer/tree/v0.12.3) - 2019-10-23

### Bug Fixes

- No Content handling.

## [0.12.2](https://github.com/stone-payments/kong-plugin-template-transformer/tree/v0.12.2) - 2019-08-15

### Bug Fixes

- Escape carriages and end of lines.

## [0.12.1](https://github.com/stone-payments/kong-plugin-template-transformer/tree/v0.12.1) - 2019-07-19

### Features

- JSON examples folder and validator.

## [0.12.0](https://github.com/stone-payments/kong-plugin-template-transformer/tree/v0.12.0) - 2019-07-10

### Bug Fixes

- Escape tabs.

## [0.11.1](https://github.com/stone-payments/kong-plugin-template-transformer/tree/v0.11.1) - 2019-06-21

### Bug Fixes

- Escape bars.

## [0.11.0](https://github.com/stone-payments/kong-plugin-template-transformer/tree/v0.11.0) - 2019-05-22

### Bug Fixes

- Remove luajit and set lua version to 5.1.

## [0.10.1](https://github.com/stone-payments/kong-plugin-template-transformer/tree/v0.10.1) - 2019-05-17

### Bug Fixes

- Special characters scaped in body_filter.

## [0.10.0](https://github.com/stone-payments/kong-plugin-template-transformer/tree/v0.10.0) - 2019-04-15

### Features

- Add Kong 1 support by removing kong.errors.dao

## [0.9.0](https://github.com/stone-payments/kong-plugin-template-transformer/tree/v0.9.0) - 2019-01-18

### Features

- Dockerfile to simplify development
- Raw_body to template context

## [0.8.0](https://github.com/stone-payments/kong-plugin-template-transformer/tree/v0.8.0) - 2018-10-30

### Features

- Travis for CI/CD

## [0.7.2](https://github.com/stone-payments/kong-plugin-template-transformer/tree/v0.7.2) - 2018-10-10

### Bug Fixes

- Execution of templates when they are empty strings.

## [0.7.1](https://github.com/stone-payments/kong-plugin-template-transformer/tree/v0.7.1) - 2018-10-02

### Bug Fixes

- Read JSON only when the payload is not an empty string.

## [0.7.0](https://github.com/stone-payments/kong-plugin-template-transformer/tree/v0.7.0) - 2018-09-20

### Bug Fixes

- Log severities to better represent information.

## [0.6.0](https://github.com/stone-payments/kong-plugin-template-transformer/tree/v0.6.0) - 2018-08-28

### Features

- Configuration variable hide fields and not log them.

## [0.5.0](https://github.com/stone-payments/kong-plugin-template-transformer/tree/v0.5.0) - 2018-07-09

### Features

- Adds ngx.ctx.custom_data to template information.

## [0.4.0](https://github.com/stone-payments/kong-plugin-template-transformer/tree/v0.4.0) - 2018-05-23

### Bug Fixes

- Params validation that was not been called.
- Empty body with request_templates that were broken.
- Special characters in request-templates.

### Changed

- Package name in rockspec.

## [0.3.0](https://github.com/stone-payments/kong-plugin-template-transformer/tree/v0.3.0) - 2018-05-17

### Bug Fixes

- Stops relying on content-type header and tries to parse the response from the API, returning bad request if not possible
- Passes body to the request table as a table, not string

## [0.2.2](https://github.com/stone-payments/kong-plugin-template-transformer/tree/v0.2.2) - 2018-05-10

### Features

- Status-code as an argument to templates.

### Bug Fixes

- Only reads response body as JSON when content-type is correct.

### Removed

- Template files

## [0.2.1](https://github.com/stone-payments/kong-plugin-template-transformer/tree/v0.2.1) - 2018-05-04

### Bug Fixes

- Template transformer import

## [0.2.0](https://github.com/stone-payments/kong-plugin-template-transformer/tree/v0.2.0) - 2018-04-24

### Features

- Can use regex uri patterns inside the templates.
- VSTS support.

## [0.1.0](https://github.com/stone-payments/kong-plugin-template-transformer/tree/v0.1.0) - 2018-04-16

### Features

- First version of the template transformer plugin
