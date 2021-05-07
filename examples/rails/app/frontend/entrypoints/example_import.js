import '~/integrations/bugsnag'
import '~/integrations/honeybadger'
import React from 'react'
import ReactDom from 'react-dom'

import Hero from '~/components/Hero.jsx'

console.log('Vite ⚡️ Rails')

ReactDom.render(React.createElement(Hero), document.getElementById('hero'))
