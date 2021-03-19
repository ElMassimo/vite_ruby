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
