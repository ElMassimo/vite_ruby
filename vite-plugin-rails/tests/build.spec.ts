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
      'assets/app-HiPXl-_u.css',
      'assets/app-HiPXl-_u.css.br',
      'assets/app-HiPXl-_u.css.gz',
      'assets/external-TUcZQQlC.js',
      'assets/external-TUcZQQlC.js.br',
      'assets/external-TUcZQQlC.js.gz',
      'assets/external-TUcZQQlC.js.map',
      'assets/index-B7_jTNDK.js',
      'assets/index-B7_jTNDK.js.br',
      'assets/index-B7_jTNDK.js.gz',
      'assets/index-B7_jTNDK.js.map',
      'assets/logo-DbqOB_Bf.svg',
      'assets/logo-DbqOB_Bf.svg.br',
      'assets/logo-DbqOB_Bf.svg.gz',
      'assets/logo-Yf1y9V5e.png',
      'assets/logo-j5j6qipL.png',
      'assets/main-dr7zO5Jf.js',
      'assets/main-dr7zO5Jf.js.br',
      'assets/main-dr7zO5Jf.js.gz',
      'assets/main-dr7zO5Jf.js.map',
      'assets/sassy-NCcoc604.css',
      'assets/sassy-NCcoc604.css.br',
      'assets/sassy-NCcoc604.css.gz',
      'assets/theme-gVQjH5fM.css',
      'assets/theme-gVQjH5fM.css.br',
      'assets/theme-gVQjH5fM.css.gz',
      'assets/vue--K8PDpiS.js',
      'assets/vue--K8PDpiS.js.br',
      'assets/vue--K8PDpiS.js.gz',
      'assets/vue--K8PDpiS.js.map',
      'assets/vue-Mdlordc1.css',
      'assets/vue-Mdlordc1.css.br',
      'assets/vue-Mdlordc1.css.gz',
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
