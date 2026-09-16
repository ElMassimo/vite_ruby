<h1 align="center">
  <a href="https://vite-ruby.netlify.app/">
    <img src="https://raw.githubusercontent.com/ElMassimo/vite_ruby/main/logo.svg" width="200px"/>
  </a>

  <br>

  <a href="https://vite-ruby.netlify.app/">
    Vite Ruby
  </a>

  <br>

  <p align="center">
    <a href="https://github.com/ElMassimo/vite_ruby/actions">
      <img alt="Build Status" src="https://github.com/ElMassimo/vite_ruby/workflows/build/badge.svg"/>
    </a>
    <a href="https://codeclimate.com/github/ElMassimo/vite_ruby">
      <img alt="Maintainability" src="https://codeclimate.com/github/ElMassimo/vite_ruby/badges/gpa.svg"/>
    </a>
    <a href="https://codeclimate.com/github/ElMassimo/vite_ruby">
      <img alt="Test Coverage" src="https://codeclimate.com/github/ElMassimo/vite_ruby/badges/coverage.svg"/>
    </a>
    <a href="https://github.com/ElMassimo/vite_ruby/blob/master/LICENSE.txt">
      <img alt="License" src="https://img.shields.io/badge/license-MIT-428F7E.svg"/>
    </a>
  </p>
</h1>

[website]: https://vite-ruby.netlify.app/
[configuration reference]: https://vite-ruby.netlify.app/config/
[features]: https://vite-ruby.netlify.app/guide/introduction.html
[guides]: https://vite-ruby.netlify.app/guide/
[config]: https://vite-ruby.netlify.app/config/
[webpacker]: https://github.com/rails/webpacker
[vite]: https://vite.dev/
[config file]: https://github.com/ElMassimo/vite_ruby/blob/main/vite-plugin-ruby/default.vite.json
[example app]: https://github.com/ElMassimo/pingcrm-vite
[heroku]: https://pingcrm-vite.herokuapp.com/
[Issues]: https://github.com/ElMassimo/vite_ruby/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-desc
[Discussions]: https://github.com/ElMassimo/vite_ruby/discussions
[vite_rails]: https://github.com/ElMassimo/vite_ruby/tree/main/vite_rails
[vite_ruby]: https://github.com/ElMassimo/vite_ruby/tree/main/vite_ruby
[vite_hanami]: https://github.com/ElMassimo/vite_ruby/tree/main/vite_hanami
[no bundling]: https://vite.dev/guide/why.html#the-problems
[bundling]: https://vite.dev/guide/why.html#slow-updates

[Vite] is to frontend tooling as Ruby to programming, pure joy! 😍

This repo contains libraries that will allow you to easily integrate Vite in
your favourite Ruby framework, such as [Rails][vite_rails] or [Hanami][vite_hanami].

## Why Vite? 🤔

Vite [does not bundle your code during development][no bundling], which means the
dev server is extremely __fast to start__, and your changes will be __updated instantly__.

In production, Vite [bundles your code][bundling]
with tree-shaking, lazy-loading, and common chunk splitting out of the box, to achieve optimal loading performance.

It also provides great defaults, and is easier to configure than similar tools like webpack.

## Features ⚡️

- 💡 Instant server start
- ⚡️ Blazing fast hot reload
- 🚀 Zero-config deployments
- 🤝 Integrated with <kbd>assets:precompile</kbd>
- [And more!][features]

## Documentation 📖

Visit the [documentation website][website] to check out the [guides] and searchable [configuration reference].

## Installation 💿

Add this line to your application's Gemfile:

```ruby
gem 'vite_rails' # vite_hanami for Hanami apps, vite_ruby for Rack apps
```

Then, run:

```bash
bundle install
bundle exec vite install
```

This will generate configuration files and a sample setup.

Additional installation instructions are available in the [documentation website][website].

## Getting Started 💻

Restart your web server, and then run <kbd>bin/vite dev</kbd> to start the Vite development server.

Visit any page and you should see a printed console output: `Vite ⚡️ Ruby`.

For more [guides] and a full [configuration reference], check the [documentation website][website].

## Contact ✉️

Please use [Issues] to report bugs you find, and [Discussions] to make feature requests or get help.

Don't hesitate to _⭐️ star the project_ if you find it useful!

Using it in production? Always love to hear about it! 😃

## Special Thanks 🙏

- [webpacker]
- [vite]

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
