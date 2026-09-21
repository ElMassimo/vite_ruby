import { basename, posix, relative, resolve } from 'path'
import { existsSync, readFileSync } from 'fs'
import { createLogger } from 'vite'
import type { ConfigEnv, Logger, PluginOption, UserConfig, ViteDevServer } from 'vite'
import { createDebug } from 'obug'

import { cleanConfig, configOptionFromEnv, slash } from './utils'
import { filterEntrypointsForRollup, loadConfiguration, resolveGlobs } from './config'
import { assetsManifestPlugin } from './manifest'
import { bindDevServerCleanup, resolveDevServerMeta, writeDevServerMeta } from './dev-server'
import { DEV_SERVER_META_FILE } from './constants'

export * from './types'

export interface PreRenderedAsset {
  type: 'asset'
  name?: string // Vite v7, deprecated
  names?: string[] // Vite v8
  originalFileName?: string // Vite v7, deprecated
  originalFileNames?: string[] // Vite v8
  source: string | Uint8Array
}

// Public: The resolved project root.
export const projectRoot = configOptionFromEnv('root') || process.cwd()

// Internal: Additional paths to watch.
let watchAdditionalPaths: string[] = []

// Public: Vite Plugin to detect entrypoints in a Ruby app, and allows to load a shared JSON configuration file that can be read from Ruby.
export default function ViteRubyPlugin (): PluginOption[] {
  return [
    {
      name: 'vite-plugin-ruby',
      config,
      configureServer,
    },
    assetsManifestPlugin(),
  ]
}

const debug = createDebug('vite-plugin-ruby:config')

// Internal: Resolves the configuration from environment variables and a JSON
// config file, and configures the entrypoints and manifest generation.
function config (userConfig: UserConfig, env: ConfigEnv): UserConfig {
  const config = loadConfiguration(env.mode, projectRoot, userConfig)
  const { assetsDir, base, outDir, server, root, entrypoints, ssrBuild } = config

  const isLocal = config.mode === 'development' || config.mode === 'test'
  const customLogger = env.command === 'build'
    ? buildOutputLogger(userConfig, root, outDir)
    : userConfig.customLogger

  const rollupOptions = userConfig.build?.rollupOptions
  let rollupInput = rollupOptions?.input

  // Normalize any entrypoints provided by plugins.
  if (typeof rollupInput === 'string')
    rollupInput = { [rollupInput]: rollupInput }

  // Detect if we're using rolldown
  // @ts-ignore - Vite plugin context provides meta information from 7 onwards.
  const isUsingRolldown = this && this.meta && this.meta.rolldownVersion
  const optionsKey = isUsingRolldown ? 'rolldownOptions' : 'rollupOptions'

  const build = {
    emptyOutDir: userConfig.build?.emptyOutDir ?? (ssrBuild || isLocal),
    sourcemap: !isLocal,
    ...userConfig.build,
    assetsDir,
    manifest: !ssrBuild,
    outDir,
    // Clear rollupOptions when using rolldown, since ...userConfig.build may have spread it in.
    ...(isUsingRolldown && { rollupOptions: undefined }),
    [optionsKey]: {
      ...rollupOptions,
      input: {
        ...rollupInput,
        ...Object.fromEntries(filterEntrypointsForRollup(entrypoints)),
      },
      output: {
        ...outputOptions(assetsDir, ssrBuild),
        ...rollupOptions?.output,
      },
    },
  }

  const envDir = userConfig.envDir || projectRoot

  debug({ base, build, envDir, root, server, entrypoints: Object.fromEntries(entrypoints) })

  watchAdditionalPaths = resolveGlobs(projectRoot, root, config.watchAdditionalPaths || [])

  const alias = { '~/': `${root}/`, '@/': `${root}/` }

  return cleanConfig({
    resolve: { alias },
    base,
    customLogger,
    envDir,
    root,
    server,
    build,
    viteRuby: config,
  })
}

// Internal: Displays build output paths relative to the Ruby project root instead of Vite's nested root.
function buildOutputLogger (userConfig: UserConfig, root: string, outDir: string): Logger {
  const logger = userConfig.customLogger || createLogger(userConfig.logLevel, { allowClearScreen: userConfig.clearScreen })
  const viteOutputDir = slash(outDir)
  const projectOutputDir = slash(relative(projectRoot, resolve(root, outDir)))
  const outputPathPattern = new RegExp(`^((?:\\x1B\\[[0-?]*[ -/]*[@-~])*)${escapeRegExp(viteOutputDir)}(?=/|$)`)

  return new Proxy(logger, {
    get (target, property) {
      if (property === 'info') {
        return (message: string, options?: Parameters<Logger['info']>[1]) => {
          target.info(message.replace(outputPathPattern, `$1${projectOutputDir}`), options)
        }
      }

      const value = Reflect.get(target, property, target)
      return typeof value === 'function' ? value.bind(target) : value
    },
  })
}

function escapeRegExp (value: string): string {
  return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
}

// Internal: Allows to watch additional paths outside the source code dir.
function configureServer (server: ViteDevServer) {
  server.watcher.add(watchAdditionalPaths)

  const devServerMetaPath = resolve(projectRoot, DEV_SERVER_META_FILE)
  server.httpServer?.once('listening', () => {
    writeDevServerMeta(devServerMetaPath, resolveDevServerMeta(server.httpServer?.address(), server.config))
    bindDevServerCleanup(devServerMetaPath)
  })

  return () => server.middlewares.use((req, res, next) => {
    if (req.url === '/index.html' && !existsSync(resolve(server.config.root, 'index.html'))) {
      res.statusCode = 404
      const file = readFileSync(resolve(__dirname, 'dev-server-index.html'), 'utf-8')
      res.end(file)
    }

    next()
  })
}

function outputOptions (assetsDir: string, ssrBuild: boolean) {
  // Internal: Avoid nesting entrypoints unnecessarily.
  const outputFileName = (ext: string) => (asset: PreRenderedAsset) => {
    // Vite v8 uses `names`, earlier versions use `name`
    const resolvedName = asset.names?.[0] ?? asset.name ?? '[name]'
    const shortName = basename(resolvedName).split('.')[0]
    return posix.join(assetsDir, `${shortName}-[hash].${ext}`)
  }

  return {
    assetFileNames: ssrBuild ? undefined : outputFileName('[ext]'),
    entryFileNames: ssrBuild ? undefined : outputFileName('js'),
  }
}
