import path from 'path'
import { promises as fsp } from 'fs'
import createDebugger from 'debug'

import type { Plugin, ResolvedConfig } from 'vite'

import type { OutputBundle, PluginContext } from 'rollup'
import { UnifiedConfig } from './types'
import { filterEntrypointAssets } from './config'

const debug = createDebugger('vite-plugin-ruby:assets-manifest')

interface AssetsManifestChunk {
  src?: string
  file: string
}

type AssetsManifest = Map<string, AssetsManifestChunk>

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
      const content = await fsp.readFile(absoluteFilename)
      const ref = ctx.emitFile({ name: path.basename(filename), type: 'asset', source: content })
      const hashedFilename = ctx.getFileName(ref)
      manifest.set(path.relative(config.root, absoluteFilename), { file: hashedFilename, src: filename })
    }
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
