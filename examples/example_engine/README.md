# Vite Ruby ➕ Rails Engine

An example on how to configure a Rails engine to use Vite Ruby.

## Configuration ⚙️

- Add `vite_rails` as a dependency in the engine `gemspec`
- Run `bundle install` and `bundle exec vite install` in the engine directory
- Check that the following files were added and configure them:
  - `config/vite.json`: Use a different `publicOutputDir` and `development.port` than the parent application to avoid conflicts
  - `vite.config.ts`: Should be using `vite-plugin-ruby`

See `engine.rb` and ` application_helper.rb` in this example to add the rest
of the setup.

The `vite_manifest` must be overriden in the engine view helpers.

## Development 💻

In order to enable HMR for assets inside the engine, run `bin/vite` inside the
engine directory, and make sure you are rendering `vite_client_tag` in your
engine views.

Use a different `development.port` to prevent connecting to the same Vite dev
server as the parent app.

## Deployment 🚀

Run `bin/vite build` inside the engine directory to precompile assets.
