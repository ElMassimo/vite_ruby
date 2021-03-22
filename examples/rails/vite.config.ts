import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import ViteLegacy from '@vitejs/plugin-legacy'
import FullReload from 'vite-plugin-full-reload'
import WindiCSS from 'vite-plugin-windicss'

export default defineConfig({
  plugins: [
    RubyPlugin(),
    FullReload(['config/routes.rb', 'app/views/**/*'], { delay: 200 }),
    ViteLegacy({
      targets: ['defaults', 'not IE 11'],
    }),
    WindiCSS({
      root: __dirname,
      scan: {
        fileExtensions: ['erb', 'html', 'vue', 'jsx', 'tsx'], // and maybe haml
        dirs: ['app/views', 'app/frontend'], // or app/javascript
      },
    }),
  ],
})
