import { resolve } from 'path'
import { readFileSync } from 'fs'
import { beforeAll, describe, test, expect } from 'vitest'
import execa from 'execa'
import glob from 'fast-glob'

const projectRoot = resolve(__dirname, '../')
const exampleDir = `${projectRoot}/example`

// Strip 8-char content hashes Vite/Rolldown injects into asset filenames so
// assertions and snapshots stay stable across platforms (Rolldown produces
// different JS chunk hashes on Linux vs macOS).
const stripHash = (s: string): string => s.replace(/-[A-Za-z0-9_-]{8}(?=\.)/g, '')

const normalize = (value: unknown): unknown => {
  if (typeof value === 'string') return stripHash(value)
  if (Array.isArray(value)) return value.map(normalize)
  if (value && typeof value === 'object') {
    return Object.fromEntries(
      Object.entries(value).map(([k, v]) => [
        stripHash(k),
        k === 'integrity' ? '<integrity>' : normalize(v),
      ]),
    )
  }
  return value
}

describe('config', () => {
  beforeAll(async () => {
    await execa('npm', ['run', 'build'], { stdio: process.env.DEBUG ? 'inherit' : undefined, cwd: exampleDir })
  }, 60000)

  test('generated files', async () => {
    const outDir = `${exampleDir}/public/vite`
    const files = await glob('**/*', { cwd: outDir, onlyFiles: true })
    expect(files.map(stripHash).sort()).toEqual(expect.arrayContaining([
      'assets/app.css',
      'assets/app.css.br',
      'assets/app.css.gz',
      'assets/external.js',
      'assets/external.js.br',
      'assets/external.js.gz',
      'assets/external.js.map',
      'assets/index.js',
      'assets/index.js.br',
      'assets/index.js.gz',
      'assets/logo.png',
      'assets/logo.svg',
      'assets/logo.svg.br',
      'assets/logo.svg.gz',
      'assets/main.js',
      'assets/main.js.br',
      'assets/main.js.gz',
      'assets/main.js.map',
      'assets/sassy.css',
      'assets/sassy.css.br',
      'assets/sassy.css.gz',
      'assets/theme.css',
      'assets/theme.css.br',
      'assets/theme.css.gz',
      'assets/vue.css',
      'assets/vue.css.br',
      'assets/vue.css.gz',
      'assets/vue.js',
      'assets/vue.js.br',
      'assets/vue.js.gz',
      'assets/vue.js.map',
      'index.html',
      'index.html.br',
      'index.html.gz',
    ]))

    const parseManifest = (path: string) => JSON.parse(readFileSync(`${outDir}/.vite/${path}`, 'utf-8'))
    const manifest = parseManifest('manifest.json')
    const manifestAssets = parseManifest('manifest-assets.json')

    expect(normalize({ ...manifest, ...manifestAssets })).toMatchSnapshot()
  })
})
