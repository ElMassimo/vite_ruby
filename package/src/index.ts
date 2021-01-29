import { resolve, join } from 'path'
import type { Plugin, UserConfig } from 'vite'
import createDebugger from 'debug'

import { cleanConfig, configOptionFromEnv } from './utils'
import { loadConfiguration, resolveEntrypoints } from './config'
import { assetsManifestPlugin } from './manifest'

export * from './types'

const projectRoot = configOptionFromEnv('root') || process.cwd()

export {
  projectRoot,
  loadConfiguration,
  resolveEntrypoints,
}

const debug = createDebugger('vite-plugin-ruby:config')

function config(config: UserConfig): UserConfig {
  const { assetsDir, base, outDir, mode, host, https, port, root, sourceCodeDir } = loadConfiguration(config, projectRoot)

  const entrypoints = resolveEntrypoints(root!, projectRoot)

  const server = { host, https, port, strictPort: true }

  const build = {
    assetsDir,
    emptyOutDir: false,
    outDir,
    manifest: true,
    rollupOptions: { input: entrypoints },
    sourcemap: mode !== 'development',
  }

  debug({ base, build, root, server })

  return cleanConfig({
    alias: {
      '~/': `${resolve(join(projectRoot, sourceCodeDir!))}/`,
    },
    base,
    root,
    server,
    build,
    optimizeDeps: {
      exclude: ['vite-plugin-ruby'],
    },
  })
}

// Public: Vite Plugin to detect entrypoints in a Ruby app, and allows to load
// a shared JSON configuration file that can be read from Ruby.
export default function ViteRubyPlugin(): Plugin[] {
  return [
    {
      name: 'vite-plugin-ruby',
      config,
    },
    assetsManifestPlugin(),
  ]
}
