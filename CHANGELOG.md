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
