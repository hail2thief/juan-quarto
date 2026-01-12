# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Academic personal website for Juan F. Tellez built with Quarto. The site is hosted on Netlify at https://juanftellez.com/.

## Build Commands

```bash
quarto render          # Build the site (outputs to _site/)
quarto preview         # Local development server with live reload
quarto publish netlify # Deploy to Netlify
```

## Architecture

### Data-Driven Content
- **Research page** (`research.qmd`) pulls publication data from Google Sheets via the `googlesheets4` R package
- Publications are maintained in a spreadsheet, not hardcoded in the QMD file

### Frozen Execution
- `execute: freeze: true` in `_quarto.yml` caches R code output
- Change `#| cache.extra:` value in R chunks to force re-execution

### Course Listings
- Teaching page uses Quarto listings to auto-generate course cards from `courses/grad/*.qmd` and `courses/undergrad/*.qmd`
- Each course QMD uses consistent YAML metadata for the listing system

### Styling
- Custom theme in `html/custom.scss` (Bootstrap 5 based)
- Components scoped by class: `.blog`, `.research`, `.teaching`, `.course-entry`

### Extensions
- Font Awesome icons via `_extensions/quarto-ext/fontawesome/`
- Use shortcodes like `{{< fa brands github >}}`

## Key Files

- `_quarto.yml` - Main Quarto configuration
- `_publish.yml` - Netlify deployment settings
- `html/custom.scss` - All custom styling
- `chicago-fullnote-bibliography.csl` - Citation format

## Build Artifacts (not committed)

- `_site/` - Generated static HTML
- `_freeze/` - Execution cache
- `.quarto/` - Quarto metadata
