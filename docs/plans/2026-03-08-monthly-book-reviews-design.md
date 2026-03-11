# Monthly Book Reviews Design

## Problem

63 individual `.qmd` files in `blog/books/` are tedious to maintain by hand. Book data already lives in Goodreads, exported to `personal_files/goodreads.csv`.

## Solution

An R script (`personal_files/generate_book_posts.R`) reads the Goodreads CSV and generates one `.qmd` per month in `blog/books/`. Old individual-book `.qmd` files are deleted.

## Data Flow

1. **Input:** `personal_files/goodreads.csv` (96 rows, 24 columns)
2. **Script:** `personal_files/generate_book_posts.R`
3. **Output:** `blog/books/YYYY-MM.qmd` (one per month, ~39 files)
4. **Skip logic:** If a `.qmd` for a given month already exists, skip it (safe to re-run)

## Generated File Format

Filename: `blog/books/YYYY-MM.qmd` (e.g., `2024-06.qmd`)

```markdown
---
title: "Books: June 2024"
date: "2024-06-30"
author: "Juan Tellez"
categories:
  - books
---

## *The Wages of Destruction* — Adam Tooze

⭐⭐⭐⭐⭐

Review text here...

## *Another Book* — Some Author

⭐⭐⭐

More review text...
```

### Conventions

- **Date:** Last day of the month (for listing sort order)
- **Title:** "Books: Month Year"
- **Headings:** `## *Title* — Author`
- **Rating:** Star emoji (⭐) repeated to match `My Rating` (0 = no stars shown)
- **Review text:** Goodreads HTML converted to markdown (double `<br/>` → paragraph breaks, remaining HTML stripped)
- **No review:** Book listed with title/author/stars but no paragraph
- **Sort within month:** By `Date Read`
- **Filters:** Only `Exclusive Shelf == "read"` books with a `Date Read`

## Cleanup

- Delete all old individual-book `.qmd` files from `blog/books/` before generating new monthly files
- Delete corresponding `_freeze/blog/books/` entries for removed files

## Listing Page

`blog.qmd` requires no changes — it already lists `blog/books/*.qmd` sorted by date desc.
