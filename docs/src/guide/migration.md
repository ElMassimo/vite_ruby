[tag helpers]: /guide/rails.html#tag-helpers-%F0%9F%8F%B7
[discussions]: https://github.com/ElMassimo/vite_ruby/discussions
[rails]: https://rubyonrails.org/
[webpacker]: https://github.com/rails/webpacker
[vite rails]: https://github.com/ElMassimo/vite_ruby
[vite]: https://vitejs.dev/guide/using-plugins.html
[rollup]: https://rollupjs.org/guide/en/
[entrypoints]: /guide/development.html#entrypoints-⤵%EF%B8%8F
[guide]: /guide/
[configuration reference]: /config/
[sourceCodeDir]: /config/#sourcecodedir
[entrypointsDir]: /config/#entrypointsdir
[watchAdditionalPaths]: /config/#watchadditionalpaths
[glob]: https://vitejs.dev/guide/features.html#glob-import
[clear rake]: https://www.rubydoc.info/gems/rake/Rake%2FTask:clear
[vite:install_dependencies]: https://github.com/ElMassimo/vite_ruby/blob/main/vite_ruby/lib/tasks/vite.rake#L32-L35
[npx]: https://docs.npmjs.com/cli/v7/commands/npx
[vite-plugin-erb]: https://github.com/ElMassimo/vite-plugin-erb
[rails-erb-loader]: https://github.com/usabilityhub/rails-erb-loader
[tag helpers]: /guide/development.html#tag-helpers-🏷
[Troubleshooting]: /guide/troubleshooting
[import aliases]: /guide/development.html#import-aliases-👉
[assets pipeline]: https://guides.rubyonrails.org/asset_pipeline.html
[glob expression]: https://github.com/ElMassimo/vite_ruby/blob/eeccd3fc4e7db9524a2bd1075ca1282f3f53c029/vite-plugin-ruby/example/config/vite.json#L9
[resolve.alias]: https://vitejs.dev/config/#resolve-alias
[sprockets]: https://github.com/rails/sprockets-rails
[sprockets example]: https://github.com/ElMassimo/vite_ruby/pull/165
[stimulus-vite-helpers]: https://github.com/ElMassimo/stimulus-vite-helpers

# Migrating to Vite

If you would like to add a note about other setups, pull requests are welcome!

## Starting Fresh ☀️

When starting a new project, follow the [guide], and you should have a [basic setup][sourceCodeDir]
where you can place your JavaScript, stylesheets, and other assets.

## Sprockets ⚙️

If you would like to remove sprockets and use Vite Ruby alone, you can [follow this example][sprockets example].

Have in mind that this is optional, as both approaches can coexist without issues.

## Webpacker 📦

When migrating from [Webpacker], start by following the [guide] to get a [basic setup][sourceCodeDir] working before proceeding to migrate existing code.

During installation, Vite Ruby detect if the `app/javascript` directory exists,
and use that in your `config/vite.json` instead of the [default][sourceCodeDir].

```json
{
  "all": {
    "sourceCodeDir": "app/javascript",
    ...
```

:::tip One entry at a time
The recommended approach for medium-to-large-sized applications is to migrate
one entrypoint at a time if possible. Gradually move each [file][entrypoints] in `app/javascript/packs` (managed by Webpacker) to [`app/javascript/entrypoints`][entrypointsDir] (managed by Vite Ruby).

