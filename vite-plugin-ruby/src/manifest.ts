import path from 'path'
import { promises as fsp } from 'fs'
import { createHash } from 'crypto'
import createDebugger from 'debug'

import type { Plugin, ResolvedConfig } from 'vite'

import { OutputBundle, PluginContext } from 'rollup'
import { resolveEntrypointAssets } from './config'

const debug = createDebugger('vite-plugin-ruby:assets-manifest')

interface AssetsManifestChunk {
  src?: string
  file: string
}

type AssetsManifest = Map<string, AssetsManifestChunk>

function getAssetHash (content: Buffer) {
  return createHash('sha256').update(content).digest('hex').slice(0, 8)
}

// Internal: Writes a manifest file that allows to map an entrypoint asset file
// name to the corresponding output file name.
export function assetsManifestPlugin (): Plugin {
  let config: ResolvedConfig

  // Internal: For stylesheets Vite does not output the result to the manifest,
  // so we extract the file name of the processed asset from the bundle.
  function extractChunkAssets (bundle: OutputBundle, manifest: AssetsManifest) {
    const entrypointFiles = Object.values(config.build.rollupOptions.input as Record<string, string>)
    const assetFiles = new Set(entrypointFiles.map(file => path.relative(config.root, file)))

    Object.values(bundle).filter(chunk => chunk.type === 'asset' && assetFiles.has(chunk.name!))
      .forEach((chunk) => { manifest.set(chunk.name!, { file: chunk.fileName, src: chunk.name }) })
  }

  // Internal: Vite ignores some entrypoint assets, so we need to manually
  // fingerprint the files and move them to the output directory.
  async function fingerprintRemainingAssets (ctx: PluginContext, manifest: AssetsManifest) {
    const remainingAssets = resolveEntrypointAssets(config.root)

    for (const [filename, absoluteFilename] of remainingAssets) {
      const content = await fsp.readFile(absoluteFilename)
      const hash = getAssetHash(content)

      const ext = path.extname(filename)
      const filenameWithoutExt = filename.slice(0, -ext.length)
      const hashedFilename = path.posix.join(config.build.assetsDir, `${filenameWithoutExt}.${hash}${ext}`)

      manifest.set(filename, { file: hashedFilename, src: filename })
      ctx.emitFile({ fileName: hashedFilename, type: 'asset', source: content })
    }
  }

  return {
    name: 'vite-plugin-ruby:assets-manifest',
    apply: 'build',
    enforce: 'post',
    configResolved (resolvedConfig: ResolvedConfig) {
      config = resolvedConfig
    },
    async generateBundle (_options, bundle) {
      const manifest: AssetsManifest = new Map()
      extractChunkAssets(bundle, manifest)
      await fingerprintRemainingAssets(this, manifest)
      debug({ manifest })

      this.emitFile({
        fileName: 'manifest-assets.json',
        type: 'asset',
        source: JSON.stringify(Object.fromEntries(manifest), null, 2),
      })
    },
  }
}
