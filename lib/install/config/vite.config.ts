import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'

export default defineConfig({
  plugins: [
    RubyPlugin(),
  ],
  optimizeDeps: {
    exclude: [/webpack/, /vite-plugin-ruby/],
  },
})
