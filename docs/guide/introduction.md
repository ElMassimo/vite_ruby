[library]: https://github.com/ElMassimo/vite_rails
[vite_rails]: https://github.com/ElMassimo/vite_rails/tree/main/vite_rails
[plugin]: https://github.com/ElMassimo/vite_rails/tree/main/vite-plugin-ruby
[vite]: https://vitejs.dev/
[webpacker]: https://github.com/rails/webpacker
[webpack]: https://github.com/webpack/webpack
[entrypoints]: /guide/development.html#entrypoints-⤵%EF%B8%8F
[deployment]: /guide/deployment
[rake tasks]: /guide/deployment.html#rake-tasks-⚙%EF%B8%8F
[recompile assets]: /guide/development.html#auto-build-🤖
[tag helpers]: /guide/development.html#tag-helpers-🏷

# Introduction

[__Vite Ruby__][library] is a library that provides full [Vite] integration in Ruby web apps.

<kbd>[vite_rails]</kbd> is an extension that aims to provide similar functionality as [webpacker] does for [webpack], but gets out of your way so that you can easily configure Vite as needed.

Check [this video comparison](https://github.com/ElMassimo/pingcrm-vite/pull/1).

## Why 🤔

[Vite] is great on its own, but configuring it correctly to work for a Ruby app structure requires knowledge of its internals.

By following existing Rails and Rack conventions, and adding [a few of its own][plugin], it becomes possible for everyone to leverage [Vite] and its wonderful features.

## Features ⚡️

[Anything Vite can do](https://vitejs.dev/guide/features.html), plus:

#### 🤖 Automatic entrypoint detection

  Simply place your code under [`app/frontend/entrypoints`][entrypoints], and the [entrypoints]
  will be configured automatically.

#### ⚡️ Lightning-fast hot reload

  Because it does not bundle your code in development, only the scripts and styles that are running need to be processed, which enables Vite to have significantly faster HMR than webpack.

#### 🚀 Integrated with <kbd>assets:precompile</kbd>

  [Rake tasks] for building and cleaning Vite assets are [automatically integrated][deployment]
  with <kbd>assets:precompile</kbd> and <kbd>assets:clean</kbd>, so deploying is straightforward.

#### 🏗 Auto-build when not running Vite

  When the development server is not running, it will automatically detect
  changes and [recompile assets] for you. Makes it seamless to run integration tests.

#### 🏷 Smart tag helpers

  [Tag helpers] for <kbd>script</kbd> and <kbd>link</kbd> tags are provided, and
  will automatically output `preload` tags in production to optimize load time.
