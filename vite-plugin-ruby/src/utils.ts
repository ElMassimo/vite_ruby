import { readFileSync } from 'fs'

import { ENV_PREFIX } from './constants'

// Internal: Replace Windows-style separators with POSIX-style separators.
export function slash (path: string): string {
  return path.replace(/\\/g, '/')
}

// Internal: Returns true if the specified value is a plain JS object
export function isObject (value: unknown): value is Record<string, any> {
  return Object.prototype.toString.call(value) === '[object Object]'
}

// Internal: Simplistic version that gets the job done for this scenario.
// Example: screamCase('buildOutputDir') === 'BUILD_OUTPUT_DIR'
export function screamCase (key: string) {
  return key.replace(/([a-z])([A-Z])/g, '$1_$2').toUpperCase()
}

// Internal: Returns a configuration option that was provided using env vars.
export function configOptionFromEnv (optionName: string) {
  return process.env[`${ENV_PREFIX}_${screamCase(optionName)}`]
}

// Internal: Ensures it's easy to turn off a setting with env vars.
export function booleanOption<T> (value: 'true' | 'false' | boolean | T): boolean | T {
  if (value === 'true') return true
  if (value === 'false') return false
  return value
}

// Internal: Returns the filename without the last extension.
export function withoutExtension (filename: string) {
  const lastIndex = filename.lastIndexOf('.')
  return lastIndex > -1 ? filename.substr(0, lastIndex) : filename
}

// Internal: Loads a json configuration file.
export function loadJsonConfig<T> (filepath: string): T {
  return JSON.parse(readFileSync(filepath, { encoding: 'utf8', flag: 'r' })) as T
}

// Internal: Removes any keys with undefined or null values from the object.
export function cleanConfig (object: Record<string, any>) {
  Object.keys(object).forEach((key) => {
    const value = object[key]
    if (value === undefined || value === null) delete object[key]
    else if (isObject(value)) cleanConfig(value)
  })
  return object
}
