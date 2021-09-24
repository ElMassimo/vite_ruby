[tag helpers]: /guide/rails.html#tag-helpers-%F0%9F%8F%B7
[discussions]: https://github.com/ElMassimo/vite_ruby/discussions
[rails]: https://rubyonrails.org/
[webpacker]: https://github.com/rails/webpacker
[vite rails]: https://github.com/ElMassimo/vite_ruby
[vite]: https://vitejs.dev/
[vite-templates]: https://github.com/vitejs/vite/tree/main/packages/create-app
[plugins]: https://vitejs.dev/plugins/
[configuration reference]: /config/
[build]: /config/#build-options
[dev options]: /config/#development-options
[json config]: /config/#shared-configuration-file-%F0%9F%93%84
[vite config]: /config/#configuring-vite-%E2%9A%A1
[sourceCodeDir]: /config/#sourcecodedir
[autoBuild]: /config/#autobuild
[entrypoints]: /guide/development.html#entrypoints-⤵%EF%B8%8F
[helpers]: https://github.com/ElMassimo/vite_ruby/blob/main/vite_hanami/lib/vite_hanami/tag_helpers.rb
[development]: /guide/development
[vite_hanami]: https://github.com/ElMassimo/vite_ruby/tree/main/vite_hanami
[hanami]: https://hanamirb.org/
[installed example]: https://github.com/ElMassimo/vite_ruby/tree/main/examples/hanami_bookshelf

# Hanami Integration

Once you have installed the <kbd>[vite_hanami]</kbd> gem, and have run <kbd>bundle exec vite install</kbd>,
you should have an [installed example].

## Tag Helpers 🏷

As we saw in the [development] section, [entrypoints] will be [automatically detected][entrypoints].

In order to link the JavaScript and CSS managed by Vite in your Hanami views or
templates, you can use the following helpers:

- <kbd>[vite_javascript][helpers]</kbd>: Renders a `<script>` tag referencing a JavaScript file
- <kbd>[vite_typescript][helpers]</kbd>: Renders a `<script>` tag referencing a TypeScript file
- <kbd>[vite_stylesheet][helpers]</kbd>: Renders a `<link>` tag referencing a CSS file

You can pass any options supported by <kbd>javascript</kbd> and <kbd>stylesheet</kbd>.

```erb
<head>
  <title>Example</title>
  <%= favicon %>
  <%= vite_client %>

  <%= vite_stylesheet 'styles' %>
  <%= vite_typescript 'application' %>
</head>
```

For other types of assets, you can use <kbd>[vite_asset_path][helpers]</kbd> and pass the resulting URI to the appropriate tag helper.

```erb
<img src="<%= vite_asset_path 'images/logo.svg' %>" />
<link rel="prefetch" href="<%= vite_asset_path 'typography.css' %>" />
```

All helpers resolve names to the <kbd>[entrypointsDir]</kbd>
unless the path includes a directory:

```ruby
vite_asset_path 'logo.svg'        # app/frontend/entrypoints/logo.svg
vite_asset_path 'images/logo.svg' # app/frontend/images/logo.svg
```

### Enabling Hot Module Reload 🔥

Use the following helpers to enable HMR in development:

- <kbd>[vite_client][helpers]</kbd>: Renders the Vite client to enable Hot Module Reload
- <kbd>[vite_react_refresh][helpers]</kbd>: Only when using `@vitejs/plugin-react`

They will only render if the dev server is running.

### Smart Output ✨

For convenience, <kbd>[vite_javascript][helpers]</kbd> will automatically inject tags for styles or entries imported within a script.

```erb
<%= vite_javascript 'application' %>
```

Example output:

```erb
<script src="/vite/assets/application.a0ba047e.js" type="module" crossorigin="anonymous"/>
<link rel="modulepreload" href="/vite/assets/example_import.8e1fddc0.js" as="script" type="text/javascript" crossorigin="anonymous">
<link rel="stylesheet" media="screen" href="/vite/assets/application.cccfef34.css">
```

When running the development server, these tags are omitted, as Vite will load the dependencies.

```erb
<script src="/vite/assets/application.js" type="module" crossorigin="anonymous"/>
```
