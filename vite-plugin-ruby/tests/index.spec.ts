import { describe, test, expect } from 'vitest'
import { defaultConfig } from '@plugin/config'
import ViteRuby from '@plugin/index'

describe('config', () => {
  test('environment defaults', () => {
    const plugin = ViteRuby()
    const pluginConfig = plugin[0].config
    defaultConfig.configPath = './default.vite.json'

    // Sourcemap is no longer set by the plugin (Vite's safe default of `false`
    // applies in all modes). Users opt in via `build.sourcemap` in their vite.config.
    const productionConfig = pluginConfig(defaultConfig, { mode: 'production' })
    expect(productionConfig.build.emptyOutDir).toBe(false)
    expect(productionConfig.build.sourcemap).toBeUndefined()

    const stagingConfig = pluginConfig(defaultConfig, { mode: 'staging' })
    expect(stagingConfig.build.emptyOutDir).toBe(false)
    expect(stagingConfig.build.sourcemap).toBeUndefined()

    const developmentConfig = pluginConfig(defaultConfig, { mode: 'development' })
    expect(developmentConfig.build.emptyOutDir).toBe(true)
    expect(developmentConfig.build.sourcemap).toBeUndefined()

    const testConfig = pluginConfig(defaultConfig, { mode: 'test' })
    expect(testConfig.build.emptyOutDir).toBe(true)
    expect(testConfig.build.sourcemap).toBeUndefined()

    expect(() => {
      pluginConfig({ ...defaultConfig, build: { ssr: true } }, { mode: 'production' })
    }).toThrow('No SSR entrypoint available')
  })
})
