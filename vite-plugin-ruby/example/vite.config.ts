import { resolve } from 'path'
import { UserConfig } from 'vite'
import Vue from '@vitejs/plugin-vue'
import ViteRuby from 'vite-plugin-ruby'
import ViteLegacy from '@vitejs/plugin-legacy'

const config: UserConfig = {
  resolve: {
    alias: {
      '@assets/': `${resolve(__dirname, 'app/assets')}/`,
    },
  },
  plugins: [
    Vue(),
    ViteRuby(),
    ViteLegacy({
      targets: ['defaults', 'not IE 11'],
    }),
  ],
}

export default config
