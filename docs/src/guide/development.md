[tag helpers]: /guide/rails.html#tag-helpers-%F0%9F%8F%B7
[discussions]: https://github.com/ElMassimo/vite_ruby/discussions
[rails]: https://rubyonrails.org/
[webpacker]: https://github.com/rails/webpacker
[vite rails]: https://github.com/ElMassimo/vite_ruby
[vite]: https://vitejs.dev/
[vite-templates]: https://github.com/vitejs/vite/tree/main/packages/create-app
[plugins]: https://vitejs.dev/plugins/
[configuration reference]: /config/
[build]: /config/#build-options
[dev options]: /config/#development-options
[json config]: /config/#shared-configuration-file-%F0%9F%93%84
[vite config]: /config/#configuring-vite-%E2%9A%A1
[sourceCodeDir]: /config/#sourcecodedir
[additionalEntrypoints]: /guide/advanced.html#additional-entrypoints
[autoBuild]: /config/#autobuild
[entrypoints]: https://vitejs.dev/guide/build.html#multi-page-app
[Importing styles from JS]: https://github.com/ElMassimo/vite_ruby/blob/main/examples/rails/app/frontend/entrypoints/application.ts#L8-L9
[layout]: https://github.com/ElMassimo/vite_ruby/blob/main/examples/rails/app/views/layouts/application.html.erb#L12
[sourceCodeDir]: /config/#sourcecodedir
[entrypointsDir]: /config/#entrypointsdir
[watchAdditionalPaths]: /config/#watchadditionalpaths
[aliased]: https://github.com/rollup/plugins/tree/master/packages/alias
[jekyll-vite]: https://jekyll-vite.netlify.app/posts/tag-helpers/
[Advanced Usage]: /guide/advanced
[css]: https://vitejs.dev/guide/features.html#css
[preprocessors]: https://vitejs.dev/guide/features.html#css-pre-processors
[tag helper]: #tag-helpers-🏷

# Developing with Vite

In this section, we'll cover the basics to get started with Vite in Ruby web apps.

## Development Server 💻

Run <kbd>bin/vite dev</kbd> to start a Vite development server.

It will use your [`config/vite.json`][json config] configuration, which can be
used to configure the `host` and `port`, as well as [other options][dev options].

## Entrypoints ⤵️

Any files inside your <kbd>[entrypointsDir]</kbd> will be considered [entries][entrypoints] to your application (SPAs or pages), and will be bundled by Vite.

<div class="language-">
  <pre>
<code>app/frontend: <kbd><a href="/config/#sourcecodedir">sourceCodeDir</a></kbd>
  ├── entrypoints: <kbd><a href="/config/#entrypointsdir">entrypointsDir</a></kbd>
  │   # only Vite entry files here
  │   │── application.js
  │   └── typography.css
  │── components:
  │   └── App.vue
  │── channels:
  │   │── index.js
  │   └── chat.js
  │── stylesheets:
  │   └── my_styles.css
  └── images:
      └── logo.svg</code>
</pre>
</div>

These files will be automatically detected and passed on to Vite, all [configuration][entrypoints] is done for you.

You can add them to your HTML layouts or views using the provided [tag helpers].

:::tip Additional Entrypoints
By default, files inside `~/{assets,fonts,icons,images}/**/*` are also
bundled as entrypoints, allowing you to reference them in [tag helpers].

Use <kbd>[additionalEntrypoints]</kbd> to configure entrypoints manually.
:::

## Import Aliases 👉

For convenience, `~/` and `@/` are [aliased] to your <kbd>[sourceCodeDir]</kbd>,
which simplifies imports:

```js
import App from '~/components/App.vue'
import '@/channels/index.js'
```

When importing files _outside_ your <kbd>[sourceCodeDir]</kbd>, make sure to check <kbd>[watchAdditionalPaths]</kbd>.

## Stylesheets 🎨

