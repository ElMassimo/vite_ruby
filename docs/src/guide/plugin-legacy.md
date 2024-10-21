[vite_plugin_legacy]: https://github.com/ElMassimo/vite_ruby/tree/main/vite_plugin_legacy
[plugin-legacy]: https://github.com/vitejs/vite/tree/main/packages/plugin-legacy
[vite_legacy_javascript_tag]: https://github.com/ElMassimo/vite_ruby/blob/main/vite_plugin_legacy/lib/vite_plugin_legacy/tag_helpers.rb

# Plugin Legacy

When using <kbd>[@vitejs/plugin-legacy][plugin-legacy]</kbd>, it's necessary to
use additional tag helpers to output `nomodule` script tags and polyfills.

## Installation 💿

Add this line to your application's Gemfile:

```ruby
gem 'vite_plugin_legacy'
```

And then run:

```
bundle install
```

## Tag Helpers 🏷

In order to include the polyfills and script tags you can using the following helpers:

- <kbd>[vite_legacy_javascript_tag]</kbd>: Render a `<script>` tag referencing a JavaScript or TypeScript entrypoints.


```erb
<head>
  <title>Example</title>
  <%= csrf_meta_tags %>
  <%= csp_meta_tag %>
  <%= vite_client_tag %>

  <%= vite_legacy_javascript_tag 'application' => :javascript %>
  <%= vite_javascript_tag 'application' %>
</head>
<body>
  <%= yield %>
</body>
```

Notice that it's necessary to still use `vite_javascript_tag` in order to render `module` tags for modern browsers.
