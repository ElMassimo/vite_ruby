[discussions]: https://github.com/ElMassimo/vite_ruby/discussions
[rails]: https://rubyonrails.org/
[webpacker]: https://github.com/rails/webpacker
[vite rails]: https://github.com/ElMassimo/vite_ruby
[vite]: https://vitejs.dev/
[vite-plugin-ruby]: https://github.com/ElMassimo/vite_ruby/tree/main/vite-plugin-ruby
[vite-templates]: https://github.com/vitejs/vite/tree/main/packages/create-app
[plugins]: https://vitejs.dev/plugins/
[configuration reference]: /config/
[example1]: https://github.com/ElMassimo/pingcrm-vite
[heroku1]: https://pingcrm-vite.herokuapp.com/
[example2]: https://github.com/ElMassimo/vite_ruby/tree/main/examples/rails
[heroku2]: https://vite-rails-demo.herokuapp.com/
[build options]: /config/#build-options
[configuration reference]: /config/
[vite_rails]: https://github.com/ElMassimo/vite_ruby/tree/main/vite_rails
[vite_hanami]: https://github.com/ElMassimo/vite_ruby/tree/main/vite_hanami
[json]: /config/#shared-configuration-file-📄
[publicOutputDir]: /config/#publicoutputdir
[installation]: /guide/#setup-%F0%9F%93%A6
[nodejs buildpack]: https://elements.heroku.com/buildpacks/heroku/heroku-buildpack-nodejs
[ruby buildpack]: https://elements.heroku.com/buildpacks/heroku/heroku-buildpack-ruby
[skip pruning]: https://devcenter.heroku.com/articles/nodejs-support#skip-pruning
[capistrano-rails]: https://github.com/capistrano/rails
[installed automatically]: https://github.com/ElMassimo/vite_ruby/blob/main/vite_ruby/lib/tasks/vite.rake#L59-L63
[dev dependencies]: /guide/deployment.html#development-dependencies-🔗
[vite-plugin-rails]: /guide/plugins.html#rails

# Deployment 🚀

Deploying a Ruby web app using _Vite Ruby_ should be quite straightforward.

