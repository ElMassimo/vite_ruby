## [2.0.3](https://github.com/ElMassimo/vite_ruby/compare/vite_rails@2.0.2...vite_rails@2.0.3) (2021-03-07)

- Add a bounded requirement to `vite_ruby` dependency.

## Vite Rails 2.0.2  (2020-02-11)

- Automatically infer `app/javascript` as the `sourceCodeDir` if it exists.

## Vite Rails 2.0.1  (2020-02-11)

- Add the CSP rules commented out when installing, in case the user hasn't uncommented them yet.

## Vite Rails 2.0.0  (2020-02-10)

- Extracted core functionality to `vite_ruby`.
- User-facing API hasn't really changed, but internal classes have been renamed.
- Installation script now injects tags to `application.html.erb` if it exists.

## Vite Rails 1.0.12  (2020-01-29)

- Add support for Vite 2.0.0-beta.56, which modified the manifest to output a `css` field in the manifest.
- Start generating an assets manifest, since 2.0.0-beta.51 stopped including non-JS entrypoints in the manifest.

## Vite Rails 1.0.11  (2020-01-24)

- Fix bug in `assetHost` that caused `base` to be configured incorrectly.
- Allow installing `vite` and `vite-plugin-ruby` as devDependencies, and install them when precompiling assets.
- Move `base` to the configuration root after Vite's update in beta.38

## Vite Rails 1.0.10  (2020-01-23)

- Use `path_to_asset` in `vite_asset_path` so that it's prefixed automatically
  when using a CDN (`config.action_controller.asset_host`).

## Vite Rails 1.0.9  (2020-01-22)

- Ensure `configPath` and `publicDir` are scoped from `root`, both in Ruby and JS.

## Vite Rails 1.0.8  (2020-01-21)

- Change the default of `sourceCodeDir` to `app/frontend`, add instructions for folks migrating
from a `app/javascript` structure.

## Vite Rails 1.0.7  (2020-01-20)

- Add `vite_client_tag` to ensure the Vite client can be loaded in apps that don't use any imports.

## Vite Rails 1.0.6  (2020-01-20)

- Ensure running `bin/rake assets:precompile` automatically invokes `vite:build`.

## Vite Rails 1.0.5  (2020-01-20)

- Automatically add `<link rel="modulepreload">` and `<link rel="stylesheet">` when using `vite_javascript_tag`, which simplifies usage.

## Vite Rails 1.0.4  (2020-01-19)

- Remove Vue specific examples from installation templates, to ensure they always run.

## Vite Rails 1.0.0 (2020-01-18)

Initial Version
