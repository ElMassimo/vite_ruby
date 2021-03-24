[installation]: /guide/#installation-💿
[config reference]: https://vitejs.dev/config/
[plugins]: https://vitejs.dev/plugins/
[entrypoints]: /guide/development.html#entrypoints-⤵%EF%B8%8F
[json config]: /config/#shared-configuration-file-%F0%9F%93%84
[sourceCodeDir]: /config/#sourcecodedir
[autoBuild]: /config/#autobuild
[publicOutputDir]: /config/#publicoutputdir
[watchAdditionalPaths]: /config/#watchadditionalpaths
[publicDir]: /config/#publicdir
[root]: /config/#root
[alignment with Rails defaults]: https://github.com/rails/webpacker/issues/769
[source maps]: https://vitejs.dev/config/#build-sourcemap

# Configuring Vite Ruby

The following section is an overview of basic configuration for _Vite Ruby_.

Most of the options discussed are specific to _Vite Ruby_, for the rest of the
available configuration options please check Vite's [config reference].

## Configuring Vite ⚡

When running <kbd>bin/vite</kbd> from the command line, Vite will use your `vite.config.ts`.

If you followed the [installation] section, it should look similar to:

```js
// vite.config.ts
import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'

export default defineConfig({
  plugins: [
    RubyPlugin(),
  ],
})
```

You can customize this file as needed, check Vite's [plugins] and [config reference] for more info.

## Shared Configuration File 📄

_Vite Ruby_ leverages a simple `config/vite.json` configuration file, which is
read both from Ruby and JavaScript, and allows you to easily configure options
such as the host and port of the Vite development server.

If you followed the [installation] section, it should look similar to:

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

The `all` section is applied to all environments, including production. You can override specific options in an environment-specific group.

The following options can all be specified in your `config/vite.json` file, or
overriden with environment variables.

## Source Maps 🗺

The only notable difference with Vite.js config defaults, is that [source maps]
are enabled in production to be in [alignment with Rails defaults].

You may skip source map generation by explicitly configuring <kbd>[sourcemap][source maps]</kbd>:

```js
// vite.config.ts
export default defineConfig({
  build: { sourcemap: false },
```


## Development Options

### autoBuild

- **Default:** `false`
- **Env Var:** `VITE_RUBY_AUTO_BUILD`

  By default, the generated config enables it for the <kbd>test</kbd> and <kbd>development</kbd> environments.

  When enabled, Vite Ruby will automatically track changes to <kbd>[sourceCodeDir]</kbd>,
  and trigger a Vite build on demand if files have changed.

  This is very convenient when running integration tests, or when a developer
  does not want to start the Vite development server (although it's highly recommended).

### host

- **Default:** `"localhost"`
- **Env Var:** `VITE_RUBY_HOST`

  Specify the hostname for the Vite development server.

### port

- **Default:** `3036`
- **Env Var:** `VITE_RUBY_PORT`

  Specify the port for the Vite development server.

### https

- **Type:** `boolean`
- **Env Var:** `VITE_RUBY_HTTPS`

  Enable TLS + HTTP/2 for the Vite development server.

## Build Options

The default configuration expects your code to be in `app/frontend`, and your
entrypoint files to be in the `app/frontend/entrypoints` directory.

The compiled assets will be outputed to the `public/vite/assets` directory.

You can customize this behavior using the following options.

### buildCacheDir

- **Default:** `tmp/cache/vite`
- **Env Var:** `VITE_RUBY_BUILD_CACHE_DIR`

  Specify the directory where the <kbd>[autoBuild]</kbd> cache should be stored, used to
  detect if a build is needed when the development server is not running.

### publicDir

- **Default:** `public`
- **Env Var:** `VITE_RUBY_PUBLIC_DIR`

  Specify the public directory (relative to <kbd>[root]</kbd>).

  It's expected for this directory to be served by Apache/NGINX, or loaded into a CDN.

  Check Rails `public_file_server.enabled` for more information.

### publicOutputDir

- **Default:** `vite`
- **Env Var:** `VITE_RUBY_PUBLIC_OUTPUT_DIR`

  Specify the output directory (relative to <kbd>[publicDir]</kbd>).

### assetsDir

- **Default:** `assets`
- **Env Var:** `VITE_RUBY_ASSETS_DIR`

  Specify the directory to nest generated assets under (relative to <kbd>[publicOutputDir]</kbd>).

### sourceCodeDir

- **Default:** `app/frontend`
- **Env Var:** `VITE_RUBY_SOURCE_CODE_DIR`

  Specify the directory where your source code will be located (relative to <kbd>[root]</kbd>).

  Vite Ruby will alias this directory as `~/` and `@/`, allowing you to make absolute imports which are more convenient.

  It be watched for changes when using <kbd>[autoBuild]</kbd>, you can add aditional paths
  to keep track of using <kbd>[watchAdditionalPaths]</kbd>.

### entrypointsDir

- **Default:** `entrypoints`
- **Env Var:** `VITE_RUBY_ENTRYPOINTS_DIR`

  Specify the directory where the [entrypoints] will be located (relative to <kbd>[sourceCodeDir]</kbd>).

## Other Options

### assetHost

- **Default:** `Rails.application.config.action_controller.asset_host`
- **Env Var:** `VITE_RUBY_ASSET_HOST`

  Specify the asset host when using a CDN. Usually there's no need to explicitly configure it.

### configPath

- **Default:** `config/vite.json`
- **Env Var:** `VITE_RUBY_CONFIG_PATH`

  Specify where the [JSON config] file is located (relative to <kbd>[root]</kbd>).

  Not supported in the JSON file.

### devServerConnectTimeout

- **Default:** `0.01` (seconds)

  Timeout when attempting to connect to the dev server (in seconds).

  You can increase this timeout if the fallback compilation is being triggered
  even though the dev server is running.

### hideBuildConsoleOutput

- **Default:** `false`
- **Env Var:** `VITE_RUBY_HIDE_BUILD_CONSOLE_OUTPUT`

  Allows to skip Vite build output from logs, to keep the noise down.

### root

- **Default:** `Rails.root`
- **Env Var:** `VITE_RUBY_ROOT`

  Specify the project root.

### viteBinPath

- **Default:** `node_modules/.bin/vite`
- **Env Var:** `VITE_RUBY_VITE_BIN_PATH`

  The path where the Vite.js binary is installed. It will be used to execute the `dev` and `build` commands.

### watchAdditionalPaths

- **Default:** `[]`

  Specify which other paths should be tracked for changes when using <kbd>[autoBuild]</kbd>.

  You may provide globs such as `["app/components/**/*"]`, paths should be relative to <kbd>[root]</kbd>.

  The <kbd>[sourceCodeDir]</kbd> is included by default.

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