Vite provides [great support for CSS][css], supporting PostCSS out of the box, and 
[built-in support for preprocessors][preprocessors] like Sass.

In _Vite Ruby_ the most common ways to add styles are:

- [Importing styles from JS], which will automatically inject the CSS on load:

  ```js
  import '~/styles/theme.css'
  ```

- [Using `vite_stylesheet_tag`][layout] in the view templates:

  ```erb
  <%= vite_stylesheet_tag 'styles.scss' %> # app/frontend/entrypoints/styles.scss
  ```

## Auto-Build 🤖

Even when not running the Vite development server, _Vite Ruby_ can detect if
any assets have changed in <kbd>[sourceCodeDir]</kbd>, and trigger a build
automatically when the asset is requested.

This is very convenient when running integration tests, or when a developer
does not want to start the Vite development server (at the expense of a slower feedback loop).

::: tip Enabled locally
By [default][json config], <kbd>[autoBuild]</kbd> is enabled in the `test` and `development` environments.
:::

## CLI Commands ⌨️

A CLI tool is provided, you can run it using <kbd>bundle exec vite</kbd>, or <kbd>bin/vite</kbd> after installation.

For information about the CLI options run <kbd>bin/vite <b>command</b> --help</kbd>.

- <kbd>bundle exec vite install</kbd>:
  Install configuration files and sample setup for your web app

- <kbd>bin/vite dev</kbd>:
  Starts the Vite development server

- <kbd>bin/vite build</kbd>:
  Makes a production bundle with Vite using Rollup behind the scenes

- <kbd>bin/vite upgrade</kbd>:
  Updates Vite Ruby gems and npm packages to compatible versions

- <kbd>bin/vite info</kbd>:
  Provide information on _Vite Ruby_ and related libraries

- <kbd>bin/vite clobber</kbd>:
  Clears the Vite cache, temp files, and builds.

  Also available through the `--clear` flag in the `dev` and `build` commands.

::: tip Environment-aware

All these commands are aware of the environment. When running them locally in
development you can pass `--mode production` to simulate a production build.
:::

## Tag Helpers 🏷

Tag helpers are provided in the framework-specific integrations:

  - [Rails](/guide/rails)
  - [Jekyll][jekyll-vite]
  - [Hanami](/guide/hanami)
  - [Padrino](/guide/padrino)
  - [Plugin Legacy](/guide/plugin-legacy)

## HMR for Integration Tests ✅

When iterating on integration tests locally, you can [avoid rebuilds] by starting
an additional Vite dev server for tests with <kbd>bin/vite dev --mode=test</kbd>.

To reuse the same Vite dev server from development, you can configure <kbd>[publicOutputDir]</kbd> and <kbd>[port]</kbd> in `test` to match the `development` config.

::: tip Intended for quick iteration
The trade-off is that your app might not even build correctly.

It's safe if you are running tests in a CI as it will build in production mode.

When running tests locally, you can test the production build by not starting the Vite dev server for tests, or by setting the `CI` environment variable.
:::

## Integration Tests in the CI ✅

When running tests in the CI, it's more reliable if assets are available
__before__ tests start to run, as it:

- Prevents timeouts in Capybara during <kbd>[autoBuild]</kbd>
- Prevents race conditions when running tests in parallel (each thread could start a build)

To achieve that, it's recommended to run `bin/rake assets:precompile`—which should [also run `vite build`][deployment]—in a previous CI step.

You can verify your setup is working by disabling <kbd>[autoBuild]</kbd>. A convenient way to do that is to add `VITE_RUBY_AUTO_BUILD="false"` to the build environment variables.

[avoid rebuilds]: https://github.com/ElMassimo/vite_ruby/tree/main/examples/rails/spec/features/home_spec.rb#15
[publicOutputDir]: /config/#publicoutputdir
[port]: /config/#port
[ruby config]: /config/#ruby-configuration-file-💎
[deployment]: /guide/deployment
