import { resolve } from 'path'
import { describe, test, expect, vi } from 'vitest'
import type { OutputBundle } from 'rollup'
import { assetsManifestPlugin } from '@plugin/manifest'

describe('assetsManifestPlugin', () => {
  const root = resolve('example/app/frontend')

  function setup (entrypoints: [string, string][]) {
    const plugin = assetsManifestPlugin()

    ;(plugin.configResolved as any)({
      root,
      build: { manifest: true },
      viteRuby: { entrypoints },
    })

    const emitFile = vi.fn(() => 'ref')
    const getFileName = vi.fn(() => 'assets/re-fingerprinted-hash.svg')
    const ctx: any = { emitFile, getFileName }

    return { plugin, ctx, emitFile, getFileName }
  }

  function manifestAssetsSource (emitFile: ReturnType<typeof vi.fn>) {
    const call = emitFile.mock.calls.find(([asset]) => asset.fileName === '.vite/manifest-assets.json')
    return JSON.parse(call![0].source)
  }

  test('reuses an asset Vite already emitted for the same source file, instead of fingerprinting it again', async () => {
    const absoluteFilename = resolve(root, 'images/logo.svg')
    const { plugin, ctx, emitFile, getFileName } = setup([['images/logo.svg', absoluteFilename]])

    // Simulates Vite/Rolldown having already emitted this exact file elsewhere
    // in the bundle (e.g. it's also imported from JS or referenced from HTML).
    const bundle = {
      'assets/logo-existingHash.svg': {
        type: 'asset',
        fileName: 'assets/logo-existingHash.svg',
        originalFileNames: [absoluteFilename],
        source: '',
      },
    } as unknown as OutputBundle

    await (plugin.generateBundle as any).call(ctx, {}, bundle)

    // Re-emitting the same content isn't guaranteed to resolve to the same
    // hash (this can differ between Rollup and Rolldown), so the existing
    // entry must be reused rather than fingerprinted a second time.
    expect(getFileName).not.toHaveBeenCalled()
    expect(manifestAssetsSource(emitFile)).toEqual({
      'images/logo.svg': { file: 'assets/logo-existingHash.svg', src: 'images/logo.svg' },
    })
  })

  test('fingerprints the asset when Vite has not already emitted it elsewhere', async () => {
    const absoluteFilename = resolve(root, 'images/logo.svg')
    const { plugin, ctx, emitFile, getFileName } = setup([['images/logo.svg', absoluteFilename]])

    const bundle = {} as OutputBundle

    await (plugin.generateBundle as any).call(ctx, {}, bundle)

    expect(getFileName).toHaveBeenCalledTimes(1)
    expect(manifestAssetsSource(emitFile)).toEqual({
      'images/logo.svg': { file: 'assets/re-fingerprinted-hash.svg', src: 'images/logo.svg' },
    })
  })

  test('does not match an asset emitted for a different source file', async () => {
    const absoluteFilename = resolve(root, 'images/logo.svg')
    const { plugin, ctx, emitFile, getFileName } = setup([['images/logo.svg', absoluteFilename]])

    const bundle = {
      'assets/other-hash.svg': {
        type: 'asset',
        fileName: 'assets/other-hash.svg',
        originalFileNames: [resolve(root, 'images/other.svg')],
        source: '',
      },
    } as unknown as OutputBundle

    await (plugin.generateBundle as any).call(ctx, {}, bundle)

    expect(getFileName).toHaveBeenCalledTimes(1)
    expect(manifestAssetsSource(emitFile)).toEqual({
      'images/logo.svg': { file: 'assets/re-fingerprinted-hash.svg', src: 'images/logo.svg' },
    })
  })

  test('resolves `originalFileNames` reported relative to config.root (observed with Rolldown)', async () => {
    const absoluteFilename = resolve(root, 'images/logo.svg')
    const { plugin, ctx, emitFile, getFileName } = setup([['images/logo.svg', absoluteFilename]])

    const bundle = {
      'assets/logo-existingHash.svg': {
        type: 'asset',
        fileName: 'assets/logo-existingHash.svg',
        originalFileNames: ['images/logo.svg'],
        source: '',
      },
    } as unknown as OutputBundle

    await (plugin.generateBundle as any).call(ctx, {}, bundle)

    expect(getFileName).not.toHaveBeenCalled()
    expect(manifestAssetsSource(emitFile)).toEqual({
      'images/logo.svg': { file: 'assets/logo-existingHash.svg', src: 'images/logo.svg' },
    })
  })

  test('supports the legacy singular `originalFileName` (pre-Vite-v8 shape)', async () => {
    const absoluteFilename = resolve(root, 'images/logo.svg')
    const { plugin, ctx, emitFile, getFileName } = setup([['images/logo.svg', absoluteFilename]])

    const bundle = {
      'assets/logo-existingHash.svg': {
        type: 'asset',
        fileName: 'assets/logo-existingHash.svg',
        originalFileName: absoluteFilename,
        source: '',
      },
    } as unknown as OutputBundle

    await (plugin.generateBundle as any).call(ctx, {}, bundle)

    expect(getFileName).not.toHaveBeenCalled()
    expect(manifestAssetsSource(emitFile)).toEqual({
      'images/logo.svg': { file: 'assets/logo-existingHash.svg', src: 'images/logo.svg' },
    })
  })
})
