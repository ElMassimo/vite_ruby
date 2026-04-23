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

    expect(() => {
      pluginConfig({ ...defaultConfig, build: { ssr: true } }, { mode: 'production' })
    }).toThrow('No SSR entrypoint available')
  })

  describe('outputFileName (assetFileNames)', () => {
    function getAssetFileNames () {
      const plugin = ViteRuby()
      const pluginConfig = plugin[0].config
      defaultConfig.configPath = './default.vite.json'
      const result = pluginConfig(defaultConfig, { mode: 'production' })
      return result.build.rollupOptions.output.assetFileNames as (asset: any) => string
    }

    const source = 'content'

    test('legacy `name` shape (Vite v7)', () => {
      const assetFileNames = getAssetFileNames()
      const result = assetFileNames({ type: 'asset', name: 'application.css', source })
      expect(result).toMatch(/^assets\/application-[^.]+\.\[ext\]$/)
    })

    test('new `names` shape (Vite v8)', () => {
      const assetFileNames = getAssetFileNames()
      const result = assetFileNames({ type: 'asset', names: ['application.css'], originalFileNames: [], source })
      expect(result).toMatch(/^assets\/application-[^.]+\.\[ext\]$/)
    })

    test('falls back to `[name]` placeholder when both are absent', () => {
      const assetFileNames = getAssetFileNames()
      const result = assetFileNames({ type: 'asset', source })
      expect(result).toBe('assets/[name]-[hash].[ext]')
    })
  })
})
