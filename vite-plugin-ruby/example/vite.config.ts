import { resolve } from 'path'
import { defineConfig } from 'vite'
import Vue from '@vitejs/plugin-vue'
import ViteRuby from 'vite-plugin-ruby'
import ViteLegacy from '@vitejs/plugin-legacy'

export default defineConfig({
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
})
