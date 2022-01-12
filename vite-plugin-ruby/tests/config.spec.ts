import { describe, test, expect } from 'vitest'
import { defaultConfig, resolveViteBase } from '@plugin/config'
import type { ResolvedConfig } from '@plugin/types'

const expectBaseFor = (config: ResolvedConfig) =>
  expect(resolveViteBase({ ...defaultConfig, ...config }))

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
