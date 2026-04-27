import ViteReact from '@vitejs/plugin-react'
import { defineConfig } from 'vite'
import rails from 'vite-plugin-rails'
import WindiCSS from 'vite-plugin-windicss'
import BugsnagPlugins from './plugins/bugsnag'

const administratorAssetsPath = process.env.ADMINISTRATOR_ASSETS_PATH

export default defineConfig({
  plugins: [
    BugsnagPlugins,
    rails({
      envVars: {
        BUGSNAG_API_KEY: null,
        HONEYBADGER_API_KEY: null,
        HEROKU_RELEASE_VERSION: 'development',
        HEROKU_SLUG_COMMIT: 'main',
      },
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
    alias: administratorAssetsPath
      ? { '@administrator/': `${administratorAssetsPath}/` }
      : {},
  },
  server: {
    fs: {
      allow: administratorAssetsPath ? [administratorAssetsPath] : [],
    },
  },
})
