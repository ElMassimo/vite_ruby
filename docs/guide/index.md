[discussions]: https://github.com/ElMassimo/vite_rails/discussions
[rails]: https://rubyonrails.org/
[webpacker]: https://github.com/rails/webpacker
[vite rails]: https://github.com/ElMassimo/vite_rails
[vite]: https://vitejs.dev/
[vite-templates]: https://github.com/vitejs/vite/tree/main/packages/create-app
[plugins]: https://vitejs.dev/plugins/
[configuration reference]: /config/
[example app]: https://github.com/ElMassimo/vite_rails/tree/main/examples/blog
[heroku]: https://vite-rails-demo.herokuapp.com/
[dev options]: /config/#development-options
[json config]: /config/#shared-configuration-file-%F0%9F%93%84
[vite config]: /config/#configuring-vite-%E2%9A%A1

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

- Add [`vite.config.ts`][vite config] and [`config/vite.json`][json config] configuration files
- Install <kbd>vite</kbd> and <kbd>vite-plugin-ruby</kbd> (which is used to configure Vite)
- Create the `app/frontend/entrypoints` directory with an example
- Add the <kbd>bin/vite</kbd> executable to start the dev server

::: tip Manual Setup
Check the configuration in this [example app](https://github.com/ElMassimo/vite_rails/tree/main/examples/blog) if you would prefer to do it manually.
:::

When working with a framework such as Vue or React, refer to [vite][plugins] to see which [plugins] to add.

If you would like to contribute a framework-specific template, reach out and we might consider it.

### Running your first example 🏃‍♂️

Use the <kbd>bin/vite</kbd> binary installed in the previous section to start a Vite development server.

Add the following to your `views/layouts/application.html.erb`:

```erb
<%= vite_client_tag %>
<%= vite_javascript_tag 'application' %>
```

Visit any page and you should see a printed console output: `Vite ⚡️ Rails`!

You can now start writing modern JavaScript apps with Vite! 😃

Check an [example app] running on [Heroku].
