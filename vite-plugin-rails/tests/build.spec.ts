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
      'assets/app-OK6MABcH.css',
      'assets/app-OK6MABcH.css.br',
      'assets/app-OK6MABcH.css.gz',
      'assets/external-BwssHmjP.js',
      'assets/external-BwssHmjP.js.br',
      'assets/external-BwssHmjP.js.gz',
      'assets/external-BwssHmjP.js.map',
      'assets/index-qTzjl5TV.js',
      'assets/index-qTzjl5TV.js.br',
      'assets/index-qTzjl5TV.js.gz',
      'assets/logo-Bh_XL1Xl.png',
      'assets/logo-CPmPqqKk.png',
      'assets/logo-Nuo4H8F_.svg',
      'assets/logo-Nuo4H8F_.svg.br',
      'assets/logo-Nuo4H8F_.svg.gz',
      'assets/main-Ddvw3iap.js',
      'assets/main-Ddvw3iap.js.br',
      'assets/main-Ddvw3iap.js.gz',
      'assets/main-Ddvw3iap.js.map',
      'assets/sassy-D5kz_As0.css',
      'assets/sassy-D5kz_As0.css.br',
      'assets/sassy-D5kz_As0.css.gz',
      'assets/theme-C09nxUps.css',
      'assets/theme-C09nxUps.css.br',
      'assets/theme-C09nxUps.css.gz',
      'assets/vue-BepfPMzO.css',
      'assets/vue-BepfPMzO.css.br',
      'assets/vue-BepfPMzO.css.gz',
      'assets/vue-CoJ_KGkH.js',
      'assets/vue-CoJ_KGkH.js.br',
      'assets/vue-CoJ_KGkH.js.gz',
      'assets/vue-CoJ_KGkH.js.map',
      'index.html',
      'index.html.br',
      'index.html.gz',
    ]))

    const parseManifest = (path: string) => JSON.parse(readFileSync(`${outDir}/.vite/${path}`, 'utf-8'))
    const manifest = parseManifest('manifest.json')
    const manifestAssets = parseManifest('manifest-assets.json')

    expect({ ...manifest, ...manifestAssets }).toMatchSnapshot()
  })
})
