[project]: https://github.com/ElMassimo/vite_ruby
[vite-plugin-full-reload]: https://github.com/ElMassimo/vite-plugin-full-reload
[tailwind-vite]: https://tailwindcss.com/docs/installation/using-vite
[example app]: https://github.com/ElMassimo/vite_ruby/tree/main/examples/rails/vite.config.ts
[Vite Ruby]: https://github.com/ElMassimo/vite_ruby
[JS From Routes]: https://js-from-routes.netlify.app/
[Tailwind CSS]: https://tailwindcss.com/
[vite-plugin-stimulus-hmr]: https://github.com/ElMassimo/vite-plugin-stimulus-hmr
[jumpstart]: https://github.com/ElMassimo/jumpstart-vite
[stimulus]: https://stimulus.hotwire.dev/
[stimulus-vite-helpers]: https://github.com/ElMassimo/stimulus-vite-helpers
[glob import]: https://vite.dev/guide/features.html#glob-import
[plugins]: https://vite.dev/plugins/
[sourceCodeDir]: /config/#sourcecodedir
[import meta env]: https://vite.dev/guide/env-and-mode.html#env-variables
[meta env]: https://vite.dev/guide/env-and-mode.html#env-files
[vite-plugin-environment]: https://github.com/ElMassimo/vite-plugin-environment
[vite-plugin-rails]: https://github.com/ElMassimo/vite_ruby/tree/main/vite-plugin-rails
[rollup-plugin-gzip]: https://github.com/kryops/rollup-plugin-gzip

# Recommended Plugins

Using [Vite Ruby][project] is even more enjoyable with the following plugins.

Check the [example app] for a sample setup with most of them.

::: tip Official Vite.js Plugins

When using Vue, React, or Svelte, check out [Vite][plugins]'s __[official plugins][plugins]__.
:::

## [Rails](https://github.com/ElMassimo/vite_ruby/tree/main/vite-plugin-rails)

<kbd>[vite-plugin-rails]</kbd> provides a shortcut for installing and
configuring the following plugins for a typical Rails application:

- <kbd>[vite-plugin-environment]</kbd>
- <kbd>[vite-plugin-full-reload]</kbd>
- <kbd>[vite-plugin-stimulus-hmr]</kbd>
- <kbd>[rollup-plugin-gzip]</kbd>: pre-configured to compress assets using `gzip` and `brotli`

In the future, `vite_rails` might install this plugin by default.

```ts
plugins: [
  Rails({
    envVars: { RAILS_ENV: 'development' },
  }),
],
```

::: tip
You can opt-out and use `vite-plugin-ruby` instead, manually adding only the plugins you need.
:::

## [Environment](https://github.com/ElMassimo/vite-plugin-environment)

Use <kbd>[vite-plugin-environment]</kbd> to expose environment variables to your
client code.  

```ts
plugins: [
  Environment(['NODE_ENV', 'API_KEY', 'APP_VERSION']),
```

::: tip
Use it only when it's not possible or desirable to [prefix variables with `VITE_`][meta env],
or if using [`import.meta.env`][import meta env] in the client code is not an option.
:::

## [Full Reload](https://github.com/ElMassimo/vite-plugin-full-reload)

Use <kbd>[vite-plugin-full-reload]</kbd> to automatically reload the page when making changes to server-rendered layouts and templates, improving the feedback cycle.

Works nicely in combination with [JS From Routes](#js-from-routes).

```ts
plugins: [
  FullReload(['config/routes.rb', 'app/views/**/*'], { delay: 200 })
```

## [JS From Routes](https://js-from-routes.netlify.app/)

Use <kbd>[js_from_routes][js from routes]</kbd> to generate path helpers and API methods from your Rails routes.

Forget about hard-coding URLs and enjoy a safer and smoother API layer.

```ts
import { videoClips } from '~/api'

const video = await videoClips.get({ id: '5' })

const path = videoClips.download.path(video) // "/video_clips/5/download"
```

## [Stimulus Helpers](https://github.com/ElMassimo/stimulus-vite-helpers)

Use <kbd>[stimulus-vite-helpers]</kbd> to easily register all [Stimulus] controllers using [`import.meta.glob`][glob import].

```ts
const controllers = import.meta.glob('./**/*_controller.js', { eager: true })
registerControllers(application, controllers)
```

Comes installed by default in [this template][jumpstart].

## [Stimulus HMR](https://github.com/ElMassimo/vite-plugin-stimulus-hmr)

Use <kbd>[vite-plugin-stimulus-hmr]</kbd> to enable HMR for [Stimulus].

See changes to your controllers instantly without refreshing the page.

```ts
plugins: [
  StimulusHMR(),
```

## [Tailwind CSS 4][Tailwind CSS]

Use the official <kbd>[@tailwindcss/vite][tailwind-vite]</kbd> plugin to integrate Tailwind CSS 4 with Vite.

```ts
plugins: [
  tailwindcss(),
```

Import Tailwind in your application stylesheet:

```css
@import "tailwindcss";
```

Tailwind CSS 4 can be configured to detect classes in both frontend code and server-rendered templates.

Add <kbd>[vite-plugin-full-reload](/guide/plugins.html#full-reload)</kbd> when template changes should also refresh the page.
