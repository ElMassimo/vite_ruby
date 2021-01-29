import path from 'path'
import createDebugger from 'debug'

import type { Plugin, ResolvedConfig } from 'vite'

import { isObject, isString } from './utils'

const debug = createDebugger('vite-plugin-ruby:assets-manifest')

interface AssetsManifestChunk {
  src?: string
  file: string
}

type AssetsManifest = Record<string, AssetsManifestChunk>

// Internal: Resolves the entrypoint files configured by the main plugin.
function getEntrypoints(config: ResolvedConfig): string[] {
  const buildInput = config.build.rollupOptions.input
  const resolvePath = (p: string) => path.relative(config.root, path.resolve(config.root, p))

  if (isString(buildInput)) return [resolvePath(buildInput)]
  if (Array.isArray(buildInput)) return buildInput.map(resolvePath)
  if (isObject(buildInput)) return Object.values(buildInput).map(resolvePath)

  throw new Error(`invalid rollupOptions.input value.\n${buildInput}`)
}

// Internal: Writes a manifest file that allows to map an entrypoint asset file
// name to the corresponding output file name.
export function assetsManifestPlugin(): Plugin {
  let entries: Set<string>

  return {
    name: 'vite-plugin-ruby:assets-manifest',
    apply: 'build',
    enforce: 'post',
    configResolved(resolvedConfig: ResolvedConfig) {
      entries = new Set(getEntrypoints(resolvedConfig))
    },
    generateBundle({ format }, bundle) {
      const manifest: AssetsManifest = {}

      Object.values(bundle).forEach((chunk) => {
        if (chunk.type === 'asset' && entries.has(chunk.name!))
          manifest[chunk.name!] = { file: chunk.fileName, src: chunk.name }
      })

      debug(manifest)

      this.emitFile({
        fileName: 'manifest-assets.json',
        type: 'asset',
        source: JSON.stringify(manifest, null, 2),
      })
    },
  }
}
