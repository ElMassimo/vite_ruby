[tag helpers]: /guide/rails.html#tag-helpers-%F0%9F%8F%B7
[additionalEntrypoints]: /config/#additionalentrypoints
[entrypointsDir]: /config/#entrypointsdir
[sourceCodeDir]: /config/#sourcecodedir
[entrypoints]: /guide/development.html#entrypoints-⤵%EF%B8%8F
[tag helpers]: /guide/development.html#tag-helpers-🏷
[CLI Command]: /guide/development.html#cli-commands-⌨%EF%B8%8F
[vite-plugin-ruby]: https://github.com/ElMassimo/vite_ruby/tree/main/vite-plugin-ruby

# Migrating to Vite Ruby v3

This section is intended to guide early adopters to upgrade from Vite Rails v2
to v3.

## New Features ✨

### Safer Upgrades

<kbd>bin/vite upgrade</kbd> is a new [CLI command] to easily upgrade any
Vite Ruby gems you are using, as well as the <kbd>[vite-plugin-ruby]</kbd> npm
package, to compatible versions.

### Additional Entrypoints

<kbd>[additionalEntrypoints]</kbd> is a new configuration option to specify [entrypoints].

By default it adds <code><kbd>[sourceCodeDir]</kbd>/{assets,fonts,icons,images}/**/*</code>, so you can now reference these files using [tag helpers] instead of having to place them inside <kbd>[entrypointsDir]</kbd>.

```ruby
vite_asset_path 'images/logo.svg' # app/frontend/images/logo.svg
```

## Breaking Changes 🧨

### Nested entrypoints paths must be explicit

Any paths without a parent dir will be resolved to the <kbd>[entrypointsDir]</kbd>:

```ruby
vite_javascript_tag 'application' # entrypoints/application.js
```

But for entrypoints in a nested directory in <kbd>[entrypointsDir]</kbd>,
the path must now be explicit:

<div class="language-">
  <pre>
<code>app/frontend: <kbd><a href="/config/#sourcecodedir">sourceCodeDir</a></kbd>
  └── entrypoints: <kbd><a href="/config/#entrypointsdir">entrypointsDir</a></kbd>
      ├── nested:
      │   └── application.js
      └── images
          └── logo.svg</code>
</pre>
</div>

```ruby
❌ vite_javascript_tag 'nested/application'
✅ vite_javascript_tag 'entrypoints/nested/application'

❌ vite_asset_path 'images/logo.svg'
✅ vite_asset_path 'entrypoints/images/logo.svg'
```

For assets located inside <kbd>[entrypointsDir]</kbd> there is now a [better
solution][additionalEntrypoints] as described in the previous section, which is
to place assets in one of the default <kbd>[additionalEntrypoints]</kbd> dirs:

```diff
- app/frontend/entrypoints/images/logo.svg
+ app/frontend/images/logo.svg
``` 

<div class="language-">
  <pre>
<code>app/frontend: <kbd><a href="/config/#sourcecodedir">sourceCodeDir</a></kbd>
  ├── entrypoints: <kbd><a href="/config/#entrypointsdir">entrypointsDir</a></kbd>
  │   └── nested:
  │       └── application.js
  └── images
      └── logo.svg</code>
</pre>
</div>

```ruby
✅ vite_javascript_tag 'entrypoints/nested/application'
✅ vite_asset_path 'images/logo.svg'
```

<br/><br/><br/><br/><br/><br/><br/>
