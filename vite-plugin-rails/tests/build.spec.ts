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
      'assets/external-BhRq1rkB.js',
      'assets/external-BhRq1rkB.js.br',
      'assets/external-BhRq1rkB.js.gz',
      'assets/external-BhRq1rkB.js.map',
      'assets/index-dwdj7H_c.js',
      'assets/index-dwdj7H_c.js.br',
      'assets/index-dwdj7H_c.js.gz',
      'assets/logo-Bh_XL1Xl.png',
      'assets/logo-CPmPqqKk.png',
      'assets/logo-Nuo4H8F_.svg',
      'assets/main-ifTZ8Gak.js',
      'assets/main-ifTZ8Gak.js.br',
      'assets/main-ifTZ8Gak.js.gz',
      'assets/main-ifTZ8Gak.js.map',
      'assets/sassy-D5kz_As0.css',
      'assets/sassy-D5kz_As0.css.br',
      'assets/sassy-D5kz_As0.css.gz',
      'assets/theme-C09nxUps.css',
      'assets/theme-C09nxUps.css.br',
      'assets/theme-C09nxUps.css.gz',
      'assets/vue-BepfPMzO.css',
      'assets/vue-BepfPMzO.css.br',
      'assets/vue-BepfPMzO.css.gz',
      'assets/vue-DfcDSmWc.js',
      'assets/vue-DfcDSmWc.js.br',
      'assets/vue-DfcDSmWc.js.gz',
      'assets/vue-DfcDSmWc.js.map',
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
