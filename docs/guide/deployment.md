[discussions]: https://github.com/ElMassimo/vite_rails/discussions
[rails]: https://rubyonrails.org/
[webpacker]: https://github.com/rails/webpacker
[vite rails]: https://github.com/ElMassimo/vite_rails
[vite]: https://vitejs.dev/
[vite-templates]: https://github.com/vitejs/vite/tree/main/packages/create-app
[plugins]: https://vitejs.dev/plugins/
[configuration reference]: /config/
[example1]: https://github.com/ElMassimo/pingcrm-vite
[heroku1]: https://pingcrm-vite.herokuapp.com/
[example2]: https://github.com/ElMassimo/vite_rails/tree/main/examples/blog
[heroku2]: https://vite-rails-demo.herokuapp.com/
[build options]: /config/#build-options
[configuration reference]: /config/

# Deployment 🚀

Deploying a Rails app using _Vite Ruby_ should be straightforward.

_Vite Ruby_ hooks up a new <kbd>vite:build</kbd> task to <kbd>assets:precompile</kbd>, which will run whenever you precompile assets.

::: tip Aliased
If not using Sprockets, <kbd>vite:build</kbd> is automatically aliased to <kbd>assets:precompile</kbd>.
:::

Vite will take `RACK_ENV` and `RAILS_ENV` into account, using the appropriate configuration for
the current environment as specified in `config/vite.json`.

Check the [configuration reference] to learn more about the [build options].

## Rake Tasks ⚙️

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

All these tasks are aware of the environment. When running them locally in
development you can provide `RACK_ENV=production` to simulate a production build.
:::

<hr/>

If you are looking for example setups, check out this [Vue app][example1] and its [live demo][heroku1], or this very [simple app][example2] and its [live demo][heroku2].
