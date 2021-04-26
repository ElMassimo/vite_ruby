// Internal: Inferred mode, since Vite doesn't yet expose it to its plugins.
export const APP_ENV = process.env.RAILS_ENV || process.env.RACK_ENV || process.env.APP_ENV

// Internal: Prefix used for environment variables that modify the configuration.
export const ENV_PREFIX = 'VITE_RUBY'

// Internal: Key of the vite.json file that is applied to all environments.
export const ALL_ENVS_KEY = 'all'

// Internal: Extensions of CSS files or known precompilers.
export const KNOWN_CSS_EXTENSIONS = [
  'css',
  'less',
  'sass',
  'scss',
  'styl',
  'stylus',
  'pcss',
  'postcss',
]

// Internal: Types of files that Vite should process correctly as entrypoints.
export const KNOWN_ENTRYPOINT_TYPES = [
  'html',
  'jsx?',
  'tsx?',
  ...KNOWN_CSS_EXTENSIONS,
]

export const CSS_EXTENSIONS_REGEX = new RegExp(
  `\\.(${KNOWN_CSS_EXTENSIONS.join('|')})$`,
)

export const ENTRYPOINT_TYPES_REGEX = new RegExp(
  `\\.(${KNOWN_ENTRYPOINT_TYPES.join('|')})(\\?.*)?$`,
)
