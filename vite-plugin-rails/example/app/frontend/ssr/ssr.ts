import { createSSRApp, h } from 'vue'
import { renderToString } from '@vue/server-renderer'
import { createInertiaApp } from '@inertiajs/inertia-vue3'
import createServer from '@inertiajs/server'

const pages = import.meta.glob('../pages/*.vue', { import: 'default', eager: true })

createServer(page => createInertiaApp({
  page,
  render: renderToString,
  resolve: name => pages[`../Pages/${name}.vue`],
  setup ({ app, props, plugin }) {
    return createSSRApp({
      render: () => h(app, props),
    }).use(plugin)
  },
}))
