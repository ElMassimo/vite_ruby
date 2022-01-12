import { resolve } from 'path'
import { defineConfig } from 'vite'

export default defineConfig({
  resolve: {
    alias: {
      '@plugin': resolve(__dirname, 'src'),
    },
  },
})
