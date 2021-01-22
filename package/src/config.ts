import { basename, join, relative, resolve } from 'path'
import { UserConfig } from 'vite'
import glob from 'fast-glob'

import { APP_ENV, ALL_ENVS_KEY } from './constants'
import { booleanOption, loadJsonConfig, configOptionFromEnv, withoutExtension } from './utils'
import { Config, UnifiedConfig, MultiEnvConfig, Entrypoints } from './types'

// Internal: Default configuration that is also read from Ruby.
const defaultConfig: Config = loadJsonConfig(resolve(__dirname, '../default.vite.json'))

// Internal: Returns the entrypoints defined in the Ruby application.
export function resolveEntrypoints(entrypointsDir: string, projectRoot: string): Entrypoints {
  const entrypoints: Entrypoints = {}
  glob.sync(`${entrypointsDir}/**/*`, { onlyFiles: true, cwd: projectRoot })
    .forEach((filename) => {
      entrypoints[withoutExtension(basename(filename))] = filename// resolve(__dirname, filename)
    })
  return entrypoints
}

// Internal: Loads configuration options provided through env variables.
function configFromEnv(): Config {
  const envConfig: Record<string, any> = {}
  Object.keys(defaultConfig).forEach((optionName) => {
    const envValue = configOptionFromEnv(optionName)
    if (envValue !== undefined) envConfig[optionName] = envValue
  })
  return envConfig
}

// Internal: Allows to load configuration from a json file, and VITE_RUBY
// prefixed environment variables.
export function loadConfiguration(currentConfig: UserConfig, projectRoot: string): UnifiedConfig {
  const envConfig = configFromEnv()
  const mode = envConfig.mode || currentConfig.mode || APP_ENV
  const filePath = join(projectRoot, envConfig.configPath || (defaultConfig.configPath as string))
  const multiEnvConfig = loadJsonConfig<MultiEnvConfig>(filePath)
  const fileConfig: Config = { ...multiEnvConfig[ALL_ENVS_KEY], ...multiEnvConfig[mode] }

  // Combine the three possible sources: env > json file > defaults.
  const config: UnifiedConfig = { ...defaultConfig, ...fileConfig, ...envConfig, mode }

  // Coerce the values to the expected types.
  config.port = parseInt(config.port as unknown as string)
  config.https = booleanOption(config.https)

  // Ensure Vite places HTML files in public with the proper dir structure.
  const buildOutputDir = join(config.publicDir!, config.publicOutputDir!)
  config.root = join(projectRoot, config.sourceCodeDir!, config.entrypointsDir!)
  config.outDir = relative(config.root!, buildOutputDir) // Vite expects it to be relative
  config.base = `/${config.publicOutputDir!}`

  return config
}
