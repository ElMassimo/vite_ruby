import { resolve } from 'path'
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
    const files = await glob('**/*', { cwd: `${exampleDir}/public/vite`, onlyFiles: true })
    expect(files.sort()).toEqual(expect.arrayContaining([
      'assets/app.80592535.css',
      'assets/app.80592535.css.br',
      'assets/app.80592535.css.gz',
      'assets/external.d1ae13f1.js',
      'assets/external.d1ae13f1.js.br',
      'assets/external.d1ae13f1.js.gz',
      'assets/external.d1ae13f1.js.map',
      'assets/index.2d44b5f7.js',
      'assets/index.2d44b5f7.js.br',
      'assets/index.2d44b5f7.js.gz',
      'assets/index.2d44b5f7.js.map',
      'assets/log.818edfb8.js',
      'assets/log.818edfb8.js.br',
      'assets/log.818edfb8.js.gz',
      'assets/log.818edfb8.js.map',
      'assets/logo.03d6d6da.png',
      'assets/logo.322aae0c.svg',
      'assets/logo.f42fb7ea.png',
      'assets/main.e2bad79c.js',
      'assets/main.e2bad79c.js.br',
      'assets/main.e2bad79c.js.gz',
      'assets/main.e2bad79c.js.map',
      'assets/sassy.2f9e231e.css',
      'assets/sassy.2f9e231e.css.br',
      'assets/sassy.2f9e231e.css.gz',
      'assets/theme.eb94a372.css',
      'assets/theme.eb94a372.css.br',
      'assets/theme.eb94a372.css.gz',
      'assets/vue.05010a24.js',
      'assets/vue.05010a24.js.br',
      'assets/vue.05010a24.js.gz',
      'assets/vue.05010a24.js.map',
      'assets/vue.a42e2aeb.css',
      'assets/vue.a42e2aeb.css.br',
      'assets/vue.a42e2aeb.css.gz',
    ]))
  })
})
