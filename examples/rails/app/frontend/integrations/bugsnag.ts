import Bugsnag from '@bugsnag/js'
import BugsnagPluginReact from '@bugsnag/plugin-react'

if (process.env.BUGSNAG_API_KEY) {
  Bugsnag.start({
    apiKey: process.env.BUGSNAG_API_KEY,
    plugins: [new BugsnagPluginReact()],
  })

  Bugsnag.notify(new Error('Test Error'))
}

export default Bugsnag
