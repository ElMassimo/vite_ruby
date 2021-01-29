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

function getEntrypoints(config: ResolvedConfig): string[] {
  const buildInput = config.build.rollupOptions.input
  const resolvePath = (p: string) => path.relative(config.root, path.resolve(config.root, p))

  if (isString(buildInput)) return [resolvePath(buildInput)]
  if (Array.isArray(buildInput)) return buildInput.map(resolvePath)
  if (isObject(buildInput)) return Object.values(buildInput).map(resolvePath)

  throw new Error(`invalid rollupOptions.input value.\n${buildInput}`)
}

export function assetsManifestPlugin(): Plugin {
  let config: ResolvedConfig

  return {
    name: 'vite-plugin-ruby:assets-manifest',
    apply: 'build',
    enforce: 'post',
    configResolved(resolvedConfig: ResolvedConfig) {
      config = resolvedConfig
    },
    generateBundle({ format }, bundle) {
      const manifest: AssetsManifest = {}
      const entries = new Set(getEntrypoints(config))

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
