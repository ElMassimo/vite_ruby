// Example: Load Rails libraries in Vite.
import '@rails/ujs'

import Turbolinks from 'turbolinks'
import * as ActiveStorage from '@rails/activestorage'

// Example: Import a stylesheet in app/frontend/styles
import '~/styles/theme.css'

import '~/entrypoints/example_import.js'
import '~/outer_import.js'

// Import all channels.
import.meta.globEager('../channels/**/*_channel.js')

Turbolinks.start()
ActiveStorage.start()
