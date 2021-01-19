export interface Config {
  assetsDir?: string
  configPath?: string
  publicDir?: string
  mode?: string
  entrypointsDir?: string
  sourceCodeDir?: string
  host?: string
  https?: boolean
  port?: number
  publicOutputDir?: string
}

export interface PluginOptions {
  root?: string
  outDir?: string
  base?: string
}

export type UnifiedConfig = Config & PluginOptions

// Public: Such as a vite.json configuration file.
export type MultiEnvConfig = Record<string, Config | undefined>

export type Entrypoints = Record<string, string>
