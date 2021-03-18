// @ts-check

const isProd = process.env.NODE_ENV === 'production'

const title = 'Vite ⚡ Ruby'
const description = 'Bringing joy to your frontend experience'
const site = isProd ? 'https://vite-ruby.netlify.app' : 'http://localhost:3000'
const image = `${site}/banner.png`

const head = [
  ['style', {}, 'img { border-radius: 10px }' + 'h1.title { margin-left: 0.5em }'],
  ['meta', { name: 'author', content: 'Máximo Mussini' }],
  ['meta', { name: 'keywords', content: 'rails, vitejs, vue, react, vite, ruby' }],

  ['link', { rel: 'icon', type: 'image/svg+xml', href: '/logo.svg' }],

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

/**
 * @type {import('vitepress').UserConfig}
 */
module.exports = {
  title: 'Vite Ruby',
  description,
  head,
  themeConfig: {
    algolia: {
      appId: 'GERZE019PN',
      apiKey: 'cdb4a3df8ecf73fadf6bde873fc1b0d2',
      indexName: 'vite_rails',
    },
    repo: 'ElMassimo/vite_ruby',
    logo: '/logo.svg',
    docsDir: 'docs',
    docsBranch: 'main',
    editLinks: true,
    editLinkText: 'Suggest changes to this page',

    nav: [
      { text: 'Guide', link: '/guide/' },
      { text: 'Config', link: '/config/' },
      { text: 'Vite', link: 'https://vitejs.dev/' },
      {
        text: 'Changelog',
        link: 'https://github.com/ElMassimo/vite_ruby/blob/main/vite_ruby/CHANGELOG.md',
      },
    ],

    sidebar: {
      '/config/': 'auto',
      // catch-all fallback
      '/': [
        {
          text: 'Guide',
          children: [
            { text: 'Introduction', link: '/guide/introduction' },
            { text: 'Getting Started', link: '/guide/' },
            { text: 'Development', link: '/guide/development' },
            { text: 'Deployment', link: '/guide/deployment' },
            { text: 'Migration', link: '/guide/migration' },
          ],
        },
        {
          text: 'Integrations',
          children: [
            { text: 'Rails', link: '/guide/rails' },
            { text: 'Hanami', link: '/guide/hanami' },
            { text: 'Padrino', link: '/guide/padrino' },
            { text: 'Plugin Legacy', link: '/guide/plugin-legacy' },
          ],
        },
        {
          text: 'FAQs',
          children: [
            { text: 'Troubleshooting', link: '/guide/troubleshooting' },
            { text: 'Motivation', link: '/motivation' },
          ],
        },
        {
          text: 'Config',
          link: '/config/',
        },
      ],
    },
  },
}
