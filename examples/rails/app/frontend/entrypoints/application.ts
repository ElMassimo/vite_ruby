// Example: Load Rails libraries in Vite.
import '@rails/ujs'

import Turbolinks from 'turbolinks'
import * as ActiveStorage from '@rails/activestorage'

// Enable Windi CSS styles and preflight
import 'windi.css'

// Example: Import a stylesheet in app/frontend/styles
import '~/styles/theme.css'

import '~/entrypoints/example_import.js'
import '~/outer_import.js'

// Example: Import from an aliased path.
import '@administrator/timer'

// Import all channels.
import.meta.globEager('../channels/**/*_channel.js')

Turbolinks.start()
ActiveStorage.start()

console.log('Visit the guide for more information: ', 'https://vite-ruby.netlify.app/guide/rails')
