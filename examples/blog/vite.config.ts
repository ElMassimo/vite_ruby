import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'

export default defineConfig({
  plugins: [
    RubyPlugin(),
  ],
  optimizeDeps: {
    exclude: [/webpack/], // In case webpacker is installed (these deps won't be imported)
  },
})
