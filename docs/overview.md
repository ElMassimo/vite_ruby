[vite ruby]: /
[vite_ruby]: https://github.com/ElMassimo/vite_ruby/tree/main/vite_ruby
[vite-plugin-ruby]: https://github.com/ElMassimo/vite_ruby/tree/main/vite-plugin-ruby
[rails]: https://rubyonrails.org/
[webpack]: https://webpack.js.org/
[webpacker]: https://github.com/rails/webpacker
[vite.js]: https://vitejs.dev/
[guide]: /guide/
[why vite]: https://vitejs.dev/guide/why.html#slow-server-start
[assets pipeline]: https://github.com/rails/sprockets/blob/master/guides/how_sprockets_works.md
[plugin]: https://vitejs.dev/guide/using-plugins.html
[Rack]: https://github.com/rack/rack
[entrypoints]: /guide/development.html#entrypoints-⤵%EF%B8%8F
[deployment]: /guide/deployment
[preload]: /guide/rails.html#smart-output-✨
[autobuild]: /guide/development.html#auto-build-🤖
[publicDir]: /config/#publicdir
[publicOutputDir]: /config/#publicoutputdir
[tag helpers]: /guide/development.html#tag-helpers-🏷
[commands]: /guide/development.html#cli-commands-⌨%EF%B8%8F
[development]: /guide/development
[assetHost]: /config/#assethost
[vite_client_tag]: /guide/rails.html#enabling-hot-module-reload-🔥

# Overview

This section provides a high-level overview of how this library interacts with
[Rails] and [Vite.js], and is intended for users that would like to know more
about the internals of the library.

For usage instructions, please refer to [the guide][guide] instead.

## Rack and Rails <img class="logo" src="https://rubyonrails.org/assets/images/favicon.ico" alt="Logo"/>

The following conventions are common in [Rack]-based applications:

  - The `public` directory contains static and compiled assets, and will be exposed as-is.

  - <kbd>rake assets:precompile</kbd> will process CSS and JS files in the project, and write the result in a subdirectory under `public`.

## Vite.js <img class="logo" src="https://vitejs.dev/logo.svg" alt="Logo"/>

In production, Vite.js will bundle assets for efficiency and write the result to an **output directory**—just like [webpack] or the [assets pipeline].

The main difference is that in development it will leverage native ESM to transform
and serve source on demand, [**as the browser requests it**][why vite]. Any code
that is not imported in the current page will not be processed nor served.


## Vite Ruby <img class="logo" src="/logo.svg" alt="Logo"/>

This library consists of two main components:

  - <kbd>[vite-plugin-ruby]</kbd>: This [plugin] configures Vite making it easier to use in a typical Ruby application by configuring [entrypoints], [directories][publicDir], and [other configuration options][assetHost]

  - <kbd>[vite_ruby]</kbd>: This gem is the [glue][tag helpers] between [Rack] applications and Vite

Vite.js and the plugin are used during [development] and [deployment],
but not once an application is live in production. In contrast, the gem is used in production as well.

### In Development

When the Vite development server is running, _Vite Ruby_ will proxy requests to it
allowing files to be processed and served **on demand**.

No files are written to the `public` directory.

:::tip Instant Updates ⚡️
When using <kbd>[vite_client_tag]</kbd>, the browser will establish
a WebSocket connection with the Vite development server in order to
receive notifications whenever a module has been invalidated and should be
re-fetched (usually when the user edits the source code).
:::

### In Production

_Vite Ruby_ extends <kbd>assets:precompile</kbd> to [perform a Vite.js build][deployment]— processed assets are placed [inside][publicOutputDir] the `public` folder.

The build also generates a manifest with metadata which allows to
map the original file names to their fingerprinted equivalent in the bundle, and
specifies other dependencies such as stylesheets or nested imports.

This metadata is used by _Vite Ruby_ in [tag helpers] to map file names when rendering URLs, and render [additional `link` tags][preload].

The resulting URLs will correspond to files in the `public` directory, which may
be served by the web application or by a [CDN][deployment].

### Auto-Build

If Vite is not running, _Vite Ruby_ can [detect if files have changed and rebuild as needed][autobuild].

The resulting fingerprinted assets are then served from `public`, just as in production.

This mode is typically used during CI, as the source code will not be modified
and fast updates are not a concern.
