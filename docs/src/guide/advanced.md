[tag helpers]: /guide/rails.html#tag-helpers-%F0%9F%8F%B7
[additionalEntrypoints]: /config/#additionalentrypoints
[entrypointsDir]: /config/#entrypointsdir
[sourceCodeDir]: /config/#sourcecodedir
[watchAdditionalPaths]: /config/#watchadditionalpaths
[entrypoints]: /guide/development.html#entrypoints-⤵%EF%B8%8F
[tag helpers]: /guide/development.html#tag-helpers-🏷
[CLI Command]: /guide/development.html#cli-commands-⌨%EF%B8%8F
[vite-plugin-ruby]: https://github.com/ElMassimo/vite_ruby/tree/main/vite-plugin-ruby
[config.json]: /config/#shared-configuration-file-📄
[sidecar assets]: https://viewcomponent.org/guide/javascript_and_css.html
[viewcomponent]: https://viewcomponent.org/
[glob imports]: https://vitejs.dev/guide/features.html#glob-import

# Advanced Usage

This section discusses settings that most projects don't need to configure
explicitly.

## Additional Entrypoints

By default, any files inside the <kbd>[entrypointsDir]</kbd> will be considered [entries to be bundled][entrypoints], allowing them to be referenced in [tag helpers].

If you need to reference files outside <kbd>[entrypointsDir]</kbd>, you can use <kbd>[additionalEntrypoints]</kbd> to configure additional entries to be bundled by Vite.

By default, it's configured to: `["~/{assets,fonts,icons,images}/**/*"]`, since
it's common to reference these files in [tag helpers]:

```ruby
vite_asset_path 'images/logo.svg' # app/frontend/images/logo.svg
```

If you would like to opt out from bundling these files, [configure it][config.json] as:

```json
    "additionalEntrypoints": []
```

## Bundling files outside sourceCodeDir

When using a library such as [`ViewComponent`][viewcomponent], it can be
convenient to group JS and CSS files within each component folder, which is called [sidecar assets].

There are a few options to achieve this, each with their pros and cons.

:::tip Required
Make sure to add `app/components/**/*` to <kbd>[watchAdditionalPaths]</kbd>, to
ensure the build is triggered when any of the component files changes.
:::

### Import every component

The simplest option is to leverage [glob imports] to import all components in a
single entrypoint, which is suitable for cases where there are few components,
or when all components should be registered in all pages.

```js
// app/frontend/entrypoints/application.js
import.meta.glob('../../components/**/*_component.js', { eager: true })
```

Any files imported from each `.js` file will be bundled as well.

### One entrypoint per component

To bundle each component independently, configure <kbd>[additionalEntrypoints]</kbd>:

```json
    "additionalEntrypoints": [
      "app/components/**/*_component.{js,ts}",
      "~/{assets,fonts,icons,images}/**/*"
    ]
```

and then reference them as needed in views or partials:

```erb
<%= vite_javascript_tag '/app/components/comment_component' %>
```