Check [this migration from Webpacker](https://github.com/ElMassimo/pingcrm-vite/pull/1) as an example.
:::

Proceed to fix any errors that occur (i.e. differences between Webpack and Vite.js) by checking the _[Troubleshooting]_ section and the following __recommendations__:

- Explicitly add a file extension to any non-JS imports.

  ```diff
  - import TextInput from '@/components/TextInput'
  + import TextInput from '@/components/TextInput.vue'
  ```

  The same is true, when importing <kbd>.svelte</kbd> or <kbd>.scss</kbd> files from Javascript.

- Replace usages of [tag helpers] as you move the [entrypoints].

  ```diff
  + <%= vite_client_tag %>

  - <%= stylesheet_pack_tag 'application' %>
  - <%= javascript_packs_with_chunks_tag 'application' %>
  + <%= vite_javascript_tag 'application' %>

  - <%= stylesheet_pack_tag 'mobile' %>
  + <%= vite_stylesheet_tag 'mobile' %>

  - <img src="<%= asset_pack_path('images/logo.svg') %>">
  + <img src="<%= vite_asset_path('images/logo.svg') %>">
  ```

- Replace `require.context` with [`import.meta.glob`][glob].

  ```diff
  - const context = require.context("./controllers", true, /\.js$/)
  + const controllers = import.meta.glob('./**/*_controller.js', { eager: true })
  ```

  If you want to automatically register the Stimulus Controllers, have a look at <kbd>[stimulus-vite-helpers]</kbd> as a replacement for <kbd>@hotwired/stimulus-webpack-helpers</kbd>

- If importing code that is located outside of the <kbd>[sourceCodeDir]</kbd>, make sure to add a [glob expression] in <kbd>[watchAdditionalPaths]</kbd>, so that changes to these files are detected, and trigger a recompilation.

- If you were using <kbd>[rails-erb-loader]</kbd>, you might want to check <kbd>[vite-plugin-erb]</kbd> to ease the transition, but it's better to avoid mixing ERB in frontend assets.

- Make sure <kbd>[npx]</kbd> is available (comes by default in most node.js installations), or [clear][clear rake] the <kbd>[vite:install_dependencies]</kbd> rake task and provide your own implementation.

- If you are importing your own source code without absolute path prefix (such as ``@/`` or ``~/``) you can either prefix all imports with ``@/``:

  ```diff

  - import MyModule from "admin/components/MyModule.vue"
  + import MyModule from "@/admin/components/MyModule.vue"
  ```

  <details>
    <summary>Or you can define an <kbd>alias</kbd> for every folder under <kbd>sourceCodeDir</kbd>:</summary>

    ```javascript
    // vite.config.js
    import path from 'path';
    import fs from 'fs'

    const sourceCodeDir = "app/javascript"
    const items = fs.readdirSync(sourceCodeDir)
    const directories = items.filter(item => fs.lstatSync(path.join(sourceCodeDir, item)).isDirectory())
    const aliasesFromJavascriptRoot = {}
    directories.forEach(directory => {
      aliasesFromJavascriptRoot[directory] = path.resolve(__dirname, sourceCodeDir, directory)
    })
    export default defineConfig({
      resolve: {
        alias: {
          ...aliasesFromJavascriptRoot,
          // can add more aliases, as "old" images or "@assets", see below
          images: path.resolve(__dirname, './app/assets/images'),
        },
      },
    ```
  </details>

::: tip Loaders to Plugins
Vite provides many features [out of the box], which reduce the
need for configuration. For example, to use SCSS just install <kbd>sass</kbd>, and Vite will detect the package and use it to process `.scss` files.

In complex setups, the app might depend on specific webpack loaders, which can't
be used in Vite, which uses [Rollup] under the hood.

Check [Vite Rollup Plugins] and [Awesome Vite] to find equivalent plugins.
:::

[Vite Rollup Plugins]: https://vite-rollup-plugins.patak.dev/
[Awesome Vite]: https://github.com/vitejs/awesome-vite#plugins
[out of the box]: https://vitejs.dev/guide/features.html

## Assets 🎨

It's recommended that you locate assets under the <kbd>[sourceCodeDir]</kbd>,
which requires no additional configuration. You can use [import aliases] to
easily reference them.

However, during a migration it can be convenient to reference files that are
still being used through the [assets pipeline], such as fonts in `app/assets`.

In that case, you should add [`app/assets/**/*`][glob expression] to <kbd>[watchAdditionalPaths]</kbd> to track changes to these files and trigger a rebuild when needed.

In order to reference these files it's highly recommended to [define][resolve.alias] your own [import aliases]:

```js{7}
import { resolve } from 'path'
import { defineConfig } from 'vite'

export default defineConfig({
  resolve: {
    alias: {
      '@assets': resolve(__dirname, 'app/assets'),
    },
  },
})
```

Remember to update any references to these files, for example, in
stylesheets processed by Vite:

```diff
@font-face {
  font-family: 'OpenSans';
- src: font-url('OpenSans.woff2');
+ src: url('@assets/fonts/OpenSans.woff2');
}
```

Once you have finished the migration, you can move all assets under <kbd>[sourceCodeDir]</kbd>:

```diff
@font-face {
  font-family: 'OpenSans';
- src: url('@assets/fonts/OpenSans.woff2');
+ src: url('@/fonts/OpenSans.woff2');
}
```
