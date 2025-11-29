# MkDocs Setup Guide

## Quick Start

```bash
# Install dependencies
pip install -r requirements-docs.txt

# Serve locally
mkdocs serve

# Build static site
mkdocs build

# Deploy to GitHub Pages
mkdocs gh-deploy
```

## Local Development

```bash
# Serve with live reload on http://127.0.0.1:8000
mkdocs serve

# Serve on custom port
mkdocs serve -a localhost:8080

# Strict mode (fail on warnings)
mkdocs serve --strict
```

## GitHub Pages Deployment

### Automatic (via GitHub Actions)

Push to `main` branch triggers automatic deployment via `.github/workflows/deploy-docs.yml`

### Manual Deployment

```bash
# Deploy to gh-pages branch
mkdocs gh-deploy --force

# Deploy with custom message
mkdocs gh-deploy -m "Update documentation"
```

## Configuration

- **mkdocs.yml** - Main configuration
- **requirements-docs.txt** - Python dependencies
- **.mkdocs-exclude.yml** - Files to exclude

## Features Enabled

✅ Material theme with dark mode  
✅ Code syntax highlighting  
✅ Mermaid diagrams  
✅ Search functionality  
✅ Git revision dates  
✅ Minified HTML  
✅ Mobile responsive  
✅ Navigation tabs  
✅ Table of contents  

## Customization

### Theme Colors

Edit `mkdocs.yml`:
```yaml
theme:
  palette:
    primary: indigo
    accent: indigo
```

### Navigation

Edit `nav:` section in `mkdocs.yml` to add/remove pages

### Plugins

Add to `plugins:` section in `mkdocs.yml`

## Troubleshooting

### Port already in use
```bash
mkdocs serve -a localhost:8001
```

### Build errors
```bash
mkdocs build --verbose --strict
```

### Clear cache
```bash
rm -rf site/
mkdocs build
```

## GitHub Pages Setup

1. Go to repository Settings → Pages
2. Source: Deploy from a branch
3. Branch: `gh-pages` / `root`
4. Save

Site will be available at: `https://nathanels.github.io/coderbyte-devops-sr-bootcamp`

## Material Theme Documentation

https://squidfunk.github.io/mkdocs-material/
