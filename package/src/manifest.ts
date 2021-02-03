import path from 'path'
import createDebugger from 'debug'

import type { Plugin, ResolvedConfig } from 'vite'

import { isObject, isString } from './utils'

const debug = createDebugger('vite-plugin-ruby:assets-manifest')
const fingerprintRegex = /\.(\w|\d){8,}\./

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
  let assetsPrefix: string
  let entries: Set<string>

  return {
    name: 'vite-plugin-ruby:assets-manifest',
    apply: 'build',
    enforce: 'post',
    configResolved(resolvedConfig: ResolvedConfig) {
      assetsPrefix = `${resolvedConfig.build.assetsDir}/`
      entries = new Set(getEntrypoints(resolvedConfig))
    },
    generateBundle({ format }, bundle) {
      const manifest: AssetsManifest = {}

      Object.values(bundle).forEach((chunk) => {
        const name = chunk.name || chunk.fileName.replace(assetsPrefix, '').replace(fingerprintRegex, '.')
        if (chunk.type === 'asset' && entries.has(name))
          manifest[name] = { file: chunk.fileName, src: name }
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
