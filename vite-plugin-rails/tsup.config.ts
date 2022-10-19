import type { Options } from 'tsup'
export const tsup: Options = {
  clean: true,
  dts: true,
  target: 'node14',
  format: ['esm', 'cjs'],
}
