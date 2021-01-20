// @ts-check

/**
 * @type {import('vitepress').UserConfig}
 */
module.exports = {
  title: 'Vite ⚡ Rails',
  description: 'Bringing joy to your frontend experience',
  head: [
    [
      'style',
      {},
      'img { border-radius: 10px }' + 'h1.title { margin-left: 0.5em }'
    ]
  ],
  themeConfig: {
    repo: 'ElMassimo/vite_rails',
    docsDir: 'docs',
    docsBranch: 'main',
    editLinks: true,
    editLinkText: 'Suggest changes to this page',

    nav: [
      { text: 'Guide', link: '/guide/' },
      { text: 'Config Reference', link: '/config/' },
      {
        text: 'Changelog',
        link:
          'https://github.com/ElMassimo/vite_rails/blob/main/CHANGELOG.md'
      }
    ],

    sidebar: {
      '/config/': 'auto',
      // catch-all fallback
      '/': [
        {
          text: 'Guide',
          children: [
            {
              text: 'Introduction',
              link: '/guide/introduction'
            },
            {
              text: 'Getting Started',
              link: '/guide/'
            },
          ]
        },
      ]
    }
  }
}
