import { resolve, join } from 'path'
import type { ConfigEnv, Plugin, UserConfig, ViteDevServer } from 'vite'
import createDebugger from 'debug'

import { cleanConfig, configOptionFromEnv } from './utils'
import { loadConfiguration, resolveEntrypointsForRollup } from './config'
import { assetsManifestPlugin } from './manifest'

export * from './types'

// Public: The resolved project root.
export const projectRoot = configOptionFromEnv('root') || process.cwd()

// Internal: The resolved source code dir.
let codeRoot: string

// Public: Vite Plugin to detect entrypoints in a Ruby app, and allows to load
// a shared JSON configuration file that can be read from Ruby.
export default function ViteRubyPlugin (): Plugin[] {
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
function config (config: UserConfig, env: ConfigEnv | undefined): UserConfig {
  const viteMode = env?.mode || config.mode || 'development' // Fallback just in case someone is using < beta.69
  const { assetsDir, base, outDir, mode, host, https, port, root, sourceCodeDir } = loadConfiguration(viteMode, projectRoot)

  const entrypoints = Object.fromEntries(resolveEntrypointsForRollup(root!))

  const server = { host, https, port, strictPort: true }

  const build = {
    assetsDir,
    emptyOutDir: false,
    outDir,
    manifest: true,
    rollupOptions: { input: entrypoints },
    sourcemap: mode !== 'development',
  }

  debug({ base, build, root, server, entrypoints })

  codeRoot = resolve(join(projectRoot, sourceCodeDir!))

  const alias = { '~/': `${codeRoot}/`, '@/': `${codeRoot}/` }

  return cleanConfig({
    resolve: { alias },
    base,
    root,
    server,
    build,
    optimizeDeps: {
      exclude: ['vite-plugin-ruby'],
    },
  })
}

// Internal: Allows to watch the entire source code dir, not just entrypoints
// which is the root for Vite.
function configureServer (server: ViteDevServer) {
  server.watcher.add(`${codeRoot}/**/*`)
}
