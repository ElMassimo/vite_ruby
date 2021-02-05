[tag helpers]: /guide/development.html#tag-helpers-%F0%9F%8F%B7
[discussions]: https://github.com/ElMassimo/vite_rails/discussions
[rails]: https://rubyonrails.org/
[webpacker]: https://github.com/rails/webpacker
[vite rails]: https://github.com/ElMassimo/vite_rails
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
[entrypoints]: https://vitejs.dev/guide/build.html#multi-page-app
[vite_client_tag]: https://github.com/ElMassimo/vite_rails/blob/main/lib/vite_rails/helper.rb#L13-L17
[vite_javascript_tag]: https://github.com/ElMassimo/vite_rails/blob/main/lib/vite_rails/helper.rb#L28-L51
[vite_typescript_tag]: https://github.com/ElMassimo/vite_rails/blob/main/lib/vite_rails/helper.rb#L57-L59
[vite_stylesheet_tag]: https://github.com/ElMassimo/vite_rails/blob/main/lib/vite_rails/helper.rb#L62-L64
[vite_asset_path]: https://github.com/ElMassimo/vite_rails/blob/main/lib/vite_rails/helper.rb#L23-L25

# Developing with Vite

In this section, we'll cover the basics to get started with Vite on Rails.

## Development Server 💻

Run <kbd>bin/vite</kbd> to start a Vite development server.

It will read your [`config/vite.json`][json config] configuration, which can be
used to configure the `host` and `port`, as well as [other options][dev options].

## Auto-Build 🤖

Even when not running the Vite development server, _Vite Rails_ can detect if
any assets have changed in [`sourceCodeDir`][sourceCodeDir], and trigger a build
automatically when the asset is requested.

This is very convenient when running integration tests, or when a developer
does not want to start the Vite development server (at the expense of a slower feedback loop).

::: tip Enabled locally
By [default][json config], [`autoBuild`][autoBuild] is enabled in the <kbd>test</kbd> and <kbd>development</kbd> environments.
:::

## Entrypoints ⤵️

Drawing inspiration from [webpacker], any files in [`app/frontend/entrypoints`][build]
will be considered [entries][entrypoints] to your application (SPAs or pages).

```
app/frontend:
  ├── entrypoints:
  │   # only Vite entry files here
  │   └── application.js
  │   └── typography.css
  └── components:
  │   └── App.vue
  └── channels:
  │   │── index.js
  │   └── chat.js
  └── stylesheets:
  │   └── my_styles.css
  └── images:
      └── logo.svg
```

These files will be automatically detected and passed on to Vite, all [configuration][entrypoints] is done
for you.

You can add them to your HTML layouts or views using the provided [tag helpers].

## Tag Helpers 🏷

In order to link the JavaScript and CSS managed by Vite in your Rails layouts or
templates, you can by using the following helpers:

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
<%= vite_stylesheet_tag 'application' unless ViteRails.dev_server_running? %>
```

## Import Aliases 👉

For convenience, a `~/` import alias is configured to `app/frontend`, allowing
you to use absolute paths:

```js
import App from '~/components/App.vue'
import '~/channels'
```
