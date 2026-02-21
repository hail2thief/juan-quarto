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

## Directory Structure

- `blog/` — Blog posts (policy briefs, technical posts, yearly content roundups, R package showcase)
- `blog/books/` — Individual book reviews
- `courses/grad/` and `courses/undergrad/` — Course pages used by the teaching listing
- `files/` — Downloadable files (CV, etc.)
- `html/` — Custom SCSS styling
- `images/` — Site images
- `_extensions/` — Quarto extensions (Font Awesome)
- `_freeze/` — Cached R execution output (committed to repo)
- `_site/` — Generated static HTML (not committed)

## Architecture

### Data-Driven Content
- **Research page** (`research.qmd`) pulls publication data from Google Sheets via the `googlesheets4` R package
- Publications are maintained in a spreadsheet, not hardcoded in the QMD file

### Frozen Execution
- `execute: freeze: true` in `_quarto.yml` caches R code output
- Change `#| cache.extra:` value in R chunks to force re-execution

### Blog
- `blog.qmd` is the listing page; individual posts live in `blog/*.qmd`
- Posts include policy briefs, technical tutorials, yearly content roundups, and book reviews
- Book reviews live in `blog/books/*.qmd` — each is a standalone post with categories metadata

### Course Listings
- Teaching page uses Quarto listings to auto-generate course cards from `courses/grad/*.qmd` and `courses/undergrad/*.qmd`
- Each course QMD uses consistent YAML metadata for the listing system

### Styling
- Custom theme in `html/custom.scss` (Bootstrap 5 based)
- Components scoped by class: `.blog`, `.research`, `.teaching`, `.course-entry`

### Extensions
- Font Awesome icons via `_extensions/quarto-ext/fontawesome/`
- Use shortcodes like `{{< fa brands github >}}`

## Blog Post Conventions

- Setup chunk uses `theme_nice()` helper, `MoMAColors::moma.colors("VanGogh")` palette, and `kableExtra` for tables
- Code-heavy posts use `echo: true`; data-driven posts use `echo: false` with `code-fold: true` for optional visibility
- Posts that run R code rely on `_freeze/` caching; change `cache.extra` to force re-execution
- Use `#|` style chunk options (not `{r, option = value}` style)
- Draft posts use `draft: true` in YAML front matter — they render but don't appear in listings

### Book Reviews
- Live in `blog/books/*.qmd`
- Minimal YAML: `title`, `date`, `author`, `categories` (always includes `books` plus topic tags)
- No setup chunk needed — plain prose, no R code
- Dates should match the `date_read` column in `personal_files/goodreads_clean.rds`

## R Dependencies

- `googlesheets4` — Pulls publication data from Google Sheets for `research.qmd`
- `juanr` — Juan's teaching datasets package (used in `blog/juanr.qmd`); install via `remotes::install_github("hail2thief/juanr")`
- `MoMAColors` — Color palettes used across blog posts
- A bibliography file is referenced from an external path (`master.bib`); it is not in this repo

## Key Files

- `_quarto.yml` - Main Quarto configuration
- `_publish.yml` - Netlify deployment settings
- `html/custom.scss` - All custom styling
- `chicago-fullnote-bibliography.csl` - Citation format

## Build Artifacts

- `_site/` — Generated static HTML (gitignored)
- `.quarto/` — Quarto metadata (gitignored)
- `_freeze/` — Execution cache (committed to repo so builds don't require re-running R)
