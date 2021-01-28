// @ts-check

const title = 'Vite ⚡ Rails'
const description = 'Bringing joy to your frontend experience'
const image = 'http://vite-rails.netlify.app/social.png'

const head = [
  ['style', {}, 'img { border-radius: 10px }' + 'h1.title { margin-left: 0.5em }'],
  ['meta', { name: 'author', content: 'Máximo Mussini' }],
  ['meta', { name: 'keywords', content: 'rails, vitejs, vue, react, vite, ruby' }],

  ['meta', { name: 'HandheldFriendly', content: 'True' }],
  ['meta', { name: 'MobileOptimized', content: '320' }],
  ['meta', { name: 'theme-color', content: '#cc0000' }],

  ['meta', { property: 'og:type', content: 'website' }],
  ['meta', { property: 'og:locale', content: 'en_US' }],
  ['meta', { property: 'og:site_name', content: title }],
  ['meta', { property: 'og:title', content: title }],
  ['meta', { property: 'og:image', content: image }],
  ['meta', { property: 'og:description', content: description }],

  ['meta', { name: 'twitter:card', content: 'summary_large_image' }],
  ['meta', { name: 'twitter:title', value: title }],
  ['meta', { name: 'twitter:description', value: description }],
  ['meta', { name: 'twitter:image', content: image }],
]

if (process.env.NODE_ENV === 'production') {
  head.push(['script', { src: 'https://unpkg.com/thesemetrics@latest', async: '' }])
}

/**
 * @type {import('vitepress').UserConfig}
 */
module.exports = {
  title,
  description,
  head,
  themeConfig: {
    algolia: {
      appId: 'GERZE019PN',
      apiKey: 'cdb4a3df8ecf73fadf6bde873fc1b0d2',
      indexName: 'vite_rails',
    },
    repo: 'ElMassimo/vite_rails',
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
        link: 'https://github.com/ElMassimo/vite_rails/blob/main/CHANGELOG.md',
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
      ],
    },
  },
}
