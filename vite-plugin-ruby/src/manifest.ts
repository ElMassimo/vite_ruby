import path from 'path'
import { promises as fsp } from 'fs'
import { createHash } from 'crypto'
import createDebugger from 'debug'

import type { Plugin, ResolvedConfig } from 'vite'

import { OutputBundle, PluginContext } from 'rollup'
import { resolveEntrypointAssets } from './config'
import { CSS_EXTENSIONS_REGEX } from './constants'
import { withoutExtension } from './utils'

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
  // so we extract the file name of the processed asset from the Rollup bundle.
  function extractChunkStylesheets (bundle: OutputBundle, manifest: AssetsManifest) {
    const cssFiles = new Set(
      Object.values(config.build.rollupOptions.input as Record<string, string>)
        .filter(file => CSS_EXTENSIONS_REGEX.test(file))
        .map(file => path.relative(config.root, file)),
    )

    Object.values(bundle).filter(chunk => chunk.type === 'asset' && chunk.name)
      .forEach((chunk) => {
        // NOTE: Rollup appends `.css` to the file so it's removed before matching.
        // See `resolveEntrypointsForRollup`.
        const src = withoutExtension(chunk.name!)
        if (cssFiles.has(src)) manifest.set(src, { file: chunk.fileName, src })
      })
  }

  // Internal: Vite ignores some entrypoint assets, so we need to manually
  // fingerprint the files and move them to the output directory.
  async function fingerprintRemainingAssets (ctx: PluginContext, bundle: OutputBundle, manifest: AssetsManifest) {
    const remainingAssets = resolveEntrypointAssets(config.root)

    for (const [filename, absoluteFilename] of remainingAssets) {
      const content = await fsp.readFile(absoluteFilename)
      const hash = getAssetHash(content)

      const ext = path.extname(filename)
      const filenameWithoutExt = filename.slice(0, -ext.length)
      const hashedFilename = path.posix.join(config.build.assetsDir, `${path.basename(filenameWithoutExt)}.${hash}${ext}`)

      manifest.set(filename, { file: hashedFilename, src: filename })

      // Avoid duplicates if the file was referenced in a different entrypoint.
      if (!bundle[hashedFilename])
        ctx.emitFile({ name: filename, fileName: hashedFilename, type: 'asset', source: content })
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
      extractChunkStylesheets(bundle, manifest)
      await fingerprintRemainingAssets(this, bundle, manifest)
      debug({ manifest })

      this.emitFile({
        fileName: 'manifest-assets.json',
        type: 'asset',
        source: JSON.stringify(Object.fromEntries(manifest), null, 2),
      })
    },
  }
}
