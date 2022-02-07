import { VPTheme } from '@mussi/vitepress-theme'
import Quote from './components/Quote.vue'

import 'windi.css'
import './styles/styles.css'

export default {
  ...VPTheme,
  enhanceApp ({ app }) {
    app.component('Quote', Quote)
  },
}
