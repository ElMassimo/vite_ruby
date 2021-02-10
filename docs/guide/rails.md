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
[vite_client_tag]: https://github.com/ElMassimo/vite_ruby/blob/main/vite_rails/lib/vite_rails/tag_helpers.rb
[vite_javascript_tag]: https://github.com/ElMassimo/vite_ruby/blob/main/vite_rails/lib/vite_rails/tag_helpers.rb
[vite_typescript_tag]: https://github.com/ElMassimo/vite_ruby/blob/main/vite_rails/lib/vite_rails/tag_helpers.rb
[vite_stylesheet_tag]: https://github.com/ElMassimo/vite_ruby/blob/main/vite_rails/lib/vite_rails/tag_helpers.rb
[vite_asset_path]: https://github.com/ElMassimo/vite_ruby/blob/main/vite_rails/lib/vite_rails/tag_helpers.rb
[development]: /development
[vite_rails]: https://github.com/ElMassimo/vite_ruby/tree/main/vite_rails

# Development in Rails

If not using <kbd>[vite_rails]</kbd> gem, skip this section.

As we saw in the [development] section, [entrypoints] will be [automatically
detected][entrypoints].

Once you have installed the <kbd>[vite_rails]</kbd> gem, and run <kbd>bundle exec vite install</kbd>,
you should have an installed example.

## Tag Helpers 🏷

In order to link the JavaScript and CSS managed by Vite in your Rails layouts or
templates, you can using the following helpers:

- <kbd>[vite_client_tag]</kbd>: Renders the Vite client to enable Hot Module Reload.
- <kbd>[vite_javascript_tag]</kbd>: Render a `<script>` tag referencing a JavaScript file.
- <kbd>[vite_typescript_tag]</kbd>: Render a `<script>` tag referencing a TypeScript file.
- <kbd>[vite_stylesheet_tag]</kbd>: Render a `<link>` tag referencing a CSS file.

You can pass any options supported by <kbd>javascript_include_tag</kbd> and <kbd>stylesheet_link_tag</kbd>.

```erb
<head>
  <title>Example</title>
  <%= csrf_meta_tags %>
  <%= csp_meta_tag %>
  <%= vite_client_tag %>

  <%= vite_javascript_tag 'application' %>
  <%= vite_stylesheet_tag 'typography', media: 'print' %>
</head>
```

For other types of assets, you can use <kbd>[vite_asset_path]</kbd> and pass the resulting URI to the appropriate tag helper.

```erb
<img src="<%= vite_asset_path 'images/logo.svg' %>" />
<link rel="prefetch" href="<%= vite_asset_path 'typography.css' %>" />
```

### Smart Output ✨

For convenience, <kbd>[vite_javascript_tag]</kbd> will automatically inject tags for styles or entries imported within a script.

```erb
<%= vite_javascript_tag 'application' %>
```

Example output:
```erb
<script src="/vite/assets/application.a0ba047e.js" type="module" crossorigin="anonymous"/>
<link rel="preload" href="/vite/assets/example_import.8e1fddc0.js" as="script" type="text/javascript" crossorigin="anonymous">
<link rel="stylesheet" media="screen" href="/vite/assets/application.cccfef34.css">
```

When running the development server, these tags are omitted, as Vite will load the dependencies.

```erb
<script src="/vite/assets/application.js" type="module" crossorigin="anonymous"/>
```

#### Opting Out ⚙️

For cases where tags need be managed manually, it's possible to opt out by using the options:

- <kbd>skip_preload_tags</kbd>: Set to false to avoid rendering `<link rel="preload">` tags.
- <kbd>skip_style_tags</kbd>: Set to false to avoid rendering `<link rel="stylesheet">` tags.

When rendering styles and preload manually, it's important to avoid rendering when the Vite development server is running, since the files don't exist yet:

```erb
<%= vite_typescript_tag 'application', skip_style_tags: true %>
<%= vite_stylesheet_tag 'application' unless ViteRuby.dev_server_running? %>
```
