# PawMate AI Challenge Documentation Site

This directory contains the VitePress documentation website for the PawMate AI Challenge.

## Quick Start

```bash
# Install dependencies
cd site
npm install

# Start dev server (http://localhost:5173)
npm run docs:dev

# Build for production
npm run docs:build

# Preview production build
npm run docs:preview
```

## Site Location

**Repository:** Part of `pawmate-ai-challenge` repository  
**Directory:** `/site/`  
**Live URL:** https://fastcraft-ai.github.io/pawmate-ai-challenge/

## Structure

```
site/
├── docs/
│   ├── .vitepress/config.ts    # VitePress configuration
│   ├── public/                 # Static assets
│   ├── index.md                # Landing page
│   ├── getting-started.md      # Installation guide
│   ├── run-benchmark.md        # Workflow documentation
│   ├── submit-results.md       # Submission guide
│   ├── profiles.md             # Profile explanations
│   ├── faq.md                  # FAQ
│   ├── cli-reference.md        # CLI commands
│   ├── rules.md                # Rules & spec
│   ├── results.md              # Leaderboard info
│   └── contributing.md         # Contributing guide
├── package.json
└── README.md                   # This file
```

## Deployment

The site automatically deploys to GitHub Pages when changes are pushed to the `site/` directory.

**GitHub Actions Workflow:** `../.github/workflows/deploy-site.yml`

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed deployment instructions.

## Updating Content

1. Edit markdown files in `docs/`
2. Test locally: `npm run docs:dev`
3. Commit and push changes
4. Site auto-deploys via GitHub Actions

## Configuration

The base URL is set for GitHub Pages:

```typescript
// docs/.vitepress/config.ts
base: '/pawmate-ai-challenge/'
```

Change to `base: '/'` if using a custom domain.

## Contributing

To contribute to the documentation:
1. Edit relevant `.md` files in `docs/`
2. Follow the existing style and structure
3. Test locally before committing
4. Submit a pull request

## License

MIT - Same as the main PawMate AI Challenge project
