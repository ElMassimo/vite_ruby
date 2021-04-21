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
