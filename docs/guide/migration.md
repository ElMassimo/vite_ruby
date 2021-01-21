[tag helpers]: /guide/development.html#tag-helpers-%F0%9F%8F%B7
[discussions]: https://github.com/ElMassimo/vite_rails/discussions
[rails]: https://rubyonrails.org/
[webpacker]: https://github.com/rails/webpacker
[vite rails]: https://github.com/ElMassimo/vite_rails
[vite]: https://vitejs.dev/
[rollup]: https://rollupjs.org/guide/en/
[entrypoints]: /guide/development.html#entrypoints-⤵%EF%B8%8F
[guide]: /guide/
[configuration reference]: /config/

# Migrating to Vite

If you would like to add a note about Sprockets, pull requests are welcome!

## Starting Fresh ☀️

When starting a new project, following the [guide] should automatically set up
the basic structure under `app/frontend` where you can place your JavaScript,
styles, and other assets.

## Webpacker 📦

When migrating from [Webpacker], assuming you were placing your packs in `app/javascript/packs`, it might be convenient to change <kbd>sourceCodeDir</kbd> in your `config/vite.json`.

```json
{
  "all": {
    "sourceCodeDir": "app/javascript",
    ...
```

That way you don't have to move code around, and can proceed to copying your
[entries][entrypoints] in `app/javascript/packs` to `app/javascript/entrypoints`.

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
