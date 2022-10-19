import { resolve } from 'path'
import { defineConfig } from 'vite'
import Vue from '@vitejs/plugin-vue'
import ViteRails from 'vite-plugin-rails'

export default defineConfig({
  resolve: {
    alias: {
      '@assets/': `${resolve(__dirname, 'app/assets')}/`,
    },
  },
  plugins: [
    Vue(),
    ViteRails({ fullReload: false }),
  ],
})
