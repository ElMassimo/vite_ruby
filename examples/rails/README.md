<h1 align="center">
  Vite ⚡️ Rails
</h1>

[vite_rails]: https://github.com/ElMassimo/vite_ruby
[heroku]: https://vite-rails-demo.herokuapp.com/
[live demo]: https://vite-rails-demo.herokuapp.com/

This app is an example using [vite_rails] to manage assets with Vite.

A [live demo] is running on [Heroku].

## Installation 💿

If using Docker, run `bin/docker_setup` to build the images and create the db.

Alternatively, you can run:

- <kbd>bundle install</kbd>: Install the ruby gems
- <kbd>yarn install</kbd>: Install the npm packages
- <kbd>bin/rake db:create db:migrate</kbd>: Create the database and tables

## Development 🚀

If using Docker, run `bin/docker` to start the services.

Alternatively, you can run:

- <kbd>bin/rails s</kbd>: Starts the Rails dev server
- <kbd>bin/vite dev</kbd>: Starts the Vite.js dev server
