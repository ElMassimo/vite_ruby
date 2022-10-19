<h2 align='center'><samp>vite-plugin-rails</samp></h2>

<p align='center'>Convention over configuration for Rails projects using Vite</p>

<p align='center'>
  <a href='https://www.npmjs.com/package/vite-plugin-rails'>
    <img src='https://img.shields.io/npm/v/vite-plugin-rails?color=222&style=flat-square'>
  </a>
  <a href='https://github.com/ElMassimo/vite_ruby/blob/master/LICENSE.txt'>
    <img src='https://img.shields.io/badge/license-MIT-blue.svg'>
  </a>
</p>

<br>

[vite_rails]: https://github.com/ElMassimo/vite_ruby/tree/main/vite_rails
[vite-plugin-ruby]: https://github.com/ElMassimo/vite_ruby/tree/main/vite-plugin-ruby
[configuration options]: https://github.com/ElMassimo/vite_ruby/tree/main/vite-plugin-rails/src/index.ts#L12-L84
[rollup-plugin-gzip]: https://github.com/kryops/rollup-plugin-gzip
[vite-plugin-environment]: https://github.com/ElMassimo/vite-plugin-environment
[vite-plugin-full-reload]: https://github.com/ElMassimo/vite-plugin-full-reload
[vite-plugin-stimulus-hmr]: https://github.com/ElMassimo/vite-plugin-stimulus-hmr
[vite-plugin-manifest-sri]: https://github.com/ElMassimo/vite-plugin-manifest-sri

## Installation 💿

In the future, [<kbd>vite_rails</kbd>][vite_rails] might install this plugin by default.

You can install it manually by running:

```bash
npm i vite-plugin-rails # yarn add vite-plugin-rails
```

## Usage 🚀

Add it to your plugins in `vite.config.ts`

```ts
// vite.config.ts
import Vue from '@vitejs/plugin-vue' // Example, could be using other plugins.
import ViteRails from 'vite-plugin-rails'

export default {
  plugins: [
    Vue(),
    ViteRails(),
  ],
};
```

## Batteries Included 🔋

Unlike [`vite-plugin-ruby`][vite-plugin-ruby], which provides the minimum amount of configuration necessary to get started, this plugin takes a Rails-approach of including plugins you would normally add.

You can configure each plugin by passing options, which are fully typed. See the [configuration options] for reference.

If you need finer-grained control, you can opt-out and use `vite-plugin-ruby` instead, manually adding only the plugins you need.

### [Ruby][vite-plugin-ruby]

[`vite-plugin-ruby`][vite-plugin-ruby] is added by default.

### Compression

This plugin uses [`rollup-plugin-gzip`][rollup-plugin-gzip] to create `gzip` and `brotli` compressed copies of your assets after build.

You can disable each manually:

```ts
    ViteRails({
      compress: { brotli: false }
    }),
```

```ts
    ViteRails({
      compress: false
    }),
```


### [Environment](https://github.com/ElMassimo/vite-plugin-environment)

[`vite-plugin-environment`][vite-plugin-environment] is used to expose environment variables to your
client code, using the [`import.meta.env`](https://vitejs.dev/guide/env-and-mode.html#env-files) convention from Vite.

This plugin allows you to conveniently provide defaults, or fail on required env variables:

```ts
    ViteRails({
      envVars: {
        API_KEY: null,
        OPTIONAL_KEY: '<opt-value>',
      },
    }),
```

### [Full Reload](https://github.com/ElMassimo/vite-plugin-full-reload)

[`vite-plugin-full-reload`][vite-plugin-full-reload] comes pre-configured to automatically reload the page
when making changes to server-rendered layouts and templates, improving the
feedback cycle.

You can override the default paths, or pass additional ones:

```ts
    ViteRails({
      fullReload: {
        additionalPaths: ['app/serializers/**/*']
      },
    }),
```

### [Stimulus HMR](https://github.com/ElMassimo/vite-plugin-stimulus-hmr)

[`vite-plugin-stimulus-hmr`][vite-plugin-stimulus-hmr] is included by default,
allowing you to see changes to your Stimulus controllers instantly without refreshing the page.

You can use the `stimulus` option if you need to configure it.

### [Subresource Integrity](https://github.com/ElMassimo/vite-plugin-manifest-sri)

[`vite-plugin-manifest-sri`][vite-plugin-manifest-sri] is included by default,
calculating a cryptographic hash for JavaScript and CSS assets, so that the browser
can verify the resources it fetches.

You can use the `sri` option if you need to configure it.

## License

This library is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
