import { resolve } from 'path'
import { beforeAll, describe, test, expect } from 'vitest'
import execa from 'execa'
import glob from 'fast-glob'

const projectRoot = resolve(__dirname, '../')
const example = `${projectRoot}/example`

describe('config', () => {
  beforeAll(async () => {
    await execa('npm', ['run', 'build'], { stdio: process.env.DEBUG ? 'inherit' : undefined, cwd: example })
  }, 60000)

  test('generated files', async () => {
    const files = await glob('**/*', { cwd: `${example}/dist`, onlyFiles: true })
    expect(files.sort()).toEqual(expect.arrayContaining([
      '404.html',
      '_headers',
      'assets/style.6f5a3ac7.css',
      'assets/turbo.a9e83070.js',
      'favicon.ico',
      'feed.rss',
      'index.html',
      'logo.svg',
      'manifest.json',
      'posts/1.html',
      'posts/2.html',
      'posts/hello-2021.html',
      'posts/volar-1-0.html',
      'posts/vue-3-2.html',
      'posts/vue-3-one-piece.html',
      'sitemap.xml',
    ]))
  })
})
