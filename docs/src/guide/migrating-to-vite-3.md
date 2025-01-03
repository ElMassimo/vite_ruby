[upgrade]: https://vite-ruby.netlify.app/guide/development.html#cli-commands-%E2%8C%A8%EF%B8%8F
[Migration Guide]: https://vitejs.dev/guide/migration.html
[Changelog]: https://github.com/vitejs/vite/blob/main/packages/vite/CHANGELOG.md#300-2022-07-13
[stimulus-vite-helpers]: https://github.com/ElMassimo/stimulus-vite-helpers

# Upgrading to Vite 3

[Vite 3 has been released](https://vitejs.dev/blog/announcing-vite3.html)!

Check the [Migration Guide] and the [Changelog] for more information.

## Upgrading in Vite Ruby

### Migrating to Vite 3

Follow Vite's [Migration Guide] and read the [Changelog] for more information.

For most _Vite Ruby_ apps, you'll likely be able to upgrade without having to make any code changes.

You can upgrade by running <kbd>[bin/vite upgrade][upgrade]</kbd>, which will bump `vite_ruby` and any related dependencies to the latest version.

::: tip Latest Version
At the time of writing, the latest version is `vite_ruby-3.2.0`, targeting the new Vite 3 release.
:::

::: tip Version Numbers
From now on, versions of `vite_ruby` will match Vite's major version number, for simplicity.
:::

#### `import.meta.glob` changes

In Vite 3, [`import.meta.glob`](https://vitejs.dev/guide/migration.html#import-meta-glob) will use keys relative to the current module.

```ts
// app/frontend/controllers/index.js
const controllers = import.meta.glob('../**/*_controller.js', { eager: true })
```

That code now transforms to:

```diff
const controllers = {
-  '../controllers/home_controller.js': () => {}
+  './home_controller.js': () => {}
}
```

This can affect any usages that rely on the full path, such as when using <kbd>[stimulus-vite-helpers]</kbd>.

Depending on the the pattern you might not need to make any changes, but if you
need the full path, you can leverage the new support for aliases:

```ts
const controllers = import.meta.glob('~/controllers/**/*_controller.js', { eager: true })
```

:::tip Prefer Aliases
An advantage of using aliases is that it's more explicit, works regardless of
the file location, making it more robust when refactoring.
:::
