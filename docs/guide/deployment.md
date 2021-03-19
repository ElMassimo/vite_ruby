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
[nodejs buildpack]: https://elements.heroku.com/buildpacks/heroku/heroku-buildpack-nodejs
[ruby buildpack]: https://elements.heroku.com/buildpacks/heroku/heroku-buildpack-ruby
[skip pruning]: https://devcenter.heroku.com/articles/nodejs-support#skip-pruning

# Deployment 🚀

Deploying a Ruby web app using _Vite Ruby_ should be quite straightforward.

The <kbd>assets:precompile</kbd> is a standard for Ruby web apps, and is
typically run automatically for you upon deployment if you are using a PaaS such
as [Heroku][heroku1], or added in Capistrano scripts.

_Vite Ruby_ will trigger a Vite build whenever <kbd>assets:precompile</kbd> is run,
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

- <kbd>vite:clean[keep,age]</kbd>

  Remove previous Vite builds.

  Called automatically whenever <kbd>assets:clean</kbd> is called.

- <kbd>vite:clobber</kbd>

  Remove the Vite build output directory.

  Called automatically whenever <kbd>assets:clobber</kbd> is called.

- <kbd>vite:info</kbd>

  Provide information on _Vite Ruby_ and related libraries.

::: tip Environment-aware

You can provide `RACK_ENV=production` to simulate a production build locally.
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

When precompiling assets in Heroku, it's better to _[skip pruning]_ of dev dependencies by setting:
```bash
heroku config:set NPM_CONFIG_PRODUCTION=false YARN_PRODUCTION=false
```
That will ensure that [vite] and [vite-plugin-ruby] are available, along with other build tools.

If you are looking for example setups, check out this [Vue app][example1] and its [live demo][heroku1], or this very [simple app][example2] and its [live demo][heroku2].
