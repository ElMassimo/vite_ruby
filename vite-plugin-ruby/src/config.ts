import { join, relative, resolve } from 'path'
import { globSync } from 'tinyglobby'

import { version as viteVersion } from 'vite'
import type { UserConfig, ServerOptions } from 'vite'
import { APP_ENV, ALL_ENVS_KEY, ENTRYPOINT_TYPES_REGEX } from './constants'
import { booleanOption, isObject, loadJsonConfig, configOptionFromEnv, slash } from './utils'
import { Config, ResolvedConfig, UnifiedConfig, MultiEnvConfig, Entrypoints } from './types'

// Internal: Default configuration that is also read from Ruby.
export const defaultConfig: ResolvedConfig = loadJsonConfig(resolve(__dirname, '../default.vite.json'))

// Internal: Returns the files defined in the entrypoints directory that should
// be processed by rollup.
export function filterEntrypointsForRollup (entrypoints: Entrypoints): Entrypoints {
  return entrypoints
    .filter(([_name, filename]) => ENTRYPOINT_TYPES_REGEX.test(filename))
}

// Internal: Returns the files defined in the entrypoints directory that are not
// processed by Rollup and should be manually fingerprinted and copied over.
export function filterEntrypointAssets (entrypoints: Entrypoints): Entrypoints {
  return entrypoints
    .filter(([_name, filename]) => !ENTRYPOINT_TYPES_REGEX.test(filename))
}

// Internal: Returns all files defined in the entrypoints directory.
export function resolveEntrypointFiles (projectRoot: string, sourceCodeDir: string, config: ResolvedConfig): Entrypoints {
  const inputGlobs = config.ssrBuild
    ? [config.ssrEntrypoint]
    : [`~/${config.entrypointsDir}/**/*`, ...config.additionalEntrypoints]

  const entrypointFiles = globSync(resolveGlobs(projectRoot, sourceCodeDir, inputGlobs), { absolute: true, expandDirectories: false })

  if (config.ssrBuild) {
    if (entrypointFiles.length === 0)
      throw new Error(`No SSR entrypoint available, please create \`${config.ssrEntrypoint}\` to do an SSR build.`)
    else if (entrypointFiles.length > 1)
      throw new Error(`Expected a single SSR entrypoint, found: ${entrypointFiles}`)

    return entrypointFiles.map(file => ['ssr', file])
  }

  return entrypointFiles.map((filename) => {
    let name = relative(sourceCodeDir, filename)
    if (name.startsWith('..'))
      name = relative(projectRoot, filename)

    return [name, filename]
  })
}

// Internal: Allows to use the `~` shorthand in the config globs.
export function resolveGlobs (projectRoot: string, sourceCodeDir: string, patterns: string[]) {
  return patterns.map(pattern =>
    slash(resolve(projectRoot, pattern.replace(/^~\//, `${sourceCodeDir}/`))),
  )
}

// Internal: Loads configuration options provided through env variables.
function configFromEnv (): Config {
  const envConfig: Record<string, any> = {}
  Object.keys(defaultConfig).forEach((optionName) => {
    const envValue = configOptionFromEnv(optionName)
    if (envValue !== undefined) envConfig[optionName] = envValue
  })
  return envConfig
}

// Internal: Allows to load configuration from a json file, and VITE_RUBY
// prefixed environment variables.
export function loadConfiguration (viteMode: string, projectRoot: string, userConfig: UserConfig, version = viteVersion): UnifiedConfig {
  const envConfig = configFromEnv()
  const mode = envConfig.mode || APP_ENV || viteMode
  const filePath = join(projectRoot, envConfig.configPath || (defaultConfig.configPath as string))
  const multiEnvConfig = loadJsonConfig<MultiEnvConfig>(filePath)
  const fileConfig: Config = { ...multiEnvConfig[ALL_ENVS_KEY], ...multiEnvConfig[mode] }

  // Combine the three possible sources: env > json file > defaults.
  return coerceConfigurationValues({ ...defaultConfig, ...fileConfig, ...envConfig, mode }, projectRoot, userConfig, version)
}

// Vite 8.0 types `server.ws` as `false` only; 8.1 reads a transport object.
type ServerWithWsTransport = Omit<ServerOptions, 'ws'> & { ws?: Record<string, unknown> | false }

// Internal: Vite 8.1 renamed the websocket transport options; 8.0 still reads server.hmr.
function viteUsesServerWs (version: string): boolean {
  const [major, minor = 0] = version.split('.').map(part => Number.parseInt(part, 10))
  return major > 8 || (major === 8 && minor >= 1)
}

// Internal: Coerces the configuration values and deals with relative paths.
function coerceConfigurationValues (config: ResolvedConfig, projectRoot: string, userConfig: UserConfig, version: string): UnifiedConfig {
  // Coerce the values to the expected types.
  const port = config.port = parseInt(config.port as unknown as string)
  const https = config.https = userConfig.server?.https || booleanOption(config.https)

  const fs: ServerOptions['fs'] = { allow: [projectRoot], strict: userConfig.server?.fs?.strict ?? true }

  const server: ServerOptions = { fs, host: config.host, https, port, strictPort: true }

  if (booleanOption(config.skipProxy))
    server.origin = userConfig.server?.origin || `${https ? 'https' : 'http'}://${config.host}:${config.port}`

  // Connect directly to the Vite dev server, rack-proxy does not proxy websocket connections.
  // Vite 8.1 moved clientPort from server.hmr to server.ws; 8.0 still reads hmr.
  const ws = userConfig.server?.ws ?? {}
  const hmr = userConfig.server?.hmr ?? {}
  if (isObject(ws) && isObject(hmr) && !ws.hasOwnProperty('clientPort') && !hmr.hasOwnProperty('clientPort')) {
    if (viteUsesServerWs(version))
      (server as ServerWithWsTransport).ws = { ...ws, clientPort: port }
    else
      server.hmr = { ...hmr, clientPort: port }
  }

  // Use the sourceCodeDir as the Vite.js root.
  const root = join(projectRoot, config.sourceCodeDir)

  // Detect SSR builds and entrypoint provided via the --ssr flag.
  const ssrEntrypoint = userConfig.build?.ssr
  config.ssrBuild = Boolean(ssrEntrypoint)
  if (typeof ssrEntrypoint === 'string')
    config.ssrEntrypoint = ssrEntrypoint

  // Vite expects the outDir to be relative to the root.
  const outDir = relative(root, config.ssrBuild
    ? config.ssrOutputDir
    : join(config.publicDir, config.publicOutputDir))

  const base = resolveViteBase(config)
  const entrypoints = resolveEntrypointFiles(projectRoot, root, config)

  return { ...config, server, root, outDir, base, entrypoints }
}

// Internal: Configures Vite's base according to the asset host and publicOutputDir.
export function resolveViteBase ({ assetHost, base, publicOutputDir }: ResolvedConfig) {
  if (assetHost && !assetHost.startsWith('http')) assetHost = `//${assetHost}`

  return [
    ensureTrailingSlash(assetHost || base || '/'),
    publicOutputDir ? ensureTrailingSlash(slash(publicOutputDir)) : '',
  ].join('')
}

function ensureTrailingSlash (path: string) {
  return path.endsWith('/') ? path : `${path}/`
}
