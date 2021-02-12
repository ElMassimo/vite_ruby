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

# Migrating to Vite

If you would like to add a note about Sprockets, pull requests are welcome!

## Starting Fresh ☀️

When starting a new project, following the [guide] should automatically set up
the basic structure under `app/frontend` where you can place your JavaScript,
styles, and other assets.

## Webpacker 📦

When migrating from [Webpacker], the installation script will detect if the
`app/javascript` directory exists, and use that in your `config/vite.json`
instead of the [default][sourceCodeDir].

```json
{
  "all": {
    "sourceCodeDir": "app/javascript",
    ...
```

That way you don't have to move code around, and can proceed to copying your
[entries][entrypoints] in `app/javascript/packs` to [`app/javascript/entrypoints`][entrypointsDir].

You might also need to:

- Explicitly add a file extension to any non-JS imports.
- Replace <kbd>javascript_packs_with_chunks_tag</kbd> with <kbd>vite_javascript_tag</kbd>.
- Replace <kbd>asset_pack_path</kbd> with <kbd>vite_assets_path</kbd>, same for stylesheets.
- For complex or deeply nested dynamic imports, use [`import.meta.glob`](https://vitejs.dev/guide/features.html#glob-import).

Check [this migration from Webpacker](https://github.com/ElMassimo/pingcrm-vite/pull/1) as an example.

::: tip Compatibily Note
Before migrating from [Webpacker], make sure that you are not using any loaders
that don't have a counterpart in [Vite], which uses [Rollup] when bundling for production.
:::


<br>
<hr>
<br>

If you are looking for configuration options, check out the [configuration reference].

Would you like to learn more about it? Visit the [discussions] for the library,
so that I can get some feedback about the library and which guides to add next.
