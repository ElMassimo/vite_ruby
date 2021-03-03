import { resolve } from 'path'
import { UserConfig } from 'vite'
import Vue from '@vitejs/plugin-vue'
import ViteRuby from 'vite-plugin-ruby'

const config: UserConfig = {
  resolve: {
    alias: {
      '@assets/': `${resolve(process.cwd(), 'app/assets')}/`,
    },
  },
  plugins: [
    Vue(),
    ViteRuby(),
  ],
}

export default config
