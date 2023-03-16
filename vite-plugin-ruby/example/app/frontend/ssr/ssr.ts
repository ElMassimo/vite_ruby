import { createSSRApp, h } from 'vue'
import { renderToString } from '@vue/server-renderer'
import { createInertiaApp } from '@inertiajs/inertia-vue3'
import createServer from '@inertiajs/server'
import logo from '~/images/logo.svg'
console.info({ logo })

const pages = import.meta.globEagerDefault('../pages/*.vue')

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
