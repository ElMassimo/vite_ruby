import path from 'path'
import { promises as fsp } from 'fs'
import { createDebug } from 'obug'

import type { Plugin, ResolvedConfig } from 'vite'

import type { OutputBundle, OutputAsset, PluginContext } from 'rollup'
import { UnifiedConfig } from './types'
import { filterEntrypointAssets } from './config'
import { slash } from './utils'

const debug = createDebug('vite-plugin-ruby:assets-manifest')

interface AssetsManifestChunk {
  src?: string
  file: string
}

type AssetsManifest = Map<string, AssetsManifestChunk>

// Internal: Older Rollup types don't know about the `names`/`originalFileNames`
// arrays introduced for Vite v8, so we widen the shape locally instead of
// bumping the (type-only) `rollup` dependency.
type EmittedOutputAsset = OutputAsset & { originalFileNames?: string[] }

// Internal: Finds an asset that Vite's own build pipeline already emitted for
// this exact source file (e.g. because it's also imported from JS/CSS, or
// referenced from an HTML entrypoint), so we can reuse its hashed file name.
//
// Emitting the same file a second time isn't safe to assume idempotent: two
// independent `emitFile` calls for byte-identical content aren't guaranteed to
// resolve to the same hash (this differs between Rollup and Rolldown), and
// when they don't, only one of the two hashed files actually ends up on disk.
// Reusing the existing entry sidesteps the mismatch entirely, and also avoids
// writing the same asset to disk twice.
function findExistingAsset (bundle: OutputBundle, root: string, absoluteFilename: string): string | undefined {
  const normalizedFilename = slash(absoluteFilename)

  // Rollup documents `originalFileNames` as absolute paths, but Rolldown (Vite
  // v8's default bundler) can report them relative to `config.root` instead.
  const resolveOriginalFileName = (fileName: string) =>
    slash(path.isAbsolute(fileName) ? fileName : path.resolve(root, fileName))

  for (const chunk of Object.values(bundle)) {
    if (chunk.type !== 'asset') continue

    const asset = chunk as EmittedOutputAsset
    const originalFileNames = asset.originalFileNames ?? (asset.originalFileName ? [asset.originalFileName] : [])
    if (originalFileNames.some(fileName => resolveOriginalFileName(fileName) === normalizedFilename)) return asset.fileName
  }
}

// Internal: Writes a manifest file that allows to map an entrypoint asset file
// name to the corresponding output file name.
export function assetsManifestPlugin (): Plugin {
  let config: ResolvedConfig
  let viteRubyConfig: UnifiedConfig

  // Internal: Vite ignores some entrypoint assets, so we need to manually
  // fingerprint the files and move them to the output directory.
  async function fingerprintRemainingAssets (ctx: PluginContext, bundle: OutputBundle, manifest: AssetsManifest) {
    const remainingAssets = filterEntrypointAssets(viteRubyConfig.entrypoints)

    for (const [filename, absoluteFilename] of remainingAssets) {
      const hashedFilename = findExistingAsset(bundle, config.root, absoluteFilename) ?? await emitAsset(ctx, filename, absoluteFilename)
      manifest.set(path.relative(config.root, absoluteFilename), { file: hashedFilename, src: filename })
    }
  }

  async function emitAsset (ctx: PluginContext, filename: string, absoluteFilename: string) {
    const content = await fsp.readFile(absoluteFilename)
    const ref = ctx.emitFile({ name: path.basename(filename), type: 'asset', source: content })
    return ctx.getFileName(ref)
  }

  return {
    name: 'vite-plugin-ruby:assets-manifest',
    apply: 'build',
    enforce: 'post',
    configResolved (resolvedConfig: ResolvedConfig) {
      config = resolvedConfig
      viteRubyConfig = (config as any).viteRuby
    },
    async generateBundle (_options, bundle) {
      if (!config.build.manifest) return

      const manifestDir = typeof config.build.manifest === 'string' ? path.dirname(config.build.manifest) : '.vite'
      const fileName = `${manifestDir}/manifest-assets.json`

      const manifest: AssetsManifest = new Map()
      await fingerprintRemainingAssets(this, bundle, manifest)
      debug({ manifest, fileName })

      this.emitFile({
        fileName,
        type: 'asset',
        source: JSON.stringify(Object.fromEntries(manifest), null, 2),
      })
    },
  }
}
