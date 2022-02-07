/// <reference types="vitepress/client" />
/// <reference types="vue/macros-global" />

declare module '@mussi/vitepress-theme/config' {
  import { UserConfig } from 'vitepress'
  const config: () => Promise<UserConfig>
  export default config
}

declare module '@mussi/vitepress-theme/highlight' {
  const createHighlighter: () => Promise<(input: string) => string>
  export default createHighlighter
}
