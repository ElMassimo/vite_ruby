import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import ViteLegacy from '@vitejs/plugin-legacy'
import ViteReact from '@vitejs/plugin-react'
import Environment from 'vite-plugin-environment'
import FullReload from 'vite-plugin-full-reload'
import WindiCSS from 'vite-plugin-windicss'
import { BugsnagBuildReporterPlugin, BugsnagSourceMapUploaderPlugin } from 'vite-plugin-bugsnag'

const isDistEnv = process.env.RAILS_ENV === 'production'

const bugsnagOptions = {
  apiKey: process.env.BUGSNAG_API_KEY!,
  appVersion: process.env.HEROKU_RELEASE_VERSION!,
}

export default defineConfig({
  define: {
    'process.env.BUGSNAG_API_KEY': JSON.stringify(process.env.BUGSNAG_API_KEY),
  },
  plugins: [
    isDistEnv && BugsnagBuildReporterPlugin({ ...bugsnagOptions, releaseStage: process.env.RAILS_ENV }),
    isDistEnv && BugsnagSourceMapUploaderPlugin({ ...bugsnagOptions, overwrite: true }),
    Environment({
      BUGSNAG_API_KEY: null,
      HONEYBADGER_API_KEY: null,
      HEROKU_RELEASE_VERSION: 'development',
      HEROKU_SLUG_COMMIT: 'main',
    }),
    RubyPlugin(),
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
})
