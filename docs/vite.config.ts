import { defineConfig } from 'vite'
import windicss from 'vite-plugin-windicss'

export default defineConfig({
  plugins: [
    windicss({
      preflight: false,
      scan: {
        dirs: ['.vitepress/components'],
      },
    }),
  ],
})
