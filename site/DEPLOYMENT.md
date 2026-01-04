# Deployment Guide

## Initial Setup

### 1. Site Location

The documentation site is located in the `site/` directory of the main repository:
```
pawmate-ai-challenge/site/
```

### 2. Push Changes

```bash
cd /Users/scott.dickerson/source/repos/pawmate/pawmate-ai-challenge
git add site/
git commit -m "Add documentation site"
git push origin main
```

### 3. Enable GitHub Pages

1. Go to repository Settings → Pages
2. Under "Build and deployment":
   - Source: **GitHub Actions**
3. Save

### 4. Base URL Configuration

The site is configured for GitHub Pages at:
```
https://fastcraft-ai.github.io/pawmate-ai-challenge/
```

The `base` is already set in `docs/.vitepress/config.ts`:
```typescript
base: '/pawmate-ai-challenge/',
```

**For a custom domain** (e.g., `pawmate.ai`), change to:
```typescript
base: '/',
```

### 5. Trigger Deployment

Push to `main` branch or manually trigger the workflow:
- Go to Actions tab
- Select "Deploy Documentation"
- Click "Run workflow"

## Custom Domain Setup (Optional)

### 1. Add CNAME File

Create `docs/public/CNAME` with your domain:
```
pawmate.ai
```

Or subdomain:
```
docs.pawmate.ai
```

### 2. Configure DNS

**For apex domain (pawmate.ai):**
Add A records pointing to GitHub Pages IPs:
```
185.199.108.153
185.199.109.153
185.199.110.153
185.199.111.153
```

**For subdomain (docs.pawmate.ai):**
Add CNAME record:
```
CNAME  docs  fastcraft-ai.github.io.
```

### 3. Enable Custom Domain in GitHub

1. Go to Settings → Pages
2. Enter your custom domain
3. Check "Enforce HTTPS" (after DNS propagates)

## Updating the Site

### Content Updates

1. Edit markdown files in `docs/`
2. Commit and push to `main`
3. GitHub Actions automatically rebuilds and deploys

### Configuration Updates

1. Edit `docs/.vitepress/config.ts`
2. Test locally: `npm run docs:dev`
3. Build locally: `npm run docs:build`
4. Commit and push

## Local Development

```bash
# Install dependencies
npm install

# Start dev server (http://localhost:5173)
npm run docs:dev

# Build for production
npm run docs:build

# Preview production build
npm run docs:preview
```

## Maintenance

### Update Dependencies

```bash
npm update
npm audit fix
```

### Monitor Build Status

Check the Actions tab for build/deployment status.

### Analytics (Optional)

Add Google Analytics or similar by editing `docs/.vitepress/config.ts`:

```typescript
head: [
  ['script', { 
    async: true, 
    src: 'https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID' 
  }],
  ['script', {}, `
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());
    gtag('config', 'GA_MEASUREMENT_ID');
  `]
]
```

## Troubleshooting

### Build Fails

Check:
- All markdown files are valid
- Links are correct
- Images exist
- VitePress config is valid

### Pages Don't Update

- Clear browser cache
- Wait 1-2 minutes for CDN propagation
- Check GitHub Actions for deployment status

### Custom Domain Not Working

- Wait up to 48 hours for DNS propagation
- Verify DNS records with `dig pawmate.ai` or `nslookup pawmate.ai`
- Check CNAME file exists and is correct
- Ensure GitHub Pages is enabled

## Site URLs

After deployment, your site will be available at:

**GitHub Pages (default):**
```
https://fastcraft-ai.github.io/pawmate-ai-challenge/
```

**Custom domain (if configured):**
```
https://pawmate.ai
```

## Next Steps

1. **Test the deployed site** - Verify all links work
2. **Update CLI README** - Add link to new docs site
3. **Update npm package** - Add homepage URL
4. **Announce** - Let users know about the new docs

