[Vite Ruby]: https://github.com/ElMassimo/vite_ruby
[vite.js]: https://github.com/vitejs/vite
[Troubleshooting]: /guide/troubleshooting
[puts debugging]: https://tenderlovemaking.com/2016/02/05/i-am-a-puts-debuggerer.html
[debug]: https://github.com/visionmedia/debug
[commands]: /guide/development.html#cli-commands-⌨%EF%B8%8F
[vite-plugin-ruby]: https://github.com/ElMassimo/vite_ruby/tree/main/vite-plugin-ruby
[nim]: https://chrome.google.com/webstore/detail/nodejs-v8-inspector-manag/gnhhdgbaldcilmgcpfddgdbkhjohddkj
[debugging session]: https://nodejs.org/en/docs/guides/debugging-getting-started/#command-line-options
[local version]: /guide/debugging.html#using-a-local-library-🔗
[local paths]: https://ryanbigg.com/2013/08/bundler-local-paths
[yarn link]: https://classic.yarnpkg.com/en/docs/cli/link
[npm link]: https://docs.npmjs.com/cli/v7/commands/npm-link
[pry-byebug]: https://github.com/deivid-rodriguez/pry-byebug
[byebug]: https://github.com/deivid-rodriguez/byebug
[this blog post]: https://maximomussini.com/posts/debugging-javascript-libraries/

# Debugging 🔎

This section contains some useful tips for debugging [Vite.js] and [Vite Ruby].

::: tip Before we start
Debugging can be time-consuming, please check the __[Troubleshooting]__ section first.
:::

<small>If you are using the vite JS executable directly, please refer to [this blog post] instead.</small>

## Getting more output from Vite 📜

The quickest way to get started is to enable more output from Vite's core plugins.

You can achieve that by passing the `--debug` flag to the [commands].

![debug](/debugging/debug.svg)

### Tweaking debug output 

To see output from other plugins, you can set the <kbd>[DEBUG]</kbd> environment variable.

You can use globs to filter specific commands:

- <kbd>DEBUG=*</kbd>: Enable all debug output
- <kbd>DEBUG=vite:\*</kbd>: Enable output from core plugins
- <kbd>DEBUG=vite-plugin-ruby:*</kbd>: Enable output from <kbd>[vite-plugin-ruby]</kbd>

![debug with env](/debugging/debug-env.svg)

## Debugging with DevTools 🎯

[Commands] in [Vite Ruby] can also receive the `--inspect` flag to start a [debugging session].

You may use the [Node Inspector Manager][nim] browser extension to attach automatically to the session.

![debug with --inspect](/debugging/nim.svg)

Set breakpoints in Dev Tools, or use the `debugger` keyword in the code to break execution.

## Opening Packages and Gems 📖

Run <kbd>bundle open</kbd> or <kbd>npm edit</kbd> to open the version of the libraries used in your project.

::: tip Set $EDITOR
This environment variable will be used to infer the text editor to open the library with.

I like using Sublime Text or Visual Studio Code, to see the entire file tree.
:::

Examples: <kbd>bundle open vite_ruby</kbd>, <kbd>npm edit vite</kbd>.

### Editing In-Place ✍️

Because both Ruby and JavaScript are dynamic languages, you can tweak the code __in-place__, and then __restart the dev servers__, and your changes will be picked up.

You can add <kbd>puts</kbd> or <kbd>console.log</kbd> as needed, or even change the behavior!

In TypeScript packages (and some JS packages), make sure to edit the transpiled file instead of the sources. This is often `dist/index.js` but that depends on the library and target environment.

::: warning Disclaimer
This has many caveats: bugs that only happen in your local, or the opposite, code that only seems to work in your local. __*[Keep reading for a better approach][local version]*__. You have been warned!

_(I use it all the time though, so convenient 😅)_
:::

## Using a Local Library 🔗

When fixing a bug, a nice flow is to __clone__ the library, and then _point to your local copy_.

- In Ruby, you can use [local paths] for Git dependencies, or use `path`:

  ```ruby
  gem 'vite_ruby', path: '../vite_ruby' # Assuming the same parent directory
  ```

- In JavaScript, you can use <kbd>[yarn link]</kbd> or <kbd>[npm link]</kbd>:

  For example, for `vite`, inside your clone:

  ```bash
  cd packages/vite # Location of the package.json for the library
  yarn link
  ```

  In the project you are debugging:

  ```bash
  yarn link vite # Name of the library
  ```

  If using `pnpm`, then you can safely use `file` which will link to your local copy:

  ```json
  "devDependencies": {
    "vite": "file:../vite/packages/vite",
  ```

- In TypeScript or compiled JS libraries, make sure to start a compiler with a watcher.

  By convention, the `dev` script is used for this purpose: <kbd>npm run dev</kbd>.

  This will detect changes in the library, and recompile as needed.

Just as in the previous section, it's important to __restart the dev servers__ after changes.

::: tip Why is it necessary to restart? 🤔

Most processes will load the required libraries into memory, and then use these cached versions during their entire running time.

Restarting your Ruby and Vite processes ensures the modified versions are loaded.
:::

## Debugging Gems <img class="logo" src="/logo.svg" alt="Logo"/>

Sometimes [puts debugging] in Ruby is not enough, and you need to use an actual debugger.

You can use <kbd>[byebug]</kbd> (or <kbd>[pry-byebug]</kbd>) to break execution and start an interactive session.

![debug with binding.pry](/debugging/pry.svg)

Use `tap` to inject breakpoints without affecting the outcome:

```ruby
.tap { |val| binding.pry }
```
