import { resolve } from 'path'
import { describe, test, expect } from 'vitest'
import { defaultConfig, resolveEntrypointFiles } from '@plugin/config'
import type { ResolvedConfig } from '@plugin/types'

const entrypointsFor = (overrideConfig: Partial<ResolvedConfig>) => {
  const { sourceCodeDir = '', ...config } = { ...defaultConfig, ...overrideConfig }
  return resolveEntrypointFiles(resolve('example'), resolve('example', sourceCodeDir), config as ResolvedConfig)
}

const expectEntrypoints = (config: Partial<ResolvedConfig>) =>
  expect(entrypointsFor(config))

describe('resolveEntrypointFiles', () => {
  test('client build', () => {
    const defaultEntrypoints = [
      ['entrypoints/app.css', resolve('example/app/frontend/entrypoints/app.css')],
      ['entrypoints/main.ts', resolve('example/app/frontend/entrypoints/main.ts')],
      ['entrypoints/sassy.scss', resolve('example/app/frontend/entrypoints/sassy.scss')],
      ['entrypoints/frameworks/vue.js', resolve('example/app/frontend/entrypoints/frameworks/vue.js')],
    ]

    expectEntrypoints({}).toEqual([
      ...defaultEntrypoints,
      ['images/logo.png', resolve('example/app/frontend/images/logo.png')],
      ['images/logo.svg', resolve('example/app/frontend/images/logo.svg')],
    ])

    expectEntrypoints({ additionalEntrypoints: ['app/assets/*.{js,css}'] }).toEqual([
      ...defaultEntrypoints,
      ['app/assets/external.js', resolve('example/app/assets/external.js')],
      ['app/assets/theme.css', resolve('example/app/assets/theme.css')],
    ])
  })

  test('ssr build', () => {
    expectEntrypoints({ ssrBuild: true }).toEqual([
      ['ssr', resolve('example/app/frontend/ssr/ssr.ts')],
    ])

    expect(() => entrypointsFor({ sourceCodeDir: 'app/missing', ssrBuild: true }))
      .toThrow('No SSR entrypoint available')

    expect(() => entrypointsFor({ sourceCodeDir: 'app/incorrect', ssrBuild: true }))
      .toThrow('Expected a single SSR entrypoint, found')
  })
})
