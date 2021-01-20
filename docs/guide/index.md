[rails]: https://rubyonrails.org/
[webpacker]: https://github.com/rails/webpacker
[vite rails]: https://github.com/ElMassimo/vite_rails
[vite]: https://vitejs.dev/
[vite-templates]: https://github.com/vitejs/vite/tree/main/packages/create-app
[plugins]: https://vitejs.dev/plugins/
[configuration reference]: /config/
[example app]: https://github.com/ElMassimo/vite_rails/tree/main/examples/blog
[heroku]: https://vite-rails-demo.herokuapp.com/

# Getting Started

If you are interested to learn more about Vite Rails before trying it, check out the [Introduction](./introduction).

If you are looking for configuration options, check out the [configuration reference].

::: tip Compatibility Note
[Vite] requires [Node.js](https://nodejs.org/en/) version >= 12.0.0.

[Vite Rails] requires [Rails] version > 5.1.
:::

## Installation 💿

Add this line to your application's Gemfile:

```ruby
gem 'vite_rails'
```

And then run:

    $ bundle install

### Setup 📦

Running

    $ bin/rake vite:install

will:

- Add `vite.config.ts` and `config/vite.json` configuration files
- Install <kbd>vite</kbd> and <kbd>vite-plugin-ruby</kbd> (which is used to configure Vite)
- Create the `app/javascript/entrypoints` directory with an example
- Add the `bin/vite` executable to start the dev server

::: tip Manual Setup
Check the configuration in this [example app](https://github.com/ElMassimo/vite_rails/tree/main/examples/blog) if you would prefer to do it manually.
:::

When working with a framework such as Vue or React, refer to [vite][plugins] to see which [plugins] to add.

If you would like to contribute a framework-specific template, reach out and we might consider it.

### Development Server 💻

Use the `bin/vite` binary installed in the previous section to start a Vite development server.

It will read your `config/vite.json` configuration to set up the `host` and `port`, as well as other options.

### Run your first example 🏃‍♂️

Restart your Rails server, and ensure `bin/vite` is running the Vite development server.

Add the following to your `views/layouts/application.html.erb`:

```erb
<%= vite_client_tag %>
<%= vite_javascript_tag 'application' %>
```

Visit any page and you should see a printed console output: `Vite ⚡️ Rails`.

Check an [example app] running on [Heroku].

## Import Aliases 👉

For convenience, a `~/` import alias is configured to `app/javascript`, allowing
you to use absolute paths:

```js
import App from '~/App.vue'
import '~/channels'
```

## Entrypoints ⤵️

Drawing inspiration from [webpacker], any files in `app/javascript/entrypoints`
will be considered entries to your application (SPAs or pages).

These files will be automatically detected and passed on to Vite, all configuration is done
for you.

You can add them to your HTML layouts or views using the provided tag helpers.

## Tag Helpers 🏷

The following helpers can be used to output tags in your Rails layouts or templates.

- <kbd>vite_javascript_tag</kbd>: Render a `<script>` tag referencing a JavaScript file.
- <kbd>vite_typescript_tag</kbd>: Render a `<script>` tag referencing a TypeScript file.
- <kbd>vite_stylesheet_tag</kbd>: Render a `<link>` tag referencing a CSS file.
- <kbd>vite_client_tag</kbd>: Renders the Vite client to enable Hot Module Reload.

```erb
<head>
  <title>Example</title>
  <%= csrf_meta_tags %>
  <%= csp_meta_tag %>
  <%= vite_client_tag %>

  <%= vite_javascript_tag 'application' %>
  <%= vite_stylesheet_tag 'typography' %>
</head>
```

For other types of assets, you can use `vite_asset_path` and pass the resulting URI to the appropriate tag helper.

### Smart Output ✨

For convenience, `vite_typescript_tag` and `vite_javascript_tag` will automatically inject `<link rel="stylesheet">` and `<link rel="preload">` tags automatically for imported styles or chunks.

When running the development server, these tags are omitted because Vite hasn't compiled them yet, and any dependencies will be loaded through native ESM imports instead.

#### Opting Out ⚙️

For cases where tags need be managed manually, it's possible to opt out by using the options:

- <kbd>skip_preload_tags</kbd>: Set to false to avoid rendering `<link rel="preload">` tags.
- <kbd>skip_style_tags</kbd>: Set to false to avoid rendering `<link rel="stylesheet">` tags.

When rendering styles and preload manually, it's important to avoid rendering when the Vite development server is running, since the files don't exist yet:

```erb
<%= vite_typescript_tag 'application', skip_style_tags: true %>
<%= vite_stylesheet_tag 'application' unless ViteRails.dev_server_running? %>
```
<br>
<hr>
<br>

If you are looking for configuration options, check out the [configuration reference].
