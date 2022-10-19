import { describe, test, expect } from 'vitest'
import ViteRails, { type Options } from '@plugin/index'

describe('config', () => {
  const pluginCount = (options?: Options) => ViteRails(options).length

  test('added plugins', () => {
    const DEFAULT = 8
    expect(pluginCount()).toEqual(DEFAULT)

    // Compression
    expect(pluginCount({ compress: { brotli: false } })).toEqual(DEFAULT - 1)
    expect(pluginCount({ compress: { gzip: false } })).toEqual(DEFAULT - 1)
    expect(pluginCount({ compress: false })).toEqual(DEFAULT - 2)

    // Environment Variables
    expect(pluginCount({ envVars: 'all' })).toEqual(DEFAULT + 1)

    // Full Reload
    expect(pluginCount({ fullReload: false })).toEqual(DEFAULT - 1)
    expect(pluginCount({ fullReload: { additionalPaths: ['app/serializers/**/*'] } })).toEqual(DEFAULT)
    expect(pluginCount({ fullReload: { additionalPaths: 'app/serializers/**/*' } })).toEqual(DEFAULT)
    expect(pluginCount({ fullReload: { overridePaths: ['app/views/**/*.html.erb'] } })).toEqual(DEFAULT)

    // SRI
    expect(pluginCount({ sri: false })).toEqual(DEFAULT - 1)
    expect(pluginCount({ sri: { algorithms: ['sha512'] } })).toEqual(DEFAULT)

    // Stimulus HMR
    expect(pluginCount({ stimulus: false })).toEqual(DEFAULT - 1)
    expect(pluginCount({ stimulus: { appGlobal: 'Stimulus' } })).toEqual(DEFAULT)
  })
})
