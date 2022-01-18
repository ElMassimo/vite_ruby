// Example: Load Rails libraries in Vite.
import * as Turbo from '@hotwired/turbo'
import * as ActiveStorage from '@rails/activestorage'

// Enable Windi CSS styles and preflight
import 'windi.css'

// Example: Import a stylesheet in app/frontend/styles
import '~/styles/theme.css'

import '~/entrypoints/example_import'
setTimeout(() => import('~/outer_import'), 5000)

// Example: Import from an aliased path.
import '@administrator/timer'

// Import all channels.
import.meta.globEager('../channels/**/*_channel.js')

Turbo.start()
ActiveStorage.start()

console.log('Visit the guide for more information: ', 'https://vite-ruby.netlify.app/guide/rails')
