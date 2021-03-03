[project]: https://github.com/ElMassimo/vite_ruby
[GitHub Issues]: https://github.com/ElMassimo/vite_ruby/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-desc
[GitHub Discussions]: https://github.com/ElMassimo/vite_ruby/discussions
[sourceCodeDir]: /config/#sourcecodedir
[watchAdditionalPaths]: /config/#watchadditionalpaths
[devServerConnectTimeout]: /config/#devserverconnecttimeout
[host]: /config/#host
[port]: /config/#port

# Troubleshooting

This section lists a few common gotchas, and bugs introduced in the past.

Please skim through __before__ opening an [issue][GitHub Issues]. 

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

### Changes are not taken into account when building

Usually happens when importing code outside the <kbd>[sourceCodeDir]</kbd>.

Add a file path or dir glob in <kbd>[watchAdditionalPaths]</kbd> to ensure changes to those files trigger a new build.

### `bin/vite dev` does not start the server

Make sure you are using [`vite_ruby@1.0.14`](https://github.com/ElMassimo/vite_ruby/pull/23) or higher.

### `vite` and `vite-plugin-ruby` were not installed

Make sure you are using [`vite_ruby@1.0.14`](https://github.com/ElMassimo/vite_ruby/pull/23) or higher.

### Images only load if placed on `entrypoints`

This is a bug affecting how static files are served, introduced in [`vite@2.0.4`](https://github.com/vitejs/vite/pull/2201). 

Make sure you are using [`vite@2.0.5`](https://github.com/vitejs/vite/pull/2309) or higher.

### Tailwind CSS is slow to load

A project called [Windi CSS](https://github.com/windicss/windicss) addresses this pain point − I've created a [documentation website](http://windicss.netlify.app/).

A [plugin for Vite.js](https://github.com/windicss/vite-plugin-windicss) is available, and should allow you to get [insanely faster](https://twitter.com/antfu7/status/1361398324587163648) load times in comparison.

The creator of Tailwind CSS was impressed by the performance achieved by Windi CSS, and is currently implementing [something similar](https://twitter.com/adamwathan/status/1363638620209446921).

## Contact ✉️

Please visit [GitHub Issues] to report bugs you find, and [GitHub Discussions] to make feature requests, or to get help.

Don't hesitate to [⭐️ star the project][project] if you find it useful!
