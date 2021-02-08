## vite-plugin-ruby 1.0.8 (2020-02-06)

- Split entrypoints into assets/non-assets and add fingerprinting for assets, in order to support 2.0.0-beta.65
- Add `@/` alias to the source dir.

## vite-plugin-ruby 1.0.7 (2020-01-29)

- Fix assets manifest generation after Vite 2.0.0-beta.62 started sending `name: undefined` for svg entrypoints.

## vite-plugin-ruby 1.0.6 (2020-01-29)

- Create a new plugin that generates an assets manifest, since Vite 2.0.0-beta.51 stopped including non-JS entrypoints in the manifest.

## vite-plugin-ruby 1.0.5  (2020-01-24)

- Fix bug in the default for `assetHost` (was `null` instead of `''`).
- Move `base` to the configuration root after Vite 2.0.0-beta.38.

## vite-plugin-ruby 1.0.4  (2020-01-23)

- Receive `assetHost` and use it as the `base` when provided.
