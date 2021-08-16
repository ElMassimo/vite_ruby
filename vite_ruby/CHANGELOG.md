# [3.0.0](https://github.com/ElMassimo/vite_ruby/compare/vite_ruby@1.2.20...vite_ruby@3.0.0) (2021-08-16)

See https://github.com/ElMassimo/vite_ruby/pull/116 for features and breaking changes.

## [1.2.20](https://github.com/ElMassimo/vite_ruby/compare/vite_ruby@1.2.18...vite_ruby@1.2.20) (2021-07-30)


### Features

* use `asset_host` for Vite client if set during development ([89a338c](https://github.com/ElMassimo/vite_ruby/commit/89a338c2f23e6b43af9dadfd937fe29c82a08b10))
* Watch Windi CSS config file by default if it exists ([842c5eb](https://github.com/ElMassimo/vite_ruby/commit/842c5eb46cd12887f28ed62cb656d81645c7239c))



## [1.2.18](https://github.com/ElMassimo/vite_ruby/compare/vite_ruby@1.2.17...vite_ruby@1.2.18) (2021-07-19)

* fix: Proxy entrypoint HMR requests only after verifying the file exists (close #102) ([67c22ec](https://github.com/ElMassimo/vite_ruby/commit/67c22ec)), closes [#102](https://github.com/ElMassimo/vite_ruby/issues/102)


## [1.2.17](https://github.com/ElMassimo/vite_ruby/compare/vite_ruby@1.2.16...vite_ruby@1.2.17) (2021-07-12)

* fix: Proxy CSS Modules requests to Vite.js with the correct extension (close #98) ([8976872](https://github.com/ElMassimo/vite_ruby/commit/8976872)), closes [#98](https://github.com/ElMassimo/vite_ruby/issues/98)



## [1.2.16](https://github.com/ElMassimo/vite_ruby/compare/vite_ruby@1.2.15...vite_ruby@1.2.16) (2021-07-07)

* feat: Enable usage in engines by using `run` from the current instance ([023a61d](https://github.com/ElMassimo/vite_ruby/commit/023a61d))



## [1.2.15](https://github.com/ElMassimo/vite_ruby/compare/vite_ruby@1.2.14...vite_ruby@1.2.15) (2021-07-01)



## [1.2.14](https://github.com/ElMassimo/vite_ruby/compare/vite_ruby@1.2.13...vite_ruby@1.2.14) (2021-07-01)


### Features

* Add support for Jekyll installer ([7b942ec](https://github.com/ElMassimo/vite_ruby/commit/7b942ec745eb28092d684056b02df675ad6ececa))



## [1.2.13](https://github.com/ElMassimo/vite_ruby/compare/vite_ruby@1.2.12...vite_ruby@1.2.13) (2021-06-30)


### Features

* Improve the error message when npm packages are missing ([9159557](https://github.com/ElMassimo/vite_ruby/commit/9159557e5152547554cfe519fae8dbefe26686fb))



## [1.2.12](https://github.com/ElMassimo/vite_ruby/compare/vite_ruby@1.2.11...vite_ruby@1.2.12) (2021-06-08)


### Features

* Support Ruby 2.4 ([#87](https://github.com/ElMassimo/vite_ruby/issues/87)) ([8fc4d49](https://github.com/ElMassimo/vite_ruby/commit/8fc4d49c82817623df81d6f9f94654ea726eb050))



## [1.2.11](https://github.com/ElMassimo/vite_ruby/compare/vite_ruby@1.2.10...vite_ruby@1.2.11) (2021-05-10)

### Refactor

* Upgrade to dry-cli 0.7 while avoiding dependency on `dry-files` ([f5b87e](https://github.com/ElMassimo/vite_ruby/commit/f5b87e69790e48397d15e609b44118e399c9493d))


## [1.2.10](https://github.com/ElMassimo/vite_ruby/compare/vite_ruby@1.2.9...vite_ruby@1.2.10) (2021-05-09)


### Bug Fixes

* Lock dry-cli to 0.6 since 0.7 has breaking changes (close [#76](https://github.com/ElMassimo/vite_ruby/issues/76)) ([9883458](https://github.com/ElMassimo/vite_ruby/commit/9883458443cb0047cd4cceaf02de2a86066d624e))



## [1.2.9](https://github.com/ElMassimo/vite_ruby/compare/vite_ruby@1.2.8...vite_ruby@1.2.9) (2021-05-04)


### Bug Fixes

* Stream output during installation and don't skip installation of npm packages when no lockfile is detected ([#73](https://github.com/ElMassimo/vite_ruby/issues/73)) ([028a5ba](https://github.com/ElMassimo/vite_ruby/commit/028a5bae359085a36aa942d2ad63c23616a00ffb))



## [1.2.8](https://github.com/ElMassimo/vite_ruby/compare/vite_ruby@1.2.7...vite_ruby@1.2.8) (2021-04-29)


### Bug Fixes

* Don't modify url for minified css when proxying a request ([#71](https://github.com/ElMassimo/vite_ruby/issues/71)) ([d30a577](https://github.com/ElMassimo/vite_ruby/commit/d30a577a8436c4987d7c2e08e7eae68e589eb2a7))



## [1.2.7](https://github.com/ElMassimo/vite_ruby/compare/vite_ruby@1.2.6...vite_ruby@1.2.7) (2021-04-28)


### Bug Fixes

* Support Rails 5.1 by avoiding [incorrectly monkeypatched](https://github.com//github.com/rails/rails/blob/5-1-stable/activesupport/lib/active_support/core_ext/array/prepend_and_append.rb/issues/L2-L3) `Array#append` ([1b59551](https://github.com/ElMassimo/vite_ruby/commit/1b5955170b33a528a2b13d7e7e308e8493d97a91))



## [1.2.6](https://github.com/ElMassimo/vite_ruby/compare/vite_ruby@1.2.5...vite_ruby@1.2.6) (2021-04-26)


### Bug Fixes

* Update installation to use the latest version of the plugin ([#67](https://github.com/ElMassimo/vite_ruby/issues/67)) ([7e10636](https://github.com/ElMassimo/vite_ruby/commit/7e10636f5396f496bd099a03e069cf8572b9585b))



## [1.2.5](https://github.com/ElMassimo/vite_ruby/compare/vite_ruby@1.2.4...vite_ruby@1.2.5) (2021-04-21)


### Features

* Add helpers to enable HMR when using @vitejs/plugin-react-refresh ([a80f286](https://github.com/ElMassimo/vite_ruby/commit/a80f286d4305bbae29ea7cea42a4329a530f43fa))



## [1.2.4](https://github.com/ElMassimo/vite_ruby/compare/vite_ruby@1.2.3...vite_ruby@1.2.4) (2021-04-21)


### Bug Fixes

* Avoid removing `base` from proxied requests to avoid confusion. ([25f79a9](https://github.com/ElMassimo/vite_ruby/commit/25f79a9848df3e6c2ffbeb9bd4fbc44f73e4c68a))



## [1.2.3](https://github.com/ElMassimo/vite_ruby/compare/vite_ruby@1.2.2...vite_ruby@1.2.3) (2021-04-15)


### Features

* Add support for .scss, .less, and .styl entrypoints (close [#50](https://github.com/ElMassimo/vite_ruby/issues/50)) ([bb1d295](https://github.com/ElMassimo/vite_ruby/commit/bb1d2953b3a8c5862d26cdfcd5edc5cc918d1c5a))



## [1.2.2](https://github.com/ElMassimo/vite_ruby/compare/vite_ruby@1.2.1...vite_ruby@1.2.2) (2021-03-20)


### Bug Fixes

* Avoid prompts when using npx outside a CI ([ed7ccd7](https://github.com/ElMassimo/vite_ruby/commit/ed7ccd7d32c079ab78555ecd36dcb68ad2da331e))
* Simplify installation of build dependencies by using package manager flags ([5c8bb62](https://github.com/ElMassimo/vite_ruby/commit/5c8bb625926f2ab1788a3e3a22aeafd7104984cb))



## [1.2.1](https://github.com/ElMassimo/vite_ruby/compare/vite_ruby@1.2.0...vite_ruby@1.2.1) (2021-03-19)


### Bug Fixes

* Use the mode option in `clobber` ([add76b2](https://github.com/ElMassimo/vite_ruby/commit/add76b2a63ea64336235536b8b5670bace357b6e))



# [1.2.0](https://github.com/ElMassimo/vite_ruby/compare/vite_ruby@1.1.2...vite_ruby@1.2.0) (2021-03-19)


### Bug Fixes

* Improve error messages when the Vite executable is missing ([#41](https://github.com/ElMassimo/vite_ruby/issues/41)) ([a79edc6](https://github.com/ElMassimo/vite_ruby/commit/a79edc6cc603c1094ede9e899226e98f734e7bbe))


### Features

* Add `clobber` to the CLI, usable as `--clear` in the `dev` and `build` commands ([331d861](https://github.com/ElMassimo/vite_ruby/commit/331d86163c12eb3303d3975a94ecc205fa59dd41))
* Allow `clobber` to receive a `--mode` option. ([e6e7a6d](https://github.com/ElMassimo/vite_ruby/commit/e6e7a6dd0a2acf205d06877f76deb924c1d5aba7))



## [1.1.2](https://github.com/ElMassimo/vite_ruby/compare/vite_ruby@1.1.1...vite_ruby@1.1.2) (2021-03-19)


### Features

* Automatically retry failed builds after a certain time ([cbb3058](https://github.com/ElMassimo/vite_ruby/commit/cbb305863a49c46e7a0d95c773f56f7d822d01d9))



## [1.1.1](https://github.com/ElMassimo/vite_ruby/compare/vite_ruby@1.1.0...vite_ruby@1.1.1) (2021-03-19)


### Bug Fixes

* handle getaddrinfo errors when checking dev server ([#39](https://github.com/ElMassimo/vite_ruby/issues/39)) ([df57d6b](https://github.com/ElMassimo/vite_ruby/commit/df57d6ba5d8ed20e15bd2de3a57c8ff711671d28))



# [1.1.0](https://github.com/ElMassimo/vite_ruby/compare/vite_ruby@1.0.5...vite_ruby@1.1.0) (2021-03-07)


### Bug Fixes

* Add development mutex in manifest to prevent re-entrant builds ([a6c6976](https://github.com/ElMassimo/vite_ruby/commit/a6c6976ba3821d8d6f26d012de13a440cb91c95b))
* Allow passing --inspect and other options to the build command ([1818ea4](https://github.com/ElMassimo/vite_ruby/commit/1818ea4f1d211923dfe0c04037baca8b2fd3b991))


### Features

* Record status and timestamp of each build to provide better errors ([a35a64a](https://github.com/ElMassimo/vite_ruby/commit/a35a64ad4ca802da7bb6d5f5139985da864293a4))
* Stream build output to provide feedback as the command runs ([2bce338](https://github.com/ElMassimo/vite_ruby/commit/2bce33888513f6961da11ddfa9f9c703182abfa6))



## [1.0.5](https://github.com/ElMassimo/vite_ruby/compare/vite_ruby@1.0.4...vite_ruby@1.0.5) (2021-03-03)


### Bug Fixes

* Fix installation of JS packages, prevent silent failures (closes [#22](https://github.com/ElMassimo/vite_ruby/issues/22)) ([#23](https://github.com/ElMassimo/vite_ruby/issues/23)) ([d972e6f](https://github.com/ElMassimo/vite_ruby/commit/d972e6f3968988460753e7a831c8e9199bbd6891))



## [1.0.4](https://github.com/ElMassimo/vite_ruby/compare/vite_ruby@1.0.3...vite_ruby@1.0.4) (2021-02-25)


### Features

* Create Vite.js integration with Padrino ([#17](https://github.com/ElMassimo/vite_ruby/issues/17)) ([9e9a0a6](https://github.com/ElMassimo/vite_ruby/commit/9e9a0a67abceed0a784d3c2e0554c717d7f5d1d6))



## [1.0.3](https://github.com/ElMassimo/vite_ruby/compare/vite_ruby@1.0.2...vite_ruby@1.0.3) (2021-02-25)


### Bug Fixes

* Infer package manager correctly ([09d3036](https://github.com/ElMassimo/vite_ruby/commit/09d303627d6012ead50acd6f814a32521a76927f))



## Vite Ruby 1.0.2 (2020-02-10)

- Fix auto-compilation when the dev server is not available.

## Vite Ruby 1.0.1 (2020-02-10)

- Fix installation script in Ruby 2.5

## Vite Ruby 1.0.0 (2020-02-09)

- Initial release, extracted core functionality from `vite_rails`.
