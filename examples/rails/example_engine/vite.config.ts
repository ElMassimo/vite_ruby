import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import ManifestSRI from 'vite-plugin-manifest-sri'

export default defineConfig({
  plugins: [
    RubyPlugin(),
    ManifestSRI(),
  ],
})
