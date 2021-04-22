import path from 'path'
import { defineConfig } from 'vite'
import RubyPlugin, { projectRoot } from 'vite-plugin-ruby'
import ViteLegacy from '@vitejs/plugin-legacy'
import ViteReact from '@vitejs/plugin-react-refresh'
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
  build: {
    rollupOptions: {
      output: {
        sourcemapPathTransform: (relativeSourcePath, sourcemapPath) => {
          return path.relative(projectRoot, path.resolve(path.dirname(sourcemapPath), relativeSourcePath))
        },
      },
    },
  },
  plugins: [
    isDistEnv && BugsnagBuildReporterPlugin({ ...bugsnagOptions, releaseStage: process.env.RAILS_ENV }),
    isDistEnv && BugsnagSourceMapUploaderPlugin({ ...bugsnagOptions, overwrite: true }),
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
