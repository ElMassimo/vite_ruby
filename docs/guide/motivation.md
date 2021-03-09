[project]: https://github.com/ElMassimo/vite_ruby
[GitHub Issues]: https://github.com/ElMassimo/vite_ruby/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-desc
[GitHub Discussions]: https://github.com/ElMassimo/vite_ruby/discussions
[rails]: https://rubyonrails.org/
[webpack]: https://webpack.js.org/
[webpacker]: https://github.com/rails/webpacker
[vite.js]: https://vitejs.dev/
[adds several hard dependencies]: https://github.com/rails/webpacker/commit/da362b8c96a4be5a4af8f8ad886f5dd8451f457f?short_path=7ae45ad#L15-L35
[webpack-chain]: https://github.com/neutrinojs/webpack-chain
[vue-cli]: https://cli.vuejs.org/
[architecture]: https://www.youtube.com/watch?v=xXrhg26VCSc
[features]: /guide/introduction.html#features-⚡%EF%B8%8F
[config]: /config/
[development]: /guide/development

# Motivation

In this section I would like to outline my personal motivation for starting this project.

## Webpack and increasing load times

I've used [webpack] and [webpacker] extensively in the past few years.

If you have worked on a large frontend application, you have probably experienced increasingly long startup times for [webpack] as the amount of code and dependencies grew.

It gets worse when HMR or incremental compilation starts to slide from under one second, to one, two, three seconds, or more!

## Webpack and configuration complexity

[Webpack] is a powerful tool, but it can be daunting to configure and requires a lot of time to understand it well.

[Webpacker] provides integration with Rails, but [adds several hard dependencies] which make upgrading dependencies painful. Because it does not use [webpack-chain], opting out of the default loaders is difficult, and integration with tools like [vue-cli] requires full understanding of the underlying implementation.

My initial goal was actually to release a [webpacker] and [vue-cli] integration, but that was soon going to change.

## Vite.js: no bundling in development

When I first heard about [Vite.js] I was excited about its [architecture], which leverages native ESM in modern browsers to only process files on demand.

Its design foundation has major implications: as your application grows, startup time doesn't keep crawling up.

When changing the source code, only the modified code needs to be re-processed. HMR takes milliseconds instead of seconds!

## Vite: less dependencies, friendly for beginners, easy to hack

Vite's [documentation][vite.js] is excellent, and the fact that it's a TypeScript codebase makes it easy to navigate its internals when writing a plugin.

I decided to write a prototype to provide a similar [level of integration][features] with Rails as [webpacker] did for [webpack]. It worked!

It was then when I chose to refine it, document it, and release it. The end result is [Vite Ruby][project].

## Vite Ruby

The design decisions in [Vite Ruby][project] share a common thread with the design of [Vite.js].

I wanted to achieve a nice experience out of the box by providing [strong conventions][development], while at the same time [allowing][config] the user to opt-out or [tweak as needed][config].

I hope that you find this project as useful as it has been for me 😃

## Contact ✉️

Please visit [GitHub Issues] to report bugs you find, and [GitHub Discussions] to make feature requests, or to get help.

Don't hesitate to [⭐️ star the project][project] if you find it useful!

Using it in production? Always love to hear about it! 😃
