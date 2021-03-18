import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import ViteLegacy from '@vitejs/plugin-legacy'
import FullReload from 'vite-plugin-full-reload'

export default defineConfig({
  plugins: [
    RubyPlugin(),
    FullReload(['config/routes.rb', 'app/views/**/*']),
    ViteLegacy({
      targets: ['defaults', 'not IE 11'],
    }),
  ],
})
