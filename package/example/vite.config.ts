import path from 'path'
import { UserConfig } from 'vite'
import Vue from '@vitejs/plugin-vue'
import ViteRuby from 'vite-plugin-ruby'

const config: UserConfig = {
  plugins: [
    Vue(),
    ViteRuby(),
  ],
  optimizeDeps: {
    exclude: [/webpack/], // In case webpacker is installed (these deps won't be imported)
  },
}

export default config
