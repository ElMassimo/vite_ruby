## [2.0.2](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@2.0.1...vite-plugin-ruby@2.0.2) (2021-04-22)


### Features

* Improve sourcemap paths to be relative to the project root ([a4c661c](https://github.com/ElMassimo/vite_ruby/commit/a4c661c1b51becafde66c5ff3e4e195534d63c67))



## [2.0.1](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@2.0.0...vite-plugin-ruby@2.0.1) (2021-04-21)


### Bug Fixes

* Fix error in manifest generation and avoid duplicate files (close [#55](https://github.com/ElMassimo/vite_ruby/issues/55)) ([1eb1307](https://github.com/ElMassimo/vite_ruby/commit/1eb1307ea183a9bcbe3ea38fe215c88ba3ed6e8f))



# [2.0.0](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@1.0.18...vite-plugin-ruby@2.0.0) (2021-04-15)

### Features

* Add support for .scss, .less, and .styl entrypoints (close [#50](https://github.com/ElMassimo/vite_ruby/issues/50)) ([bb1d295](https://github.com/ElMassimo/vite_ruby/commit/bb1d2953b3a8c5862d26cdfcd5edc5cc918d1c5a))

### Breaking Change

* The manifest entries now include the file extension in the name for stylesheet entrypoints.

## [1.0.18](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@1.0.17...vite-plugin-ruby@1.0.18) (2021-03-24)


### Bug Fixes

* Allow overriding `sourcemap` and `emptyOutDir` build options (close [#49](https://github.com/ElMassimo/vite_ruby/issues/49)) ([f9a2379](https://github.com/ElMassimo/vite_ruby/commit/f9a237907726d9d1d44eca9fb671df3c4333905c))
* Improve error messages when the Vite executable is missing ([#41](https://github.com/ElMassimo/vite_ruby/issues/41)) ([a79edc6](https://github.com/ElMassimo/vite_ruby/commit/a79edc6cc603c1094ede9e899226e98f734e7bbe))



## [1.0.17](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@1.0.16...vite-plugin-ruby@1.0.17) (2021-03-19)

### Bug Fixes

* Preserve custom server.https configuration (close [#42](https://github.com/ElMassimo/vite_ruby/issues/42)) ([#43](https://github.com/ElMassimo/vite_ruby/issues/43)) ([2ec0b50](https://github.com/ElMassimo/vite_ruby/commit/2ec0b503783e8890f179c384800a02c082cf8cc0))


## [1.0.16](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@1.0.15...vite-plugin-ruby@1.0.16) (2021-03-04)

* Add `vite-plugin` keyword to `package.json`

## [1.0.15](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@1.0.14...vite-plugin-ruby@1.0.15) (2021-03-03)

* Add keywords to `package.json`

## [1.0.14](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@1.0.13...vite-plugin-ruby@1.0.14) (2021-03-03)


### Features

* Add paths in watchAdditionalPaths to configureServer (close [#21](https://github.com/ElMassimo/vite_ruby/issues/21)) ([#24](https://github.com/ElMassimo/vite_ruby/issues/24)) ([405d748](https://github.com/ElMassimo/vite_ruby/commit/405d7482c7285a3d067c137d01e321f42d4df1c5))



## vite-plugin-ruby 1.0.13 (2020-02-16)

- Remove old `alias` fallback now that Vite is officially in 2.0! Thanks Konnor!

## vite-plugin-ruby 1.0.12 (2020-02-15)

- Fix the repo URLs in the package metadata. Thanks @davidrunger!

## vite-plugin-ruby 1.0.11 (2020-02-12)

- Move `alias` to `resolve.alias` as per the deprecation in [beta-68](https://github.com/vitejs/vite/blob/main/packages/vite/CHANGELOG.md#200-beta68-2021-02-11).
- Start using `env.mode` if available, introduced in [beta-69](https://github.com/vitejs/vite/blob/main/packages/vite/CHANGELOG.md#200-beta69-2021-02-11).

## vite-plugin-ruby 1.0.10 (2020-02-09)

- Move `debug` from external to dependency.

## vite-plugin-ruby 1.0.9 (2020-02-09)

- Add all files under `sourceCodeDir` to the dev server watcher.

## vite-plugin-ruby 1.0.8 (2020-02-06)

- Split entrypoints into assets/non-assets and add fingerprinting for assets, in order to support 2.0.0-beta.65
- Add `@/` alias to the source dir.

## vite-plugin-ruby 1.0.7 (2020-01-29)

- Fix assets manifest generation after Vite 2.0.0-beta.62 started sending `name: undefined` for svg entrypoints.

## vite-plugin-ruby 1.0.6 (2020-01-29)

- Create a new plugin that generates an assets manifest, since Vite 2.0.0-beta.51 stopped including non-JS entrypoints in the manifest.

## vite-plugin-ruby 1.0.5  (2020-01-24)

- Fix bug in the default for `assetHost` (was `null` instead of `''`).
- Move `base` to the configuration root after Vite 2.0.0-beta.38.

## vite-plugin-ruby 1.0.4  (2020-01-23)

- Receive `assetHost` and use it as the `base` when provided.
