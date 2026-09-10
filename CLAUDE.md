# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Academic personal website for Juan F. Tellez built with Quarto. Hosted on Netlify at https://juanftellez.com/. Source on GitHub at `hail2thief/juan-quarto`.

## Build Commands

```bash
scripts/update_site.sh          # pull pubs from Google Sheet, render everything, publish
scripts/update_site.sh --no-pub # same, but stop before publishing
quarto render                   # full build (outputs to _site/)
quarto preview                  # local dev server with live reload
quarto publish netlify          # deploy to Netlify
```

**Always do a full `quarto render` after touching `html/custom.scss`.** Per-file renders leave other pages pointing at a stale content-hashed CSS file, so navbars and fonts stop matching.

## Directory Structure

- `blog/` — Blog posts (technical posts, yearly "Year in Content" roundups, R package showcase)
- `courses/grad/`, `courses/undergrad/`, `courses/software/` — Pages used by the teaching listing
- `courses/logos/` — Header images for course pages
- `files/` — Downloadable files and the syllabus CSL (`files/bib/`)
- `html/custom.scss` — All custom styling
- `images/` — Site images
- `personal_files/` — Local data snapshots and pull scripts (mostly gitignored)
- `scripts/` — `update_site.sh`
- `_extensions/` — Quarto extensions (Font Awesome)
- `_freeze/` — Cached R execution output (committed to repo)
- `_site/`, `.quarto/` — Build output (gitignored)

## Architecture

### Research page (data-driven)
- `research.qmd` reads `personal_files/pubs.csv`, a local snapshot of the "pubs" tab in the CV Google Sheet. It does **not** read the sheet live, so renders need no network or Google auth.
- Refresh the snapshot with `Rscript personal_files/pull_pubs.R` (or `scripts/update_site.sh`). `pubs.csv` and `pull_pubs.R` are gitignored.
- CSV columns: `category` (`working_paper`, `peer_reviewed`, `book_chapter`, `report`), `summary` (abstract), `title`, `author`, `journal`, `pub_date`, `year`, `url`, `country`.
- `country` holds two-letter ISO codes (`CO`, `ET`; comma-separate several). Blank means cross-national and shows a globe. Flags appear on working papers and peer-reviewed only, via the flag-icons CSS loaded from cdnjs. Code-to-name lookup is the `country_names` vector in the setup chunk; add new countries there. If the column is missing from the CSV, `get_pubs()` adds it as NA.
- All three sections go through one R helper, `render_pub(pubs, group_by_year, show_flag, show_venue)`. Peer-reviewed and other writing are grouped under year headers (newest first); working papers are a flat list. Styling lives in the CSS block in the page's YAML header (`.pub`, `.pub-year`, `.pub-flag`, `.pub-meta`). Change the look there, not in the R code.
- Linked titles are the only link to a paper (no separate PDF button). "JF Tellez" is bolded in author lists.
- `clean_summary()` converts LaTeX in abstracts (`\textit{}`, `\emph{}`, `\textbf{}`, `\%`) to HTML. Pandoc silently drops raw LaTeX in HTML output, so abstracts pasted from papers need this.

### Frozen execution
- `execute: freeze: true` in `_quarto.yml` (not `auto`). A page's R code only re-runs when you delete its cache: `rm -rf _freeze/<path>`.
- `scripts/update_site.sh` clears `_freeze/research` automatically.

### Blog
- `blog.qmd` is the listing page; posts live in `blog/*.qmd`.
- "Year in Content" posts (`blog/content_*.qmd`) load `personal_files/goodreads_clean.rds` and `letterboxd_clean.rds` directly. Regenerate those with `personal_files/clean_letterboxd_goodreads.R`.
- Monthly book-review posts were removed on purpose in 2026. Do not regenerate them.
- Draft posts use `draft: true`; they render but stay out of listings.

### Teaching
- `teaching.qmd` uses three Quarto listings (`undergrad`, `grad`, `software`) that read `courses/<dir>/*.qmd`.
- Course YAML: `title`, `subtitle: "Taught: W23, S24"` (short quarter codes: F = fall, W = winter, S = spring, two-digit year), `categories`, `date`.
- Course pages reference bib and CSL files by absolute path. If the Dropbox path moves, those break.

### Styling
- `html/custom.scss` (Bootstrap 5 based). Fonts: Fraunces for headings, navbar, TOC, footer; Source Sans 3 for body. Both load from Google Fonts via `$web-font-path`.
- `$link-color` (body links, `#1A5DAD`) is deliberately separate from `$blue` (navbar, TOC). Keep them decoupled.
- Components scoped by class: `.blog`, `.research`, `.teaching`, `.course-entry`.

### Extensions
- Font Awesome via `_extensions/quarto-ext/fontawesome/`; use shortcodes like `{{< fa brands github >}}`. Inside R output, use `fontawesome::fa()` instead.

## Blog Post Conventions

- Setup chunk uses `theme_nice()` helper, `MoMAColors::moma.colors("VanGogh")` palette, and `kableExtra` for tables
- Code-heavy posts use `echo: true`; data-driven posts use `echo: false` with `code-fold: true`
- Use `#|` style chunk options
- Posts that run R rely on `_freeze/`; delete the post's freeze dir to force re-execution

## R Dependencies

- `googlesheets4` — used only by `personal_files/pull_pubs.R`
- `juanr` — teaching datasets (`blog/juanr.qmd`); `remotes::install_github("hail2thief/juanr")`
- `MoMAColors` — palettes in blog posts
- `fontawesome`, `htmltools` — research page (globe icon, link helpers)
- A bibliography file is referenced from an external path (`master.bib`); it is not in this repo

## Key Files

- `_quarto.yml` — main config (navbar, footer, theme)
- `_publish.yml` — Netlify site id
- `html/custom.scss` — all custom styling
- `research.qmd` — publications page and `render_pub()`
- `scripts/update_site.sh` — one-command refresh and publish
