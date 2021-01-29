import path from 'path'
import createDebugger from 'debug'

import type { OutputChunk } from 'rollup'
import type { Plugin, ResolvedConfig } from 'vite'

import { normalizePath, isObject, isString } from './utils'

const debug = createDebugger('vite-plugin-ruby:assets-manifest')

interface AssetsManifestChunk {
  src?: string
  file: string
  isEntry?: boolean
}

type AssetsManifest = Record<string, AssetsManifestChunk>

function isEmptyChunk(chunk: OutputChunk): boolean {
  return !chunk.code || (chunk.code.length <= 1 && !chunk.code.trim())
}

function getEntrypoints(config: ResolvedConfig): string[] {
  const buildInput = config.build.rollupOptions.input
  const resolvePath = (p: string) => path.resolve(config.root, p)

  if (isString(buildInput)) return [resolvePath(buildInput)]
  if (Array.isArray(buildInput)) return buildInput.map(resolvePath)
  if (isObject(buildInput)) return Object.values(buildInput).map(resolvePath)

  throw new Error(`invalid rollupOptions.input value.\n${buildInput}`)
}

export function assetsManifestPlugin(): Plugin {
  let config: ResolvedConfig
  const manifest: AssetsManifest = {}

  return {
    name: 'vite-plugin-ruby:assets-manifest',
    apply: 'build',
    enforce: 'post',
    configResolved(resolvedConfig: ResolvedConfig) {
      config = resolvedConfig
    },
    generateBundle({ format }, bundle) {
      const entries = new Set(getEntrypoints(config))

      function getChunkName(chunk: OutputChunk) {
        if (chunk.facadeModuleId) {
          let name = normalizePath(
            path.relative(config.root, chunk.facadeModuleId),
          )
          if (format === 'system' && !chunk.name.includes('-legacy')) {
            const ext = path.extname(name)
            name = `${name.slice(0, -ext.length)}-legacy${ext}`
          }
          return name
        }
        else {
          return `_${path.basename(chunk.fileName)}`
        }
      }

      function replaceFileWithAsset(chunk: OutputChunk) {
        const name = chunk.facadeModuleId ? getChunkName(chunk) : chunk.name
        const asset = Object.values(bundle).find(
          otherChunk => otherChunk.type === 'asset' && otherChunk.name === name,
        )
        debug('replaceFileWithAsset', { name, fileName: asset?.fileName })
        if (asset) chunk.fileName = asset.fileName
        return chunk
      }

      function createChunk(chunk: OutputChunk): AssetsManifestChunk {
        const manifestChunk: AssetsManifestChunk = {
          file: chunk.fileName,
        }

        if (chunk.facadeModuleId)
          manifestChunk.src = getChunkName(chunk)

        if (chunk.isEntry)
          manifestChunk.isEntry = true

        return manifestChunk
      }

      Object.entries(bundle).forEach(([file, chunk]) => {
        if (chunk.type === 'chunk') {
          if (chunk.isEntry) debug('entry', file, chunk.fileName)
          if (isEmptyChunk(chunk)) {
            replaceFileWithAsset(chunk)

            manifest[getChunkName(chunk)] = createChunk(chunk)
          }
        }
        else {
          debug('asset', file, chunk)
        }
      })

      this.emitFile({
        fileName: 'manifest-assets.json',
        type: 'asset',
        source: JSON.stringify(manifest, null, 2),
      })
    },
  }
}
