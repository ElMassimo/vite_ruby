import { BugsnagBuildReporterPlugin, BugsnagSourceMapUploaderPlugin } from 'vite-plugin-bugsnag'

const options = {
  apiKey: process.env.BUGSNAG_API_KEY!,
  appVersion: process.env.HEROKU_RELEASE_VERSION!,
}

const useBugsnag = process.env.RAILS_ENV === 'production' && Boolean(options.apiKey)

export default useBugsnag
  ? [
    BugsnagBuildReporterPlugin({ ...options, releaseStage: process.env.RAILS_ENV }),
    BugsnagSourceMapUploaderPlugin({ ...options, overwrite: true }),
  ]
  : []
