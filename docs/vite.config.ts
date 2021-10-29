import { defineConfig } from 'vite'
import unocss from 'unocss/vite'

export default defineConfig({
  plugins: [
    unocss({
      include: [/\.vitepress\/components/],
    }),
  ],
})
