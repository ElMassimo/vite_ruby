import tailwindcss from '@tailwindcss/vite'
import ViteReact from '@vitejs/plugin-react'
import { defineConfig } from 'vite'
import rails from 'vite-plugin-rails'
import BugsnagPlugins from './plugins/bugsnag'

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
    tailwindcss(),
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
