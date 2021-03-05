import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import ViteLegacy from '@vitejs/plugin-legacy'

export default defineConfig({
  plugins: [
    RubyPlugin(),
    ViteLegacy({
      targets: ['defaults', 'not IE 11'],
    }),
  ],
})
