import { resolve } from 'path'
import { type UserConfig } from 'vite'
import Vue from '@vitejs/plugin-vue'
import ViteRails from 'vite-plugin-rails'

const config: UserConfig = {
  resolve: {
    alias: {
      '@assets/': `${resolve(__dirname, 'app/assets')}/`,
    },
  },
  plugins: [
    Vue(),
    ViteRails(),
  ],
}

export default config
