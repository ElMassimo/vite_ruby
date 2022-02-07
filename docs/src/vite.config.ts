import { resolve } from 'path'
import { defineConfig } from 'vite'
import windicss from 'vite-plugin-windicss'

export default defineConfig({
  plugins: [
    windicss({
      preflight: false,
      scan: {
        dirs: [resolve(__dirname, '../.vitepress/theme/components')],
      },
    }),
  ],
})
