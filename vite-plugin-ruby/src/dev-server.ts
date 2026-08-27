import { mkdirSync, readFileSync, rmSync, writeFileSync } from 'fs'
import { dirname } from 'path'
import type { AddressInfo } from 'net'
import type { ResolvedConfig } from 'vite'

// Internal: Metadata written to disk so Ruby can detect the running dev server.
export interface DevServerMeta {
  url: string
  host: string
  port: number
  https: boolean
  pid: number
}

// Internal: Hosts that a browser can not connect to and must be replaced.
const WILDCARD_HOSTS = new Set(['', '0.0.0.0', '::', '::1'])

let exitHandlersBound = false
let ownedMetaPath: string | null = null

// Internal: Returns true when the address is a resolved TCP address.
function isAddressInfo (address: string | AddressInfo | null | undefined): address is AddressInfo {
  return Boolean(address) && typeof address === 'object'
}

// Internal: Resolves the address a browser should use to reach the dev server.
export function resolveDevServerMeta (address: string | AddressInfo | null | undefined, config: ResolvedConfig): DevServerMeta {
  const https = Boolean(config.server.https)
  const protocol = https ? 'https' : 'http'
  const bound = isAddressInfo(address) ? address : undefined

  let host = typeof config.server.host === 'string' ? config.server.host : ''
  if (WILDCARD_HOSTS.has(host)) host = 'localhost'

  const port = bound?.port ?? config.server.port ?? 0
  const url = `${protocol}://${host.includes(':') ? `[${host}]` : host}:${port}`

  return { url, host, port, https, pid: process.pid }
}

// Internal: Writes the dev server metadata file, creating the directory if needed.
export function writeDevServerMeta (path: string, meta: DevServerMeta): void {
  mkdirSync(dirname(path), { recursive: true })
  writeFileSync(path, JSON.stringify(meta))
}

// Internal: Removes the metadata file only when this process owns it.
export function removeOwnedMeta (path: string, pid: number = process.pid): void {
  let ownerPid: unknown
  try {
    ownerPid = JSON.parse(readFileSync(path, 'utf8')).pid
  }
  catch {
    return
  }
  if (ownerPid === pid) rmSync(path, { force: true })
}

// Internal: Ensures the metadata file is removed when the dev server stops.
export function bindDevServerCleanup (path: string): void {
  ownedMetaPath = path
  if (exitHandlersBound) return

  exitHandlersBound = true
  const cleanup = () => { if (ownedMetaPath) removeOwnedMeta(ownedMetaPath) }
  process.on('exit', cleanup)
  process.on('SIGINT', () => process.exit())
  process.on('SIGTERM', () => process.exit())
  process.on('SIGHUP', () => process.exit())
  process.on('uncaughtException', (error) => {
    cleanup()
    throw error
  })
}
