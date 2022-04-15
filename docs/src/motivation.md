[project]: /
[github]: https://github.com/ElMassimo/vite_ruby
[GitHub Issues]: https://github.com/ElMassimo/vite_ruby/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-desc
[GitHub Discussions]: https://github.com/ElMassimo/vite_ruby/discussions
[rails]: https://rubyonrails.org/
[webpack]: https://webpack.js.org/
[webpacker]: https://github.com/rails/webpacker
[vite.js]: https://vitejs.dev/
[adds several hard dependencies]: https://github.com/rails/webpacker/blob/da362b8c96a4be5a4af8f8ad886f5dd8451f457f/package.json#L15-L35
[webpack-chain]: https://github.com/neutrinojs/webpack-chain
[vue-cli]: https://cli.vuejs.org/
[architecture]: https://www.youtube.com/watch?v=xXrhg26VCSc
[features]: /guide/introduction.html#features-⚡%EF%B8%8F
[config]: /config/
[development]: /guide/development
[balance]: https://www.youtube.com/watch?v=ANtSWq-zI0s
[me]: https://maximomussini.com
[connection]: https://vimeo.com/38272912
[changes the game]: https://twitter.com/patak_js/status/1361383298052878342
[Nick Cherry]: https://blog.coinbase.com/optimizing-react-native-7e7bf7ac3a34
[overview]: /overview

# Motivation

In this section I outline my personal motivation for starting this project.

## Webpack—configuration complexity

I've used [webpack] and [webpacker] extensively in the past few years. Both are good libraries, with their merits and caveats.

[Webpack] is powerful, but it can be daunting to configure and it takes time to understand it well. Raise your hand if you have seen a [webpack] config that made you cringe.

[Webpacker] provides integration with Rails, but [adds several hard dependencies] which can make upgrades a painful experience.

Additionally, since it does not use [webpack-chain], opting out of the default loaders is difficult, and integration with tools like [vue-cli] requires full understanding of the underlying implementation.

My original goal was to release a [webpacker] and [vue-cli] integration so that everyone could benefit, but that was soon going to change.

## Webpack—increasing load times

If you have worked on a large frontend application, you have probably experienced increasingly long startup times for [webpack] as the amount of code and dependencies grew.

It gets worse when HMR or incremental compilation starts to slide from under one second, to one, two, three seconds, or more! _Should I refresh the page?_

<Quote v-once author="Bret Victor, Inventing on Principle" href="https://vimeo.com/38272912">Creators need an <em><b>immediate</b></em> connection to what they're creating.</Quote>

## Vite—no bundling in development

When I first heard about [Vite.js] I became excited about its __[architecture]__, which leverages native ESM in modern browsers to process files on demand.

This design decision has major implications: as your application grows, startup time _does not keep crawling up_.
Incremental builds are extremely fast, since _processing happens on demand_.

A friend said that it _[changes the game]_, and I couldn't agree more.

[Vite.js] brought me closer to having [_an immediate connection with my creations_][connection].

## Less dependencies, friendly for beginners, easy to hack

Vite's [documentation][vite.js] is excellent, and its internals are easy to navigate since the codebase is written in TypeScript, which is really convenient when writing a plugin.

I decided to write a prototype in Rails that had a similar [level of integration][features] as [webpacker] provided for [webpack]. __It worked!__

Then, I chose to refine it, [document it][project], and [release it][github]. The end result is [Vite Ruby][project].

## Vite Ruby <img class="logo" src="/logo.svg" alt="Logo"/>

The [design of Vite Ruby][overview] shares a common thread with the design of [Vite.js].

I wanted to achieve a nice experience out of the box by providing [strong conventions][development], while at the same time allowing the user to opt-out or [tweak as needed][config].

In short, I'm striving to achieve a good __[balance]__.

I hope that you find this project as useful as it has been for [me].

## Acknowledgements 🙏

This project wouldn't exist without [Vite.js].

[Webpacker] broke ground in the Rails community by enabling everyone to use [webpack] and any modern framework, without struggling with the assets pipeline. It has been a major inspiration for this project.

Thanks to [Nick Cherry] for sharing [this fantastic speech][connection] many years ago.

## Contact ✉️

Please visit [GitHub Issues] to report bugs you find, and [GitHub Discussions] to make feature requests, or to get help.

Don't hesitate to [⭐️ star the project][project] if you find it useful!

Using it in production? Always love to hear about it! 😃
