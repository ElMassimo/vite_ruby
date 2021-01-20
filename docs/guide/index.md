[rails]: https://rubyonrails.org/
[vite rails]: https://github.com/ElMassimo/vite_rails
[vite]: https://vitejs.dev/
[vite-templates]: https://github.com/vitejs/vite/tree/main/packages/create-app
[plugins]: https://vitejs.dev/plugins/

# Getting Started

If you are interested to learn more about Vite Rails before trying it, check out the [Introduction](./introduction) section.

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

- Create `vite.config.ts` and `config/vite.json` configuration files
- Install <kbd>vite</kbd> and <kbd>vite-plugin-ruby</kbd> (which is used to configure Vite)
- Creating the `app/javascript/entrypoints` directory with an example
- Create the `bin/vite` executable to start the dev server

::: tip
Check the configuration in this [example app](https://github.com/ElMassimo/vite_rails/tree/main/examples/blog) if you would prefer to do it manually.
:::

When working with a framework such as Vue or React, refer to [vite][plugins] to see which [plugins] to add.

If you would like to contribute a framework-specific template, reach out and we might consider it.

## Development Server 💻

You can use the `bin/vite` binary installed in the previous section to start a Vite development server.

It will read your `config/vite.json` configuration to set up the `host` and `port`, as well as other options.
