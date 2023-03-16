import { resolve } from 'path'
import { readFileSync } from 'fs'
import { beforeAll, describe, test, expect } from 'vitest'
import execa from 'execa'
import glob from 'fast-glob'

const projectRoot = resolve(__dirname, '../')
const exampleDir = `${projectRoot}/example`

describe('config', () => {
  beforeAll(async () => {
    await execa('npm', ['run', 'build'], { stdio: process.env.DEBUG ? 'inherit' : undefined, cwd: exampleDir })
  }, 60000)

  test('generated files', async () => {
    const outDir = `${exampleDir}/public/vite`
    const files = await glob('**/*', { cwd: outDir, onlyFiles: true })
    expect(files.sort()).toEqual(expect.arrayContaining([
      'assets/app-80592535.css',
      'assets/app-80592535.css.br',
      'assets/app-80592535.css.gz',
      'assets/external-088a12da.js',
      'assets/external-088a12da.js.br',
      'assets/external-088a12da.js.gz',
      'assets/external-088a12da.js.map',
      'assets/index-fe03930f.js',
      'assets/index-fe03930f.js.br',
      'assets/index-fe03930f.js.gz',
      'assets/index-fe03930f.js.map',
      'assets/log-092f4148.js',
      'assets/log-092f4148.js.br',
      'assets/log-092f4148.js.gz',
      'assets/log-092f4148.js.map',
      'assets/logo-03d6d6da.png',
      'assets/logo-322aae0c.svg',
      'assets/logo-f42fb7ea.png',
      'assets/main-fd323c2a.js',
      'assets/main-fd323c2a.js.br',
      'assets/main-fd323c2a.js.gz',
      'assets/main-fd323c2a.js.map',
      'assets/sassy-2f9e231e.css',
      'assets/sassy-2f9e231e.css.br',
      'assets/sassy-2f9e231e.css.gz',
      'assets/theme-eb94a372.css',
      'assets/theme-eb94a372.css.br',
      'assets/theme-eb94a372.css.gz',
      'assets/vue-3d27911e.js',
      'assets/vue-3d27911e.js.br',
      'assets/vue-3d27911e.js.gz',
      'assets/vue-3d27911e.js.map',
      'assets/vue-b821fb22.css',
      'assets/vue-b821fb22.css.br',
      'assets/vue-b821fb22.css.gz',
    ]))

    const parseManifest = (path: string) => JSON.parse(readFileSync(`${outDir}/${path}`, 'utf-8'))
    const manifest = parseManifest('manifest.json')
    const manifestAssets = parseManifest('manifest-assets.json')

    expect({ ...manifest, ...manifestAssets }).toMatchSnapshot()
  })
})
