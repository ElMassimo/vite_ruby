import Bugsnag from '@bugsnag/js'
import BugsnagPluginReact from '@bugsnag/plugin-react'

if (import.meta.env.BUGSNAG_API_KEY) {
  Bugsnag.start({
    apiKey: import.meta.env.BUGSNAG_API_KEY,
    plugins: [new BugsnagPluginReact()],
  })

  Bugsnag.notify(new Error('Test Error'))
}

export default Bugsnag
