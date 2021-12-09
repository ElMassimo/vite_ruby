import type { ServerOptions } from 'vite'

export type HttpsOption = ServerOptions['https']

export interface ResolvedConfig {
  additionalEntrypoints: string[]
  assetHost: string
  assetsDir: string
  configPath: string
  publicDir: string
  mode: string
  entrypointsDir: string
  sourceCodeDir: string
  host: string
  https: HttpsOption
  port: number
  publicOutputDir: string
  watchAdditionalPaths: string[]
  base: string
}

export type Config = Partial<ResolvedConfig>

export interface PluginOptions {
  root: string
  outDir: string
  base: string
}

export type Entrypoints = Array<[string, string]>

export type UnifiedConfig = ResolvedConfig & PluginOptions & { entrypoints: Entrypoints }

// Public: Such as a vite.json configuration file.
export type MultiEnvConfig = Record<string, Config | undefined>
