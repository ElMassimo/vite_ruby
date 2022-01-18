import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import ViteLegacy from '@vitejs/plugin-legacy'
import ViteReact from '@vitejs/plugin-react'
import Environment from 'vite-plugin-environment'
import ManifestSRI from 'vite-plugin-manifest-sri'
import FullReload from 'vite-plugin-full-reload'
import WindiCSS from 'vite-plugin-windicss'
import BugsnagPlugins from './plugins/bugsnag'

export default defineConfig({
  plugins: [
    BugsnagPlugins,
    Environment({
      BUGSNAG_API_KEY: null,
      HONEYBADGER_API_KEY: null,
      HEROKU_RELEASE_VERSION: 'development',
      HEROKU_SLUG_COMMIT: 'main',
    }),
    RubyPlugin(),
    ManifestSRI(),
    FullReload(['config/routes.rb', 'app/views/**/*'], { delay: 200 }),
    ViteLegacy({
      targets: ['defaults', 'not IE 11'],
    }),
    ViteReact(),
    WindiCSS({
      root: __dirname,
      scan: {
        fileExtensions: ['erb', 'html', 'vue', 'jsx', 'tsx'], // and maybe haml
        dirs: ['app/views', 'app/frontend'], // or app/javascript
      },
    }),
  ],
  // Example: Importing assets from arbitrary paths.
  resolve: {
    alias: {
      '@administrator/': `${process.env.ADMINISTRATOR_ASSETS_PATH}/`,
    },
  },
  server: {
    fs: {
      allow: [process.env.ADMINISTRATOR_ASSETS_PATH!],
    },
  },
})
