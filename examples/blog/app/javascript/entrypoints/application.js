// Example: Load Rails libraries in Vite.
import '@rails/ujs'

import Turbolinks from 'turbolinks'
import ActiveStorage from '@rails/activestorage'

// Import all channels.
import.meta.globEager('../channels/**/*_channel.js')

Turbolinks.start()
ActiveStorage.start()

// Example: Import a stylesheet in app/javascript/styles
import '~/styles/tailwind.css'
import '~/styles/index.css'

import '~/entrypoints/example_import.js'
import '~/outer_import.js'

