# Changelog

All changes made on any release of this project should be commented on high level of this document.

Document model based on [Semantic Versioning](http://semver.org/).
Examples of how to use this _markdown_ cand be found here [Keep a CHANGELOG](http://keepachangelog.com/).

## Unreleased
### Changed
- Package name in rockspec.

## [0.3.0](https://github.com/stone-payments/kong-plugin-template-transformer/tree/v0.3.0) - 2018-05-17
### Fixed
- Stops relying on content-type header and tries to parse the response from the API, returning bad request if not possible
- Passes body to the request table as a table, not string

## [0.2.2](https://github.com/stone-payments/kong-plugin-template-transformer/tree/v0.2.2) - 2018-05-10
### Added
- Status-code as an argument to templates.

### Fixed
- Only reads response body as JSON when content-type is correct.

### Removed
- Template files

## [0.2.1](https://github.com/stone-payments/kong-plugin-template-transformer/tree/v0.2.1) - 2018-05-04
### Fixed
- Template transformer import

## [0.2.0](https://github.com/stone-payments/kong-plugin-template-transformer/tree/v0.2.0) - 2018-04-24
### Added
- Can use regex uri patterns inside the templates.
- VSTS support.

## [0.1.0](https://github.com/stone-payments/kong-plugin-template-transformer/tree/v0.1.0) - 2018-04-16
### Added
- First version of the template transformer plugin

