import baseConfig from '@mussi/vitepress-theme/config'

import { defineConfigWithTheme, HeadConfig, UserConfig } from 'vitepress'
import type { Config } from '@mussi/vitepress-theme'
import { NavItem, SidebarConfig } from '@mussi/vitepress-theme/src/vitepress/config'

const isProd = process.env.NODE_ENV === 'production'

const title = 'Vite ⚡ Ruby'
const description = 'Bringing joy to your frontend experience'
const site = isProd ? 'https://vite-ruby.netlify.app' : 'http://localhost:3005'
const image = `${site}/banner.png`

const head: HeadConfig = [
  ['style', {}, 'img { border-radius: 10px }' + 'h1.title { margin-left: 0.5em }'],
  ['meta', { name: 'author', content: 'Máximo Mussini' }],
  ['meta', { name: 'keywords', content: 'rails, vitejs, vue, react, vite, ruby' }],

  ['link', { rel: 'icon', type: 'image/svg+xml', href: '/favicon.svg' }],

  ['meta', { name: 'HandheldFriendly', content: 'True' }],
  ['meta', { name: 'MobileOptimized', content: '320' }],
  ['meta', { name: 'theme-color', content: '#cc0000' }],

  ['meta', { name: 'twitter:card', content: 'summary_large_image' }],
  ['meta', { name: 'twitter:site', content: site }],
  ['meta', { name: 'twitter:description', value: description }],
  ['meta', { name: 'twitter:image', content: image }],
  ['meta', { name: 'twitter:creator', content: '@maximomussini' }],

  ['meta', { property: 'og:type', content: 'website' }],
  ['meta', { property: 'og:locale', content: 'en_US' }],
  ['meta', { property: 'og:site', content: site }],
  ['meta', { property: 'og:site_name', content: title }],
  ['meta', { property: 'og:image', content: image }],
  ['meta', { property: 'og:description', content: description }],
]

if (isProd)
  head.push(['script', { src: 'https://unpkg.com/thesemetrics@latest', async: '' }])

const nav: NavItem[] = [
  { text: 'Guide', link: '/guide/' },
  { text: 'Config', link: '/config/' },
  {
    text: 'Links',
    items: [
      {
        text: 'Documentation',
        items: [
          { text: 'Vite', link: 'https://vitejs.dev/' },
        ],
      },
      {
        text: 'Changelogs',
        items: [
          { text: 'vite-plugin-ruby', link: 'https://github.com/ElMassimo/vite_ruby/blob/main/vite-plugin-ruby/CHANGELOG.md' },
          { text: 'Vite Ruby', link: 'https://github.com/ElMassimo/vite_ruby/blob/main/vite_ruby/CHANGELOG.md' },
          { text: 'Vite Rails', link: 'https://github.com/ElMassimo/vite_ruby/blob/main/vite_rails/CHANGELOG.md' },
          { text: 'Vite Hanami', link: 'https://github.com/ElMassimo/vite_ruby/blob/main/vite_hanami/CHANGELOG.md' },
          { text: 'Vite Padrino', link: 'https://github.com/ElMassimo/vite_ruby/blob/main/vite_padrino/CHANGELOG.md' },
        ],
      },
    ],
  },
]

const sidebar: SidebarConfig = {
  // '/config/': 'auto',
  // catch-all fallback
  '/': [
    {
      text: 'Guide',
      items: [
        { text: 'Introduction', link: '/guide/introduction' },
        { text: 'Getting Started', link: '/guide/' },
        { text: 'Development', link: '/guide/development' },
        { text: 'Deployment', link: '/guide/deployment' },
        { text: 'Migration', link: '/guide/migration' },
        { text: 'Plugins', link: '/guide/plugins' },
        { text: 'Advanced', link: '/guide/advanced' },
      ],
    },
    {
      text: 'Integrations',
      items: [
        { text: 'Rails', link: '/guide/rails' },
        { text: 'Hanami', link: '/guide/hanami' },
        { text: 'Padrino', link: '/guide/padrino' },
        { text: 'Plugin Legacy', link: '/guide/plugin-legacy' },
      ],
    },
    {
      text: 'FAQs',
      items: [
        { text: 'Troubleshooting', link: '/guide/troubleshooting' },
        { text: 'Motivation', link: '/motivation' },
        { text: 'Overview', link: '/overview' },
        { text: 'Debugging', link: '/guide/debugging' },
        { text: 'Migrating to Vite 3', link: '/guide/migrating-to-vite-3' },
      ],
    },
    {
      text: 'Config',
      items: [
        { text: 'Configuration', link: '/config/' },
      ],
    },
  ],
}

export default defineConfigWithTheme<Config>({
  extends: baseConfig as () => UserConfig<Config>,
  title: 'Vite Ruby',
  head,
  description,
  lang: 'en-US',
  scrollOffset: 'header',
  srcDir: 'src',
  themeConfig: {
    logo: '/logo.svg',
    author: {
      name: 'Maximo Mussini',
      link: 'https://maximomussini.com',
    },
    algolia: {
      appId: 'GERZE019PN',
      apiKey: 'cdb4a3df8ecf73fadf6bde873fc1b0d2',
      indexName: 'vite_rails',
    },
    nav,
    sidebar,
    socialLinks: [
      { icon: 'github', link: 'https://github.com/ElMassimo/vite_ruby' },
      { icon: 'twitter', link: 'https://twitter.com/MaximoMussini' },
      { icon: 'discord', link: 'https://discord.gg/9sSq53jxb4' },
    ],
    footer: {
      license: {
        text: 'MIT License',
        link: 'https://opensource.org/licenses/MIT',
      },
      copyright: 'Copyright © 2021',
    },
  },
  vite: {
    optimizeDeps: {
      exclude: ['@mussi/vitepress-theme'],
    },
  },
})
