# [5.1.0](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@5.0.0...vite-plugin-ruby@5.1.0) (2024-09-04)


### Bug Fixes

* infer correct dirname when a custom manifest is provided ([#458](https://github.com/ElMassimo/vite_ruby/issues/458)) ([cc46e3a](https://github.com/ElMassimo/vite_ruby/commit/cc46e3af8de735e8046a5126710c859f2ffe80ff))
* storybook compatibility, plugins can now add entrypoints ([#488](https://github.com/ElMassimo/vite_ruby/issues/488)) ([a8103b7](https://github.com/ElMassimo/vite_ruby/commit/a8103b7421160c391cc84064c5a170502c8cb40f))


### Features

* add `package_manager` config option, experimental support for bun ([#481](https://github.com/ElMassimo/vite_ruby/issues/481)) ([4426cb1](https://github.com/ElMassimo/vite_ruby/commit/4426cb1007dbb58f4637a4423b1e7d640db96841)), closes [#324](https://github.com/ElMassimo/vite_ruby/issues/324)
* change default execution to use `npx vite` instead ([#480](https://github.com/ElMassimo/vite_ruby/issues/480)) ([330f61f](https://github.com/ElMassimo/vite_ruby/commit/330f61fedadf1274547a069856125e52002d0065)), closes [#462](https://github.com/ElMassimo/vite_ruby/issues/462)
* upgrade vite-plugin-rails dependencies to support vite 5 ([b4eade9](https://github.com/ElMassimo/vite_ruby/commit/b4eade9b92413172501df8f762a9c0164633ee95))



# [5.0.0](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@3.2.2...vite-plugin-ruby@5.0.0) (2023-11-16)


### Features

* add support for vite 5, which changed default manifest path ([818132a](https://github.com/ElMassimo/vite_ruby/commit/818132a07af3f17ba27ae09c44fcd59029064238))



## [3.2.2](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@3.2.1...vite-plugin-ruby@3.2.2) (2023-04-28)



## [3.2.1](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@3.2.0...vite-plugin-ruby@3.2.1) (2023-03-16)


### Features

* help users that visit the vite dev server directly ([#346](https://github.com/ElMassimo/vite_ruby/issues/346)) ([0f40a1d](https://github.com/ElMassimo/vite_ruby/commit/0f40a1de2d29201a32d7d2f679e99b1ed3208246))



# [3.2.0](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@3.1.3...vite-plugin-ruby@3.2.0) (2023-03-16)


### Bug Fixes

* ssr incompatibility with vite 4 ([#345](https://github.com/ElMassimo/vite_ruby/issues/345)) ([3491bde](https://github.com/ElMassimo/vite_ruby/commit/3491bdedad2b0fcb8a1895efa4dafb3874d14efd)), closes [#333](https://github.com/ElMassimo/vite_ruby/issues/333)



## [3.1.3](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@3.1.2...vite-plugin-ruby@3.1.3) (2022-12-02)


### Features

* add experimental `skipProxy` setting ([#315](https://github.com/ElMassimo/vite_ruby/issues/315)) ([e9285f6](https://github.com/ElMassimo/vite_ruby/commit/e9285f62c76cc0cbbc5dc99d977e8aef30d08b6f))
* create vite-plugin-rails, an opinionated version of `vite-plugin-ruby` ([#282](https://github.com/ElMassimo/vite_ruby/issues/282)) ([16375fb](https://github.com/ElMassimo/vite_ruby/commit/16375fb1f6f2bf86dff935ca3aaf91c333a796ff))



## [3.1.2](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@3.1.1...vite-plugin-ruby@3.1.2) (2022-07-15)


### Bug Fixes

* avoid overriding hmr.clientPort when specified by the user (close [#231](https://github.com/ElMassimo/vite_ruby/issues/231)) ([ea2d844](https://github.com/ElMassimo/vite_ruby/commit/ea2d8444c2e9700ef6f6887632c617190c2f8ced))



## [3.1.1](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@3.1.0...vite-plugin-ruby@3.1.1) (2022-07-14)


### Bug Fixes

* specify the client port explicitly ([3dd06db](https://github.com/ElMassimo/vite_ruby/commit/3dd06dbb85946a2645ab67607a8d6dabe77c5d73))



# [3.1.0](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@3.0.12...vite-plugin-ruby@3.1.0) (2022-07-13)


### Features

* use Vite 3 as the default ([#225](https://github.com/ElMassimo/vite_ruby/issues/225)) ([8fab191](https://github.com/ElMassimo/vite_ruby/commit/8fab1912dc8c7c600854b490c09a603644714266))



# [3.1.0-beta.0](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@3.0.12...vite-plugin-ruby@3.1.0-beta.0) (2022-07-01)


### Features

* simplify internals now that Vite adds CSS assets to the manifest ([aa9c2b3](https://github.com/ElMassimo/vite_ruby/commit/aa9c2b327c556766d955ab7a3bbf3eb029a858c8))



## [3.0.12](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@3.0.11...vite-plugin-ruby@3.0.12) (2022-05-15)


### Bug Fixes

* change default for ssrOutputDir so it's ignored by default ([2f93b76](https://github.com/ElMassimo/vite_ruby/commit/2f93b762b29462cc619527ed47e6fa3cf8d3c8c9))
* load .env files in the project root (close [#214](https://github.com/ElMassimo/vite_ruby/issues/214)) ([a8162e9](https://github.com/ElMassimo/vite_ruby/commit/a8162e9877b6b8f5a680095f6d424bd3117d9539))



## [3.0.11](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@3.0.10...vite-plugin-ruby@3.0.11) (2022-05-12)


### Features

* add support for SSR builds (experimental) ([#212](https://github.com/ElMassimo/vite_ruby/issues/212)) ([4d6cd2b](https://github.com/ElMassimo/vite_ruby/commit/4d6cd2b84f670b1703e3bde7033e822be97bf505))



## [3.0.10](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@3.0.9...vite-plugin-ruby@3.0.10) (2022-05-04)


### Features

* add support for SSR builds (experimental) ([#210](https://github.com/ElMassimo/vite_ruby/issues/210)) ([e98d725](https://github.com/ElMassimo/vite_ruby/commit/e98d72531ef64f1f56028611a5ad42e015ea3282))



## [3.0.9](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@3.0.8...vite-plugin-ruby@3.0.9) (2022-04-01)


### Bug Fixes

* disable emptyOutDir in non-development modes ([#199](https://github.com/ElMassimo/vite_ruby/issues/199)) ([94e75a3](https://github.com/ElMassimo/vite_ruby/commit/94e75a31ed4c6d49d1dc0cc5260c2ce8280e7279))


### Features

* bump up default vite version to 2.8.6 ([fd53030](https://github.com/ElMassimo/vite_ruby/commit/fd5303017760dc176b3fb15908f08a16a175c22f))



## [3.0.8](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@3.0.7...vite-plugin-ruby@3.0.8) (2022-01-18)


### Bug Fixes

* disable emptyOutDir in production mode ([#177](https://github.com/ElMassimo/vite_ruby/issues/177)) ([#180](https://github.com/ElMassimo/vite_ruby/issues/180)) ([d9b6225](https://github.com/ElMassimo/vite_ruby/commit/d9b6225436fce0f7916ef96b5661af9eb404c04f))
* Revert "pass hmr host explicitly by default ([#119](https://github.com/ElMassimo/vite_ruby/issues/119))" (close [#179](https://github.com/ElMassimo/vite_ruby/issues/179)) ([f629628](https://github.com/ElMassimo/vite_ruby/commit/f6296280065473354638a7337572ce50b338f8a5))



## [3.0.7](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@3.0.6...vite-plugin-ruby@3.0.7) (2022-01-12)


### Bug Fixes

* **vite-plugin-ruby:** regression in assetHosts protocol ([#174](https://github.com/ElMassimo/vite_ruby/issues/174)) ([8337ec9](https://github.com/ElMassimo/vite_ruby/commit/8337ec912b2b6387a6729f4ae5d29ab7d07f0b4b))



## [3.0.6](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@3.0.5...vite-plugin-ruby@3.0.6) (2022-01-04)


### Bug Fixes

* default export when app uses `"type": "module"` ([97cf854](https://github.com/ElMassimo/vite_ruby/commit/97cf854468956df318f379c6b017ba06bace06cd))



## [3.0.5](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@3.0.4...vite-plugin-ruby@3.0.5) (2021-12-24)


### Bug Fixes

* allow providing an empty public output dir (close [#161](https://github.com/ElMassimo/vite_ruby/issues/161)) ([#164](https://github.com/ElMassimo/vite_ruby/issues/164)) ([ef48c9b](https://github.com/ElMassimo/vite_ruby/commit/ef48c9b39084a96364a783fa670bd6ec68dfa289))



## [3.0.4](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@3.0.3...vite-plugin-ruby@3.0.4) (2021-12-09)


### Features

* add 'base' setting ([#152](https://github.com/ElMassimo/vite_ruby/issues/152)) ([fb7642f](https://github.com/ElMassimo/vite_ruby/commit/fb7642f849b7fe879c02e543962a72dcc1b1c48c))



## [3.0.3](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@3.0.2...vite-plugin-ruby@3.0.3) (2021-10-29)


### Bug Fixes

* avoid generating sourcemaps when running tests ([2b4faac](https://github.com/ElMassimo/vite_ruby/commit/2b4faac7b811af089f981861bcf7e3a3fd8486b2))


### Features

* enable hmr when running tests in development with vite dev server ([e253bba](https://github.com/ElMassimo/vite_ruby/commit/e253bba26d164aabc7a9526df504c207ad2cf6f9))



## [3.0.2](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@3.0.2-pre.2...vite-plugin-ruby@3.0.2) (2021-10-27)



## [3.0.2-pre.2](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@3.0.2-pre.1...vite-plugin-ruby@3.0.2-pre.2) (2021-10-08)


### Bug Fixes

* use slash after resolving, for windows compatibility ([c6ea9ac](https://github.com/ElMassimo/vite_ruby/commit/c6ea9acf6efbe2c126551cfdf06b9a07d2bfc817))



## [3.0.2-pre.1](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@3.0.1...vite-plugin-ruby@3.0.2-pre.1) (2021-10-08)


### Bug Fixes

* use posix-style paths for globs to support windows (see [#129](https://github.com/ElMassimo/vite_ruby/issues/129)) ([ded65f7](https://github.com/ElMassimo/vite_ruby/commit/ded65f784285f79d1e781dfbad6385af6c5e0099))



## [3.0.1](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@3.0.0...vite-plugin-ruby@3.0.1) (2021-08-23)


### Bug Fixes

* pass hmr host explicitly by default ([#119](https://github.com/ElMassimo/vite_ruby/issues/119)) ([07d3237](https://github.com/ElMassimo/vite_ruby/commit/07d3237bcfe2c744b0b0b3a14b11b6321de5f05e))



# [3.0.0](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@2.0.5...vite-plugin-ruby@3.0.0) (2021-08-16)

See https://github.com/ElMassimo/vite_ruby/pull/116 for features and breaking changes.


## [2.0.5](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@2.0.4...vite-plugin-ruby@2.0.5) (2021-07-29)


### Bug Fixes

* add style.css to the manifest when using build.cssCodeSplit: false (close [#109](https://github.com/ElMassimo/vite_ruby/issues/109)) ([9f07ac9](https://github.com/ElMassimo/vite_ruby/commit/9f07ac9db301c5189daaaa16204b469a453f15e5))



## [2.0.4](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@2.0.3...vite-plugin-ruby@2.0.4) (2021-05-10)


### Bug Fixes

* Explicitly set the project root to prepare for changes in upcoming Vite (> 2.2.4) ([4e00780](https://github.com/ElMassimo/vite_ruby/commit/4e00780309242ac8bb801cd30c345d91796ed684))



## [2.0.3](https://github.com/ElMassimo/vite_ruby/compare/vite-plugin-ruby@2.0.2...vite-plugin-ruby@2.0.3) (2021-04-26)


### Features

* Add support for .pcss extension for PostCSS ([512790e](https://github.com/ElMassimo/vite_ruby/commit/512790e7254f6073571695a977744369854dbfa7))
* Update plugin types to use PluginOption[] instead of Plugin[] ([1ffdbc6](https://github.com/ElMassimo/vite_ruby/commit/1ffdbc6369f0d6f87d050b1d7fa10f5ce8934758))



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
