import { join, relative, resolve, isAbsolute } from 'path'
import glob from 'fast-glob'

import type { UserConfig } from 'vite'
import { APP_ENV, ALL_ENVS_KEY, CSS_EXTENSIONS_REGEX, ENTRYPOINT_TYPES_REGEX } from './constants'
import { booleanOption, loadJsonConfig, configOptionFromEnv, slash } from './utils'
import { Config, ResolvedConfig, UnifiedConfig, MultiEnvConfig, Entrypoints } from './types'

// Internal: Default configuration that is also read from Ruby.
export const defaultConfig: ResolvedConfig = loadJsonConfig(resolve(__dirname, '../default.vite.json'))

// Internal: Returns the files defined in the entrypoints directory that should
// be processed by rollup.
//
// NOTE: For stylesheets the original extension is preserved in the name so that
// the resulting file can be accurately matched later in `extractChunkStylesheets`.
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

// Internal: Returns the style files defined in the entrypoints directory that
// are processed by Rollup but not included in the Vite.js manifest.
export function filterStylesheetAssets (entrypoints: Entrypoints): Entrypoints {
  return entrypoints
    .filter(([_name, filename]) => CSS_EXTENSIONS_REGEX.test(filename))
}

// Internal: Checks if the specified path is inside the specified dir.
function isInside (file: string, dir: string) {
  const path = relative(dir, file)
  return path && !path.startsWith('..') && !isAbsolute(path)
}

// Internal: Returns all files defined in the entrypoints directory.
function resolveEntrypointFiles (projectRoot: string, sourceCodeDir: string, { entrypointsDir, additionalEntrypoints }: ResolvedConfig): Entrypoints {
  const inputGlobs = [`~/${entrypointsDir}/**/*`, ...additionalEntrypoints]
  const resolvedGlobs = resolveGlobs(projectRoot, sourceCodeDir, inputGlobs)
  return glob.sync(resolvedGlobs).map(filename => [
    resolveEntryName(projectRoot, sourceCodeDir, filename),
    filename,
  ])
}

// Internal: All entry names are relative to the sourceCodeDir if inside it, or
// to the project root if outside.
export function resolveEntryName (projectRoot: string, sourceCodeDir: string, file: string) {
  return relative(isInside(file, sourceCodeDir) ? sourceCodeDir : projectRoot, file)
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
export function loadConfiguration (viteMode: string, projectRoot: string, userConfig: UserConfig): UnifiedConfig {
  const envConfig = configFromEnv()
  const mode = envConfig.mode || APP_ENV || viteMode
  const filePath = join(projectRoot, envConfig.configPath || (defaultConfig.configPath as string))
  const multiEnvConfig = loadJsonConfig<MultiEnvConfig>(filePath)
  const fileConfig: Config = { ...multiEnvConfig[ALL_ENVS_KEY], ...multiEnvConfig[mode] }

  // Combine the three possible sources: env > json file > defaults.
  return coerceConfigurationValues({ ...defaultConfig, ...fileConfig, ...envConfig, mode }, projectRoot, userConfig)
}

// Internal: Coerces the configuration values and deals with relative paths.
function coerceConfigurationValues (config: ResolvedConfig, projectRoot: string, userConfig: UserConfig): UnifiedConfig {
  // Coerce the values to the expected types.
  config.port = parseInt(config.port as unknown as string)
  config.https = userConfig.server?.https || booleanOption(config.https)

  // Use the sourceCodeDir as the Vite.js root.
  const root = join(projectRoot, config.sourceCodeDir)

  // Vite expects the outDir to be relative to the root.
  const buildOutputDir = join(config.publicDir, config.publicOutputDir)
  const outDir = relative(root, buildOutputDir) // Vite expects it to be relative

  const base = resolveViteBase(config)
  const entrypoints = resolveEntrypointFiles(projectRoot, root, config)
  return { ...config, root, outDir, base, entrypoints }
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
