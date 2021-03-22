[project]: https://github.com/ElMassimo/vite_ruby
[GitHub Issues]: https://github.com/ElMassimo/vite_ruby/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-desc
[GitHub Discussions]: https://github.com/ElMassimo/vite_ruby/discussions
[sourceCodeDir]: /config/#sourcecodedir
[watchAdditionalPaths]: /config/#watchadditionalpaths
[devServerConnectTimeout]: /config/#devserverconnecttimeout
[host]: /config/#host
[port]: /config/#port
[vite]: https://vitejs.dev/
[vite-plugin-ruby]: https://github.com/ElMassimo/vite_ruby/tree/main/vite-plugin-ruby
[viteBinPath]: /config/#vitebinpath
[docker example]: https://github.com/ElMassimo/vite_rails_docker_example
[Using Heroku]: /guide/deployment#using-heroku
[example app]: https://github.com/ElMassimo/vite_ruby/tree/main/examples/rails/vite.config.ts
[windi]: /guide/plugins.html#windi-css

# Troubleshooting

This section lists a few common gotchas, and bugs introduced in the past.

Please skim through __before__ opening an [issue][GitHub Issues].

### Missing executable error

Verify that both <kbd>[vite]</kbd> and <kbd>[vite-plugin-ruby]</kbd> are in `devDependencies` in your `package.json` and have been installed by running <kbd>bin/vite info</kbd>.

If you are using a non-standard setup, try configuring <kbd>[viteBinPath]</kbd>.

### Making HMR work in Docker Compose

Using Vite.js with Docker Compose requires configuring [`VITE_RUBY_HOST`][host] in the services.

In the Rails service, it should match the [name of your Vite service](https://github.com/ElMassimo/vite_rails_docker_example/blob/main/docker-compose.yml#L13), and in the Vite service it should be [set to receive external requests](https://github.com/ElMassimo/vite_rails_docker_example/blob/main/docker-compose.yml#L27) (from the browser in the host) in order to perform HMR.

Refer to this [Docker example] for a working setup.

### Build not working in CI or Heroku

Make sure `devDependencies` are installed when precompiling assets in a CI.

Refer to the _[Using Heroku]_ section.

### Build is triggered when the dev server is running

First, verify that the dev server is reachable by starting a new console session and running:

```ruby
> ViteRuby.instance.dev_server_running?
```

If it returns `false`, try increasing the <kbd>[devServerConnectTimeout]</kbd>, restart the console and retry.
In systems with constrained resources the [default timeout][devServerConnectTimeout] might not be enough.

If that doesn't work, verify that the [host] and [port] configuration is correct.

### Requests to vite sporadically return a 404

[See above](/guide/troubleshooting.html#build-is-triggered-when-the-dev-server-is-running), it could be related to the <kbd>[devServerConnectTimeout]</kbd>.

### Changes are not taken into account, build is skipped

Usually happens when importing code outside the <kbd>[sourceCodeDir]</kbd>.

Add a file path or dir glob in <kbd>[watchAdditionalPaths]</kbd> to ensure changes to those files trigger a new build.

### `vite` and `vite-plugin-ruby` were not installed

If you have run <kbd>bundle exec vite install</kbd>, check the output for errors.

A bug prior to [`vite_ruby@1.0.14`](https://github.com/ElMassimo/vite_ruby/pull/23) caused these packages not be added during installation.

### Images only load if placed on `entrypoints`

This is a bug affecting how static files are served, introduced in [`vite@2.0.4`](https://github.com/vitejs/vite/pull/2201). 

Make sure you are using [`vite@2.0.5`](https://github.com/vitejs/vite/pull/2309) or higher.

### Tailwind CSS is slow to load

A project called [Windi CSS](https://github.com/windicss/windicss) addresses this pain point − I've created a [documentation website](http://windicss.netlify.app/).

A [plugin for Vite.js](https://github.com/windicss/vite-plugin-windicss) is available, and should allow you to get [insanely faster](https://twitter.com/antfu7/status/1361398324587163648) load times in comparison.

Check the [_Recommended Plugins_][windi] section for more information.

### Windi CSS does not detect changes to server templates

Ensure you're using `vite-plugin-windicss@0.9.5` or higher.

Check the [_Recommended Plugins_][windi] section for more information.

### esbuild: cannot execute binary file

This can happen when using mounted volumes in Docker, and attempting to run Vite from the host.

Since `esbuild` relies on a `postinstall` script, and the architecture of the host usually does not match the architecture of the image, this means the binaries are not compatible.

Try reinstalling `esbuild` in the host.

## Contact ✉️

Please visit [GitHub Issues] to report bugs you find, and [GitHub Discussions] to make feature requests, or to get help.

Don't hesitate to [⭐️ star the project][project] if you find it useful!

Using it in production? Always love to hear about it! 😃
