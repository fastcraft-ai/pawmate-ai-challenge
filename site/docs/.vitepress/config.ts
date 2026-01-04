import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'PawMate AI Challenge',
  description: 'Benchmark AI coding assistants with a reproducible, standardized workflow',
  base: '/pawmate-ai-challenge/',
  
  head: [
    ['link', { rel: 'icon', href: '/favicon.ico' }],
    ['meta', { name: 'theme-color', content: '#3eaf7c' }],
    ['meta', { name: 'og:type', content: 'website' }],
    ['meta', { name: 'og:locale', content: 'en' }],
    ['meta', { name: 'og:site_name', content: 'PawMate AI Challenge' }],
  ],

  themeConfig: {
    logo: '/logo.png',
    
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Getting Started', link: '/getting-started' },
      { text: 'Run Benchmark', link: '/run-benchmark' },
      { text: 'Submit Results', link: '/submit-results' },
      { 
        text: 'More',
        items: [
          { text: 'FAQ', link: '/faq' },
          { text: 'CLI Reference', link: '/cli-reference' },
          { text: 'Profiles', link: '/profiles' },
          { text: 'Rules & Spec', link: '/rules' },
          { text: 'View Results', link: '/results' }
        ]
      }
    ],

    sidebar: [
      {
        text: 'Getting Started',
        items: [
          { text: 'Overview', link: '/' },
          { text: 'Installation', link: '/getting-started' },
          { text: 'Your First Run', link: '/run-benchmark' }
        ]
      },
      {
        text: 'Running Benchmarks',
        items: [
          { text: 'Workflow', link: '/run-benchmark' },
          { text: 'Profiles Explained', link: '/profiles' },
          { text: 'Rules & Spec', link: '/rules' }
        ]
      },
      {
        text: 'Results',
        items: [
          { text: 'Submit Results', link: '/submit-results' },
          { text: 'View Leaderboard', link: '/results' }
        ]
      },
      {
        text: 'Reference',
        items: [
          { text: 'CLI Commands', link: '/cli-reference' },
          { text: 'FAQ', link: '/faq' },
          { text: 'Contributing', link: '/contributing' }
        ]
      }
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/rsdickerson/pawmate-ai-challenge' },
      { icon: 'npm', link: 'https://www.npmjs.com/package/pawmate-ai-challenge' }
    ],

    footer: {
      message: 'Released under the MIT License.',
      copyright: 'Copyright © 2024-present PawMate AI Challenge'
    },

    search: {
      provider: 'local'
    },

    editLink: {
      pattern: 'https://github.com/rsdickerson/pawmate-site/edit/main/docs/:path',
      text: 'Edit this page on GitHub'
    }
  }
})

