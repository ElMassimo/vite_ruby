import type { Options } from 'tsup'
export const tsup: Options = {
  clean: true,
  dts: true,
  shims: true,
  target: 'node18',
  format: ['esm', 'cjs'],
}
