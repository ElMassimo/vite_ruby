import { resolve, join } from 'path'
import type { Plugin } from 'vite'
import { cleanConfig, configOptionFromEnv } from './utils'
import { loadConfiguration, resolveEntrypoints } from './config'

export * from './types'

export {
  loadConfiguration,
  resolveEntrypoints,
}

// Public: Vite Plugin to detect entrypoints in a Ruby app, and allows to load
// a shared JSON configuration file that can be read from Ruby.
export default function ViteRubyPlugin(): Plugin {
  return {
    name: 'vite-plugin-ruby',
    config(config) {
      const {
        assetsDir,
        base,
        outDir,
        mode,
        host,
        https,
        port,
        root,
        sourceCodeDir,
      } = loadConfiguration(config)

      const projectRoot = config.root || configOptionFromEnv('root') || process.cwd()
      const entrypoints = resolveEntrypoints(root!, projectRoot)

      return cleanConfig({
        alias: {
          '~/': `${resolve(join(projectRoot, sourceCodeDir!))}/`,
        },

        root,

        optimizeDeps: {
          exclude: [/webpack/, /vite-plugin-ruby/],
        },

        server: {
          host,
          https,
          port,
          strictPort: true,
        },

        build: {
          assetsDir,
          base,
          emptyOutDir: false,
          outDir,
          manifest: true,
          rollupOptions: { input: entrypoints },
          sourcemap: mode !== 'development',
        },
      })
    },
  }
}
