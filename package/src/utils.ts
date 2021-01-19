import { readFileSync } from 'fs'
import { ENV_PREFIX } from './constants'

// Internal: Simplistic version that gets the job done for this scenario.
// Example: screamCase('buildOutputDir') === 'build_output_dir'
export function screamCase (key: string) {
  return key.replace(/([a-z])([A-Z])/g, '$1_$2').toUpperCase()
}

// Internal: Returns a configuration option that was provided using env vars.
export function configOptionFromEnv (optionName: string) {
  return process.env[`${ENV_PREFIX}_${screamCase(optionName)}`]
}

// Internal: Ensures it's easy to turn off a setting with env vars.
export function booleanOption (value: string | boolean | undefined): boolean | undefined {
  return value === true || value === 'true' || (value === undefined ? undefined : false)
}

// Internal: Returns the filename without the extension.
export function withoutExtension (filename: string) {
  return filename.substr(0, filename.lastIndexOf('.'))
}

// Internal: Loads a json configuration file.
export function loadJsonConfig<T>(filepath: string): T {
  return JSON.parse(readFileSync(filepath, { encoding: 'utf8', flag: 'r' })) as T
}

// Internal: Removes any keys with undefined or null values from the object.
export function cleanConfig (object: Record<any, any>) {
  for (const key in object) {
    const value = object[key]
    if (value === undefined || value === null) delete object[key]
    else if (typeof value === 'object') cleanConfig(value)
  }
  return object
}
