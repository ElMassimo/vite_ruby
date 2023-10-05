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
[entrypointsDir]: /config/#entrypointsdir
[autoBuild]: /config/#autobuild
[entrypoints]: /guide/development.html#entrypoints-⤵%EF%B8%8F
[helpers]: https://github.com/ElMassimo/vite_ruby/blob/main/vite_rails/lib/vite_rails/tag_helpers.rb
[development]: /guide/development
[vite_rails]: https://github.com/ElMassimo/vite_ruby/tree/main/vite_rails
[installed example]: https://github.com/ElMassimo/vite_ruby/tree/main/examples/rails
[jumpstart]: https://github.com/ElMassimo/jumpstart-vite
[vite-plugin-stimulus-hmr]: https://github.com/ElMassimo/vite-plugin-stimulus-hmr
[stimulus]: https://stimulus.hotwire.dev/
[vite-plugin-rails]: /guide/plugins.html#rails
[additionalEntrypoints]: /guide/advanced.html#additional-entrypoints

# Rails Integration

Once you have installed the <kbd>[vite_rails]</kbd> gem, and have run <kbd>bundle exec vite install</kbd>,
you should have an [installed example].

As an alternative, you could also use [this template][jumpstart] to [jumpstart] your app.

## Batteries Included 🔋

If you want a more opinionated setup, you can replace <kbd>vite-plugin-ruby</kbd> with <kbd>[vite-plugin-rails]</kbd>.

It will include [additional plugins][vite-plugin-rails] that users typically add in Rails apps.

## Tag Helpers 🏷

As we saw in the [development] section, [entrypoints] will be [automatically detected][entrypoints].

In order to link these JavaScript and CSS [entrypoints] managed by Vite in your Rails layouts or
templates, you can using the following helpers:

- <kbd>[vite_javascript_tag][helpers]</kbd>: Renders a `<script>` tag referencing a JavaScript file
- <kbd>[vite_typescript_tag][helpers]</kbd>: Renders a `<script>` tag referencing a TypeScript file
- <kbd>[vite_stylesheet_tag][helpers]</kbd>: Renders a `<link>` tag referencing a CSS file

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

If using `.jsx` or any pre-processor, make sure to be explicit:

```erb
<%= vite_javascript_tag 'application.tsx' %>
<%= vite_stylesheet_tag 'theme.scss' %>
```

For images you can use <kbd>[vite_image_tag][helpers]</kbd> or <kbd>[vite_picture_tag][helpers]</kbd> (Rails 7.1+):

```erb
<%= vite_image_tag 'images/logo.jpg' %>
<%= vite_picture_tag 'images/logo.avif', 'images/logo.jpg', image: {alt: 'example'}) %>
```

For other types of assets, you can use <kbd>[vite_asset_path][helpers]</kbd> and pass the resulting URI to the appropriate tag helper.

```erb
<link rel="apple-touch-icon" type="image/png" href="<%= vite_asset_path 'images/favicon.png' %>" />
<link rel="prefetch" href="<%= vite_asset_path 'typography.css' %>" />
```

Use <kbd>[vite_asset_url][helpers]</kbd> when you need the full URL:

```erb
<meta property="twitter:image" content="<%= vite_asset_url 'images/social-banner.png' %>">
```

All helpers resolve names to the <kbd>[entrypointsDir]</kbd>
unless the path includes a directory:

```ruby
vite_asset_path 'images/logo.svg' # app/frontend/images/logo.svg
vite_asset_path 'typography.css'  # app/frontend/entrypoints/typography.css
vite_asset_path 'logo.svg'        # app/frontend/entrypoints/logo.svg
```

:::warning Entrypoints Only
Make sure any files that are being referenced in tag helpers are [entrypoints].

Otherwise, Vite won't be [aware of these files][additionalEntrypoints] and won't bundle them.
:::

### Enabling Hot Module Reload 🔥

Use the following helpers to enable HMR in development:

- <kbd>[vite_client_tag][helpers]</kbd>: Renders the Vite client to enable Hot Module Reload
- <kbd>[vite_react_refresh_tag][helpers]</kbd>: Only when using `@vitejs/plugin-react`

They will only render if the dev server is running.

#### Hot Reload for Stimulus Controllers

If you are using [Stimulus], check out <kbd>[vite-plugin-stimulus-hmr]</kbd>.

You will no longer need to refresh the page when tweaking your controllers 😃

Comes installed by default in [this template][jumpstart].

### Smart Output ✨

For convenience, <kbd>[vite_javascript_tag][helpers]</kbd> will automatically inject tags for styles or entries imported within a script.

```erb
<%= vite_javascript_tag 'application' %>
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
