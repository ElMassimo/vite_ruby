import { resolve } from 'path'
import { describe, test, expect } from 'vitest'
import { defaultConfig, resolveEntrypointFiles } from '@plugin/config'
import type { ResolvedConfig } from '@plugin/types'

const entrypointsFor = (config: Partial<ResolvedConfig>) => {
  config = { ...defaultConfig, ...config }
  return resolveEntrypointFiles(resolve('example'), config.sourceCodeDir, config)
}

const expectEntrypoints = (config: Partial<ResolvedConfig>) =>
  expect(entrypointsFor(config))

describe('resolveEntrypointFiles', () => {
  test('client build', () => {
    expectEntrypoints({}).toEqual([
      ['app/frontend/entrypoints/app.css', resolve('example/app/frontend/entrypoints/app.css')],
      ['app/frontend/entrypoints/main.ts', resolve('example/app/frontend/entrypoints/main.ts')],
      ['app/frontend/entrypoints/sassy.scss', resolve('example/app/frontend/entrypoints/sassy.scss')],
      ['app/frontend/entrypoints/frameworks/vue.js', resolve('example/app/frontend/entrypoints/frameworks/vue.js')],
      ['app/frontend/images/logo.png', resolve('example/app/frontend/images/logo.png')],
      ['app/frontend/images/logo.svg', resolve('example/app/frontend/images/logo.svg')],
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
