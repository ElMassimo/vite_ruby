[discussions]: https://github.com/ElMassimo/vite_ruby/discussions
[rails]: https://rubyonrails.org/
[webpacker]: https://github.com/rails/webpacker
[vite rails]: https://github.com/ElMassimo/vite_ruby
[vite]: https://vitejs.dev/
[vite-plugin-ruby]: https://github.com/ElMassimo/vite_ruby/tree/main/vite-plugin-ruby
[vite_rails_legacy]: https://github.com/ElMassimo/vite_ruby/tree/main/vite_rails_legacy
[vite_hanami]: https://github.com/ElMassimo/vite_ruby/tree/main/vite_hanami
[vite_padrino]: https://github.com/ElMassimo/vite_ruby/tree/main/vite_padrino
[vite_ruby]: https://github.com/ElMassimo/vite_ruby/tree/main/vite_ruby
[commands]: /guide/development.html#cli-commands-⌨%EF%B8%8F
[vite-templates]: https://github.com/vitejs/vite/tree/main/packages/create-app
[plugins]: https://vitejs.dev/plugins/
[configuration reference]: /config/
[simple app]: https://github.com/ElMassimo/vite_ruby/tree/main/examples/rails
[example app]: https://github.com/ElMassimo/pingcrm-vite
[heroku]: https://pingcrm-vite.herokuapp.com/
[dev options]: /config/#development-options
[json config]: /config/#shared-configuration-file-%F0%9F%93%84
[vite config]: /config/#configuring-vite-%E2%9A%A1
[GitHub Issues]: https://github.com/ElMassimo/vite_ruby/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-desc
[GitHub Discussions]: https://github.com/ElMassimo/vite_ruby/discussions
[Troubleshooting]: /guide/troubleshooting
[Recommended Plugins]: /guide/plugins
[jekyll-vite]: https://github.com/ElMassimo/jekyll-vite
[tag helpers]: https://vite-ruby.netlify.app/guide/development.html#tag-helpers-%F0%9F%8F%B7

# Getting Started

If you are interested to learn more about Vite Ruby before trying it, check out the [Introduction](./introduction).

If you are looking for configuration options, check out the [configuration reference].

## Installation 💿

Add this line to your application's Gemfile:

```ruby
gem 'vite_rails'
```

And then run:

```
bundle install
```

- If using Jekyll, install the <kbd>[jekyll-vite]</kbd> gem instead.

- If using Hanami, install the <kbd>[vite_hanami]</kbd> gem instead.

- If using Padrino, install the <kbd>[vite_padrino]</kbd> gem instead.

- If using other Ruby web frameworks, install the <kbd>[vite_ruby]</kbd> gem.

- If using Rails 4, install the <kbd>[vite_rails_legacy]</kbd> gem.

### Setup 📦

Run <kbd>bundle exec vite install</kbd>, which:


- Adds the <kbd>bin/vite</kbd> executable to start the dev server and run other [commands]

- Installs <kbd>[vite]</kbd> and <kbd>[vite-plugin-ruby]</kbd>

- Adds [`vite.config.ts`][vite config] and [`config/vite.json`][json config] configuration files

- Creates a sample `application.js` entrypoint in your web app

- Injects [tag helpers] in the default `application.html.erb` view layout

:::tip Tag Helpers
If you are using a different layout file, follow the _[Tag Helpers]_ section to add them manually.
:::

### Running your first example 🏃‍♂️

Run <kbd>bin/vite dev</kbd> to start the Vite development server.

Restart your Rails or Rack web server before visiting any page, and you should see a printed console output:

```
Vite ⚡️ Ruby
```

You can now start writing modern JavaScript apps with Vite! 😃

Check an [example app] running on [Heroku].

::: tip Not seeing anything?
Check the _[Troubleshooting]_ section for common problems.
:::

### Further Configuration 🧩

Check the _[Recommended Plugins]_ section for more information about [plugins] and useful libraries.

::: tip Official Vite.js Plugins

When using Vue, React, or Svelte, check out [Vite][plugins]'s __[official plugins][plugins]__.
:::

### Contact ✉️

Please visit [GitHub Issues] to report bugs you find, and [GitHub Discussions] to make feature requests, or to get help.

Don't hesitate to [⭐️ star the project][vite rails] if you find it useful!

Using it in production? Always love to hear about it! 😃
