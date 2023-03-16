import type { Options } from 'tsup'
export const tsup: Options = {
  clean: true,
  dts: true,
  shims: true,
  sourcemap: true,
  target: 'node12',
  format: ['esm', 'cjs'],
}
