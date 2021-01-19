<h2 align='center'><samp>vite-plugin-ruby</samp></h2>

<p align='center'>Convention over configuration for Ruby projects using Vite</p>

<p align='center'>
  <a href='https://www.npmjs.com/package/vite-plugin-ruby'>
    <img src='https://img.shields.io/npm/v/vite-plugin-ruby?color=222&style=flat-square'>
  </a>
  <a href='https://github.com/ElMassimo/vite_rails/blob/master/LICENSE.txt'>
    <img src='https://img.shields.io/badge/license-MIT-blue.svg'>
  </a>
</p>

<br>

[vite_rails]: https://github.com/ElMassimo/vite_rails
[configuration options]: https://github.com/ElMassimo/vite_rails

## Installation 💿

If you are using Rails, you should instead check out [<kbd>vite_rails</kbd>][vite_rails],
which uses this plugin and will configure it for you.

```bash
npm i vite-plugin-ruby # yarn add vite-plugin-ruby
```

## Usage 🚀

Add it to your plugins in `vite.config.js`

```ts
// vite.config.js
import Vue from '@vitejs/plugin-vue' // Example, could be using other plugins.
import ViteRuby from 'vite-plugin-ruby'

export default {
  plugins: [
    Vue(),
    ViteRuby(),
  ],
  optimizeDeps: {
    exclude: [/vite-plugin-ruby/],
  },
};
```

You can now configure it using `config/vite.json`, check out the available
[configuration options] for reference.


## Thanks

- [vite-plugin-components](https://github.com/antfu/vite-plugin-components): Picked up that neat pnpm setup.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
