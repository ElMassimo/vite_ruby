import '@rails/ujs'
import Turbolinks from 'turbolinks'
import ActiveStorage from '@rails/activestorage'
import { createApp } from 'vue'

import App from '~/App.vue'
import '~/channels'
import '../../stylesheets/index.css'

Turbolinks.start()
ActiveStorage.start()

console.log('Vite ⚡️ Rails')

createApp(App).mount('#app')

