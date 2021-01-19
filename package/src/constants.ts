// Internal: Inferred mode, since Vite doesn't yet expose it to its plugins.
export const APP_ENV = process.env.RAILS_ENV || process.env.RACK_ENV || process.env.APP_ENV || 'development'

// Internal: Prefix used for environment variables that modify the configuration.
export const ENV_PREFIX = 'VITE_RUBY'

// Internal: Key of the vite.json file that is applied to all environments.
export const ALL_ENVS_KEY = 'all'