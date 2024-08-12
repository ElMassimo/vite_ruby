[library]: https://github.com/ElMassimo/vite_ruby
[vite_rails]: https://github.com/ElMassimo/vite_ruby/tree/main/vite_rails
[plugin]: https://github.com/ElMassimo/vite_ruby/tree/main/vite-plugin-ruby
[vite]: https://vitejs.dev/
[webpacker]: https://github.com/rails/webpacker
[webpack]: https://github.com/webpack/webpack
[entrypoints]: /guide/development.html#entrypoints-⤵%EF%B8%8F
[deployment]: /guide/deployment
[rake tasks]: /guide/deployment.html#rake-tasks-⚙%EF%B8%8F
[recompile assets]: /guide/development.html#auto-build-🤖
[tag helpers]: /guide/rails.html#tag-helpers-🏷
[vite_rails]: https://github.com/ElMassimo/vite_ruby/tree/main/vite_rails
[vite_ruby]: https://github.com/ElMassimo/vite_ruby/tree/main/vite_ruby
[vite_hanami]: /guide/hanami
[vite_padrino]: /guide/padrino
[no bundling]: https://vitejs.dev/guide/why.html#the-problems
[bundling]: https://vitejs.dev/guide/why.html#why-bundle-for-production
[motivation]: /motivation
[overview]: /overview
[jekyll-vite]: https://github.com/ElMassimo/jekyll-vite
[blog post]: https://maximomussini.com/posts/a-rubyist-guide-to-vite-js/

# Introduction

[__Vite Ruby__][library] is an umbrella project that provides full [Vite.js][vite] integration in Ruby web apps.

- <kbd>[vite_rails]</kbd> provides similar functionality as [webpacker] does for [webpack], without all the configuration overhead and dependencies.

- <kbd>[vite_ruby]</kbd> can be used in plain Rack apps, and is all you need when using HTML entrypoints.

- There are also integrations for [Jekyll][jekyll-vite], [Hanami][vite_hanami], and [Padrino][vite_padrino].

[Read an introduction __blog post__][blog post].

## Why Vite? 🤔

Vite [does not bundle your code during development][no bundling], which means the
dev server is extremely __fast to start__, and your changes will be __updated instantly__.

In production, Vite [bundles your code][bundling]
with tree-shaking, lazy-loading, and common chunk splitting out of the box, to achieve optimal loading performance.

It also provides great defaults, and is easier to configure than similar tools like webpack.

Check [this video comparison with webpack](https://github.com/ElMassimo/jumpstart-vite)
which demonstrates the difference in boot time, or [this one](https://github.com/ElMassimo/pingcrm-vite/pull/1)
with the difference in speed during development.

## Why Vite Ruby? 🤔

[Vite] is great on its own, but configuring it correctly to work for a Ruby app structure requires knowledge of its internals.

By following existing Rails and Rack conventions, and adding [a few of its own][plugin], it becomes possible for everyone to leverage [Vite] and its wonderful features!

Interested in hearing more? [Read an introduction __blog post__][blog post], [learn __how it works__][overview], or [read about __my personal motivation__][motivation].

## Features ⚡️

[Everything Vite provides](https://vitejs.dev/guide/features.html), plus:

### 🤖 Automatic entrypoint detection

  Simply place your code under [`app/frontend/entrypoints`][entrypoints], and the [entrypoints]
  will be configured automatically.

### ⚡️ Lightning-fast hot reload

  Because it does not bundle your code in development, only the scripts and styles that are running need to be processed, which enables Vite to have significantly faster HMR than webpack.

### 🚀 Integrated with <kbd>assets:precompile</kbd>

  [Rake tasks] for building and Vite assets are [automatically integrated][deployment]
  with <kbd>assets:precompile</kbd>, so deploying is straightforward.

### 🏗 Auto-build when not running Vite

  When the development server is not running, it will automatically detect
  changes and [recompile assets] for you. Makes it seamless to run integration tests.

### 🏷 Smart tag helpers

  [Tag helpers] for <kbd>script</kbd> and <kbd>link</kbd> tags are provided, and
  will automatically output `preload` tags in production to optimize load time.
