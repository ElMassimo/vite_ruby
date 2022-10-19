import { brotliCompressSync } from 'zlib'
import type { PluginOption, Plugin } from 'vite'

import fullReloadPlugin, { type Config as FullReloadConfig } from 'vite-plugin-full-reload'
import manifestSRI, { type Options as SRIOptions } from 'vite-plugin-manifest-sri'
import ruby from 'vite-plugin-ruby'
import environment, { type EnvOptions, type EnvVars } from 'vite-plugin-environment'
import stimulusHMRPlugin, { type Options as StimulusHMROptions } from 'vite-plugin-stimulus-hmr'

import gzipPlugin, { type GzipPluginOptions } from 'rollup-plugin-gzip'

export interface Options {
  /**
   * Whether to create compressed copies of relevant assets.
   *
   * Can use it to turn off `gzip` and `brotli` at once.
   *
   * @default true
   */
  compress?: boolean | {
    /**
     * Whether to create gzip copies of relevant assets.
     * @default true
     */
    gzip?: boolean
    /**
     * Whether to create brotli copies of relevant assets.
     * @default true
     */
    brotli?: boolean
  }

  /**
   * Options for rollup-plugin-gzip, will be used both for brotli and gzip.
   *
   * https://github.com/kryops/rollup-plugin-gzip
   */
  compression?: GzipPluginOptions

  /**
   * Environment variables that should be exposed to the client build.
   *
   * By default, they are exposed under `import.meta.env`.
   *
   * https://github.com/ElMassimo/vite-plugin-environment
   */
  envVars?: EnvVars

  /**
   * Options for vite-plugin-environment.
   *
   * By default, they are exposed under `import.meta.env`.
   *
   * https://github.com/ElMassimo/vite-plugin-environment
   */
  envOptions?: EnvOptions

  /**
   * Options for vite-plugin-manifest-sri.
   *
   * https://github.com/ElMassimo/vite-plugin-manifest-sri
   */
  sri?: false | SRIOptions

  /**
   * Options for vite-plugin-stimulus-hmr.
   *
   * https://github.com/ElMassimo/vite-plugin-stimulus-hmr
   */
  stimulus?: false | StimulusHMROptions

  /**
   * Options for vite-plugin-full-reload.
   *
   * By default it's configured for a standard Rails structure, assuming you
   * would want to automatically reload when modifying views or routes.
   *
   * https://github.com/ElMassimo/vite-plugin-full-reload
   */
  fullReload?: false | FullReloadConfig & {
    additionalPaths?: string | string[]
    overridePaths?: string | string[]
  }
}

/**
 * [defaultReloadPaths description]
 * @type {Array}
 */
const defaultReloadPaths = [
  'config/routes.rb',
  'config/routes/*.rb',
  'app/views/**/*',
]

// Public: Vite Plugin to pre-configure plugins for a typical Rails app.
export default function ViteRubyPlugin (options: Options = {}): PluginOption[] {
  // Compression
  let { compress = true } = options
  if (compress !== false)
    compress = { gzip: true, brotli: true, ...(compress === true ? {} : compress) }

  // Environment
  const envOptions = { defineOn: 'import.meta.env', ...options.envOptions }

  // Full Reload
  const { overridePaths, additionalPaths = [], ...reloadOptions } = options.fullReload || {}
  const reloadPaths = overridePaths || [...defaultReloadPaths, ...wrapArray(additionalPaths)]

  const pluginOptions: PluginOption = [
    // Convention over configuration for Ruby projects using Vite.
    ruby(),

    // Expose environment variables to your client code.
    options.envVars && environment(options.envVars, envOptions),

    // Subresource Integrity for JavaScript and CSS assets.
    options.sri !== false && manifestSRI(options.sri),

    // See changes to your controllers instantly without refreshing the page.
    options.stimulus !== false && stimulusHMRPlugin(options.stimulus),

    // Automatically reload the page when making changes to server files.
    options.fullReload !== false && fullReloadPlugin(reloadPaths, reloadOptions),

    // Create gzip copies of relevant assets.
    compress && compress.gzip && gzipPlugin(options.compression) as PluginOption,

    // Create brotli copies of relevant assets.
    compress && compress.brotli && gzipPlugin({
      ...options.compression,
      customCompression: content => brotliCompressSync(Buffer.from(content)),
      fileName: '.br',
    }) as PluginOption,
  ]

  const plugins = (pluginOptions as Plugin[]).flat(Infinity).filter(plugin => plugin)

  return [...plugins, dupDetector(plugins.map(plugin => plugin.name))]
}

function wrapArray<T> (array: T | T[]): T[] {
  return Array.isArray(array) ? array : [array]
}

// Internal: Allows to detect duplicate plugins.
function dupDetector (originalPluginNames: string[]): Plugin {
  return {
    name: 'vite-plugin-rails:dup-detector',
    configResolved (config) {
      if (config.plugins) {
        const pluginNames = new Set(originalPluginNames)
        pluginNames.delete('gzip') // Can have additional copies.

        const pluginCounts: Record<string, number> = Object.create(null)
        config.plugins.filter(plugin => pluginNames.has(plugin.name)).forEach((plugin) => {
          pluginCounts[plugin.name] = (pluginCounts[plugin.name] || 0) + 1
        })

        const duplicates = Object.entries(pluginCounts)
          .filter(([name, count]) => count > 1).map(([name, count]) => name)

        if (duplicates.length) {
          throw new Error(`
            [vite-plugin-rails] Duplicate plugins detected: ${duplicates.join(', ')}.

            If migrating from vite-plugin-ruby, make sure to remove these manually added
            plugins, and instead pass the options to vite-plugin-rails.
          `)
        }
      }
    },
  }
}
