import { existsSync, mkdtempSync } from 'fs'
import { tmpdir } from 'os'
import { join } from 'path'
import { describe, it, expect } from 'vitest'

import { removeOwnedMeta, resolveDevServerMeta, writeDevServerMeta } from '../src/dev-server'

const withServer = (server: Record<string, unknown>) => ({ server }) as any

describe('resolveDevServerMeta', () => {
  it('uses the bound port and the configured host', () => {
    const meta = resolveDevServerMeta({ address: '127.0.0.1', family: 'IPv4', port: 5273 } as any, withServer({ host: 'localhost', https: false, port: 3036 }))

    expect(meta.url).toBe('http://localhost:5273')
    expect(meta).toMatchObject({ host: 'localhost', port: 5273, https: false })
  })

  it('replaces wildcard hosts with localhost and honors https', () => {
    const meta = resolveDevServerMeta({ port: 3036 } as any, withServer({ host: '0.0.0.0', https: {}, port: 3036 }))

    expect(meta.url).toBe('https://localhost:3036')
    expect(meta.https).toBe(true)
  })
})

describe('removeOwnedMeta', () => {
  it('only removes the file when the pid matches', () => {
    const path = join(mkdtempSync(join(tmpdir(), 'vpr-')), 'vite-ruby.json')
    writeDevServerMeta(path, { url: 'x', host: 'h', port: 1, https: false, pid: 4242 })

    removeOwnedMeta(path, 9999)
    expect(existsSync(path)).toBe(true)

    removeOwnedMeta(path, 4242)
    expect(existsSync(path)).toBe(false)
  })
})
