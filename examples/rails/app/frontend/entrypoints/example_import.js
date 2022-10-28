import '~/integrations/bugsnag'
// import '~/integrations/honeybadger'
import React from 'react'
import { createRoot } from 'react-dom/client'

import Hero from '~/components/Hero.jsx'

console.log('Vite ⚡️ Rails')

const root = createRoot(document.getElementById('hero'))
root.render(React.createElement(Hero))