<kbd>assets:precompile</kbd> is a standard for Ruby web apps, and is typically
run automatically for you upon deployment if you are using a PaaS such as
[Heroku][heroku1], or added in [Capistrano](#using-capistrano) scripts.

<kbd>vite:build</kbd> will be executed whenever <kbd>assets:precompile</kbd> is run,
and the resulting assets will be placed [inside][publicOutputDir] the `public` folder.

::: tip CDN Support
Both <kbd>[vite_rails]</kbd> and <kbd>[vite_hanami]</kbd> will honor your CDN configuration, and tag helpers will render the appropriate URLs.
:::

Vite will take `RACK_ENV` and `RAILS_ENV` into account in commands and rake tasks,
using the appropriate [configuration][configuration reference] for the environment as specified in [`config/vite.json`][json].

## Rake Tasks ⚙️

In Rails, they are installed automatically, so you can simply use them.

In other apps, you can add them manually in your `Rakefile`:

```ruby
require 'vite_ruby'
ViteRuby.install_tasks
```

The following rake tasks are available:

- <kbd>vite:build</kbd>

  Makes a production bundle with Vite using Rollup behind the scenes.

  Called automatically whenever <kbd>assets:precompile</kbd> is called.

- <kbd>vite:clobber</kbd>

  Remove the Vite build output directory.

  Called automatically whenever <kbd>assets:clobber</kbd> is called.

- <kbd>vite:info</kbd>

  Provide information on _Vite Ruby_ and related libraries.

::: tip Environment-aware

You can provide `RACK_ENV=production` to simulate a production build locally.
:::

## Development Dependencies 🔗

By default `vite` and `vite-plugin-ruby` will be [added][installation] as
development dependencies, and they will be [installed automatically] when
running `assets:precompile`.

This allows you to skip installation in servers that won't precompile assets, or
easily prune them after assets have been precompiled.

You can opt-out by setting the [`VITE_RUBY_SKIP_INSTALL_DEV_DEPENDENCIES`](/config/#skip-install-dev-dependencies)
environment variable to `true`.

## Disabling `node_modules` installation in `assets:precompile`

By default, node dependencies will be automatically installed as part of the `assets:precompile` task.

If all dependencies that necessary for the Vite build have already been installed
in a previous step, you may skip installation by setting the
[`VITE_RUBY_SKIP_ASSETS_PRECOMPILE_INSTALL`](/config/#skip-assets-precompile-install)
environment variable to `true`.

## Disabling extension of the `assets:precompile` task

During complex migrations, it might be convenient that `vite:build` is not run
along the `assets:precompile` rake task.

You can disable the extension of the `assets:precompile` rake task by setting
the [`VITE_RUBY_SKIP_ASSETS_PRECOMPILE_EXTENSION`](/config/#skip-assets-precompile-extension)
environment variable to `true`.


## Compressing Assets 📦

Most CDN and edge service providers will automatically serve compressed assets,
which is why Vite does not create compressed copies of each file.

If you are not sure about whether your setup handles compression, consider using
[`rollup-plugin-gzip`](https://github.com/kryops/rollup-plugin-gzip) to output
[gzip and brotli copies](https://github.com/ElMassimo/vite_ruby/discussions/101#discussioncomment-1019222) of each asset.

If using <kbd>[vite-plugin-rails]</kbd>, assets will be compressed using gzip and brotli out of the box.

## Using Capistrano

<kbd>[capistrano-rails]</kbd> is a gem that adds Rails-specific tasks to Capistrano, such as support for assets precompilation and migrations.

While it was originally designed for sprockets, you can easily configure it for _Vite Ruby_, which means you get automatic removal of expired assets, and manifest backups.

It's necessary to extend [the default configuration](https://github.com/capistrano/rails/blob/d86a8db16281f09d8cfff9ee791297134bce9801/lib/capistrano/tasks/assets.rake#L139)
so that it detects the following files:

- `manifest.json`: generated [by Vite](https://vitejs.dev/config/build-options.html#build-manifest) for entrypoints
- `manifest-assets.json`: generated [by `vite-plugin-ruby`](https://github.com/ElMassimo/vite_ruby/blob/main/vite-plugin-ruby/src/manifest.ts#L26-L29)   for other assets

```ruby
# config/deploy.rb

append :linked_dirs, "public/vite"
append :assets_manifests, "public/vite/.vite/manifest*.*"
  ```

See <kbd>[capistrano-rails]</kbd> for more information about relevant settings
such as `keep_assets` and `assets_roles`.

:::warning Custom Output Dirs
When customizing `ViteRuby.config.public_output_dir` or `ViteRuby.config.public_dir`
change `"public/vite"`   to reflect your configuration.
:::

## Using Heroku

In order to deploy to Heroku, it's necessary to add the [nodejs][nodejs buildpack] and [ruby][ruby buildpack] buildpacks.

Make sure that the ruby buildpack [appears last](https://devcenter.heroku.com/articles/using-multiple-buildpacks-for-an-app#viewing-buildpacks) to ensure the proper defaults are applied.

```
$ heroku buildpacks
=== pingcrm-vite Buildpack URLs
1. heroku/nodejs
2. heroku/ruby
```

If you are starting from scratch, you achieve that by running:

```bash
heroku buildpacks:set heroku/ruby
heroku buildpacks:add --index 1 heroku/nodejs
```

When precompiling assets in Heroku, it's better to _[skip pruning]_ of [dev dependencies] by setting:
```bash
heroku config:set NPM_CONFIG_INCLUDE='dev' YARN_PRODUCTION=false
# or NPM_CONFIG_PRODUCTION=false in versions of npm < 7
```
That will ensure that [vite] and [vite-plugin-ruby] are available, along with other build tools.

If you are looking for example setups, check out this [Vue app][example1] and its [live demo][heroku1], or this very [simple app][example2] and its [live demo][heroku2].
