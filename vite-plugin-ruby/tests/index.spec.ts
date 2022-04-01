import { describe, test, expect } from 'vitest'
import { defaultConfig } from '@plugin/config'
import ViteRuby from '@plugin/index'

describe('config', () => {
  test('environment defaults', () => {
    const plugin = ViteRuby()
    const pluginConfig = plugin[0].config
    defaultConfig.configPath = './default.vite.json'

    const productionConfig = pluginConfig(defaultConfig, { mode: 'production' })
    expect(productionConfig.build.emptyOutDir).toBe(false)
    expect(productionConfig.build.sourcemap).toBe(true)

    const stagingConfig = pluginConfig(defaultConfig, { mode: 'staging' })
    expect(stagingConfig.build.emptyOutDir).toBe(false)
    expect(stagingConfig.build.sourcemap).toBe(true)

    const developmentConfig = pluginConfig(defaultConfig, { mode: 'development' })
    expect(developmentConfig.build.emptyOutDir).toBe(true)
    expect(developmentConfig.build.sourcemap).toBe(false)

    const testConfig = pluginConfig(defaultConfig, { mode: 'test' })
    expect(testConfig.build.emptyOutDir).toBe(true)
    expect(testConfig.build.sourcemap).toBe(false)
  })
})
