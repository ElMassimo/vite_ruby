<h1 align="center">
  Vite ⚡️ Rails
  <p align="center">
<!--     <a href="https://github.com/ElMassimo/vite_rails/actions">
      <img alt="Build Status" src="https://github.com/ElMassimo/vite_rails/workflows/build/badge.svg"/>
    </a> -->
    <!-- <a href="https://codeclimate.com/github/ElMassimo/vite_rails">
      <img alt="Maintainability" src="https://codeclimate.com/github/ElMassimo/vite_rails/badges/gpa.svg"/>
    </a>
    <a href="https://codeclimate.com/github/ElMassimo/vite_rails">
      <img alt="Test Coverage" src="https://codeclimate.com/github/ElMassimo/vite_rails/badges/coverage.svg"/>
    </a> -->
    <a href="https://rubygems.org/gems/vite_rails">
      <img alt="Gem Version" src="https://img.shields.io/gem/v/vite_rails.svg?colorB=e9573f"/>
    </a>
    <a href="https://github.com/ElMassimo/vite_rails/blob/master/LICENSE.txt">
      <img alt="License" src="https://img.shields.io/badge/license-MIT-428F7E.svg"/>
    </a>
  </p>
</h1>

[vite_rails]: https://github.com/ElMassimo/vite_rails
[webpacker]: https://github.com/rails/webpacker
[vite]: http://vitejs.dev/
[config file]: https://github.com/ElMassimo/vite_rails/blob/main/package/default.vite.json

[__Vite Rails__][vite_rails] allows you to use [Vite] to power the frontend.

[Vite] is to frontend tooling as Ruby to programming, pure joy! 😍

## Features ⚡️

- 🤖 Automatic Entrypoint Detection
- ⚡️ Hot Reload
- ⚙️ Rake Tasks
- 🪝 Hooks to <kbd>assets:precompile</kbd> and friends
- And more! (detects changes, and builds automatically if Vite is not running)

## Documentation 📖

A documentation website is coming soon!

## Installation 💿

Add this line to your application's Gemfile:

```ruby
gem 'vite_rails'
```

Then, run:

```bash
bundle install
bin/rake vite:install
```

This will generate configuration files and a sample setup.

## Usage 🚀

Drawing inspiration from [webpacker], any files in `app/javascript/entrypoints`
will be considered entries to your application (SPAs or pages).

These files will be detected, and passed on to Vite, all configuration is done
for you.

### Imports ⤵️

For convenience, a `~/` import alias is configured to `app/javascript`, allowing
you to use absolute paths:

```js
import { createApp } from 'vue'
import App from '~/App.vue'
import '~/channels'

createApp(App).mount('#app')
```

### Tags 🏷

`vite_typescript_tag`, `vite_javascript_tag`, and `vite_stylesheet_tag` can be
used to output `<script>` and `<link>` tags in your Rails layouts or templates.

```html
<head>
  <title>Joie</title>
  <%= csrf_meta_tags %>
  <%= csp_meta_tag %>

  <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
  <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>

  <%= vite_stylesheet_tag 'strange' %>
  <%= vite_typescript_tag 'application' %>
</head>
```

For other types of assets, you can use `vite_asset_path` and pass that to the appropriate tag helper.

## Configuration ⚙️

This is what your `config/vite.json` might look like:

```json
{
  "all": {
    "watchAdditionalPaths": []
  },
  "development": {
    "autoBuild": true,
    "publicOutputDir": "vite-dev",
    "port": 3036
  },
  "test": {
    "autoBuild": true,
    "publicOutputDir": "vite-test"
  }
}
```

Check [this file][config file] to see all config options, documentation is coming soon.

## Inspiration 💡

- [webpacker]

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
