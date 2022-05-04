/// <reference types="vite/client" />
/// <reference types="vue/macros-global" />

interface ImportMeta {
  globEagerDefault(pattern: string): Record<string, any>
}
