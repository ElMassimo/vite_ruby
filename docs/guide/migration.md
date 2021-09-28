[tag helpers]: /guide/rails.html#tag-helpers-%F0%9F%8F%B7
[discussions]: https://github.com/ElMassimo/vite_ruby/discussions
[rails]: https://rubyonrails.org/
[webpacker]: https://github.com/rails/webpacker
[vite rails]: https://github.com/ElMassimo/vite_ruby
[vite]: https://vitejs.dev/
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

# Migrating to Vite

If you would like to add a note about Sprockets, pull requests are welcome!

## Starting Fresh ☀️

When starting a new project, follow the [guide], and you should have a [basic setup][sourceCodeDir]
where you can place your JavaScript, stylesheets, and other assets.

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

- Replace `require.context` with [`import.meta.glob`][glob] or [`import.meta.globEager`][glob].

  ```diff
  - const context = require.context("./controllers", true, /\.js$/)
  + const controllers = import.meta.globEager('./**/*_controller.js')
  ```

- If importing code that is located outside of the <kbd>[sourceCodeDir]</kbd>, make sure to add a [glob expression](https://github.com/ElMassimo/vite_ruby/blob/main/vite_ruby/lib/vite_ruby/builder.rb#L97) in <kbd>[watchAdditionalPaths]</kbd>, so that changes to these files are detected, and trigger a recompilation. 

- If you were using <kbd>[rails-erb-loader]</kbd>, you might want to check <kbd>[vite-plugin-erb]</kbd> to ease the transition, but it's better to avoid mixing ERB in frontend assets.

- Make sure <kbd>[npx]</kbd> is available (comes by default in most node.js installations), or [clear][clear rake] the <kbd>[vite:install_dependencies]</kbd> rake task and provide your own implementation.

::: tip Compatibility Note
Before migrating from [Webpacker], make sure that you are not using any loaders
that don't have a counterpart in [Vite], which uses [Rollup] when bundling for production.
:::
