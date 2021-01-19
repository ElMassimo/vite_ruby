import { defineConfig } from 'vite'
import VuePlugin from '@vitejs/plugin-vue'
import RubyPlugin from 'vite-plugin-ruby'

export default defineConfig({
  plugins: [
    VuePlugin(),
    RubyPlugin(),
  ],
  optimizeDeps: {
    exclude: [/webpack/, /vite-plugin-ruby/],
  },
})
