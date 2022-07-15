import { resolve } from 'path'
import { describe, test, expect } from 'vitest'
import { defaultConfig, resolveViteBase, loadConfiguration } from '@plugin/config'
import type { ResolvedConfig } from '@plugin/types'
import type { UserConfig } from 'vite'

const exampleDir = resolve('example')

const expectBaseFor = (config: Partial<ResolvedConfig>) =>
  expect(resolveViteBase({ ...defaultConfig, ...config }))

const expectResolvedConfig = (config: UserConfig, ...keys: string[]) => {
  let resolvedConfig: any = loadConfiguration('development', exampleDir, config)
  keys.forEach((option) => { resolvedConfig = resolvedConfig[option] })
  return expect(resolvedConfig)
}

describe('resolveViteBase', () => {
  test('default usage', () => {
    expectBaseFor({}).toEqual('/vite/')
    expectBaseFor({ publicOutputDir: '' }).toEqual('/')
    expectBaseFor({ publicOutputDir: 'assets/frontend' }).toEqual('/assets/frontend/')
  })

  test('windows compatibility', () => {
    expectBaseFor({ publicOutputDir: 'assets\\frontend' }).toEqual('/assets/frontend/')
  })

  test('custom base', () => {
    expectBaseFor({ base: '/sub' }).toEqual('/sub/vite/')
    expectBaseFor({ base: '/sub/' }).toEqual('/sub/vite/')
    expectBaseFor({ base: '/sub', publicOutputDir: '' }).toEqual('/sub/')
    expectBaseFor({ base: '/sub/', publicOutputDir: '' }).toEqual('/sub/')
  })

  test('supports asset host', () => {
    expectBaseFor({ assetHost: 'assets-cdn.com' }).toEqual('//assets-cdn.com/vite/')
    expectBaseFor({ assetHost: 'https://assets-cdn.com' }).toEqual('https://assets-cdn.com/vite/')
    expectBaseFor({ assetHost: 'assets-cdn.com', publicOutputDir: '' }).toEqual('//assets-cdn.com/')
    expectBaseFor({ assetHost: 'http://assets-cdn.com', publicOutputDir: '' }).toEqual('http://assets-cdn.com/')
  })
})

describe('loadConfiguration', () => {
  test('configures server', () => {
    expectResolvedConfig({}, 'server')
      .toEqual({
        fs: {
          allow: [
            exampleDir,
          ],
          strict: true,
        },
        hmr: {
          clientPort: 3037,
        },
        host: 'localhost',
        https: null,
        port: 3037,
        strictPort: true,
      })
  })

  test('avoids overriding user config for hmr', () => {
    expectResolvedConfig({}, 'server')
      .toHaveProperty('hmr', { clientPort: 3037 })

    expectResolvedConfig({ server: { hmr: { host: 'vite.myapp.test', clientPort: 443 } } }, 'server')
      .not.toHaveProperty('hmr')

    expectResolvedConfig({ server: { hmr: true } }, 'server')
      .not.toHaveProperty('hmr')

    expectResolvedConfig({ server: { hmr: false } }, 'server')
      .not.toHaveProperty('hmr')
  })
})
