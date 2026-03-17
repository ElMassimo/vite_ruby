import { defineConfig } from 'tsdown'

export default defineConfig({
  clean: true,
  dts: true,
  sourcemap: true,
  exports: true,
  shims: true,
  format: 'esm',
  target: 'node20',
  copy: ['src/dev-server-index.html'],
})
