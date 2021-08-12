import { basename, posix, resolve } from 'path'
import type { ConfigEnv, PluginOption, UserConfig, ViteDevServer } from 'vite'
import createDebugger from 'debug'

import { cleanConfig, configOptionFromEnv } from './utils'
import { loadConfiguration, filterEntrypointsForRollup } from './config'
import { assetsManifestPlugin } from './manifest'
import { UnifiedConfig } from './types'

export * from './types'

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

const debug = createDebugger('vite-plugin-ruby:config')

// Internal: Resolves the configuration from environment variables and a JSON
// config file, and configures the entrypoints and manifest generation.
function config (userConfig: UserConfig, env: ConfigEnv): UserConfig {
  const config = loadConfiguration(env.mode, projectRoot, userConfig)
  const { assetsDir, base, outDir, host, https, port, root, entrypoints } = config

  const fs = { allow: [projectRoot], strict: true }
  const server = { host, https, port, strictPort: true, fs }

  const build = {
    emptyOutDir: true,
    sourcemap: config.mode !== 'development',
    ...userConfig.build,
    assetsDir,
    manifest: true,
    outDir,
    rollupOptions: {
      input: Object.fromEntries(filterEntrypointsForRollup(entrypoints)),
      output: {
        ...outputOptions(config),
        ...userConfig.build?.rollupOptions?.output,
      },
    },
  }

  debug({ base, build, root, server, entrypoints: Object.fromEntries(entrypoints) })

  watchAdditionalPaths = (config.watchAdditionalPaths || []).map(glob => resolve(projectRoot, glob))

  const alias = { '~/': `${root}/`, '@/': `${root}/` }

  return cleanConfig({
    resolve: { alias },
    base,
    root,
    server,
    build,
    viteRuby: config,
  })
}

// Internal: Allows to watch additional paths outside the source code dir.
function configureServer (server: ViteDevServer) {
  server.watcher.add(watchAdditionalPaths)
}

function outputOptions ({ assetsDir, entrypointsDir }: UnifiedConfig) {
  // Internal: Avoid nesting entrypoints unnecessarily.
  const outputFileName = (ext: string) => ({ name }: { name: string }) => {
    const shortName = basename(name).split('.')[0]
    return posix.join(assetsDir, `${shortName}.[hash].${ext}`)
  }

  return {
    entryFileNames: outputFileName('js'),
    chunkFileNames: outputFileName('js'),
    assetFileNames: outputFileName('[ext]'),
  }
}
