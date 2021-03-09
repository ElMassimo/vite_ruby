import Theme from 'vitepress/theme'
import Quote from '../components/Quote.vue'

import 'windi.css'
import '../styles/styles.css'

export default {
  ...Theme,
  enhanceApp ({ app }) {
    app.component('Quote', Quote)
  },
}
