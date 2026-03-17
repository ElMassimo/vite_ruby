import { defineConfig } from 'tsdown'

export default defineConfig({
  clean: true,
  dts: true,
  exports: true,
  shims: true,
  format: 'esm',
  target: 'node20',
})
