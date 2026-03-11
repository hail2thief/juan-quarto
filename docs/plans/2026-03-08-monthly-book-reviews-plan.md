# Monthly Book Reviews Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace 63 individual book review `.qmd` files with ~39 monthly-grouped posts auto-generated from a Goodreads CSV export.

**Architecture:** An R script reads `personal_files/goodreads.csv`, groups books by month of `Date Read`, converts Goodreads HTML to markdown, and writes one `.qmd` per month to `blog/books/`. It skips months that already have a `.qmd` on disk. Old individual-book `.qmd` files are deleted first.

**Tech Stack:** R (tidyverse, lubridate, stringr, here)

---

### Task 1: Delete old individual book review files

**Files:**
- Delete: all `.qmd` files in `blog/books/` that are NOT named `YYYY-MM.qmd`

**Step 1: Remove old files**

```bash
cd /Users/juan/Library/CloudStorage/Dropbox/websites/juanftellez.com
# List files to be deleted (all current .qmd files in blog/books/)
ls blog/books/*.qmd
# Delete them
rm blog/books/*.qmd
```

**Step 2: Verify directory is empty**

```bash
ls blog/books/
```

Expected: empty directory (or just subdirectories if any)

**Step 3: Commit**

```bash
git add blog/books/
git commit -m "Remove individual book review .qmd files

Replaced by monthly-grouped posts generated from Goodreads CSV."
```

---

### Task 2: Write the R generation script

**Files:**
- Create: `personal_files/generate_book_posts.R`

**Step 1: Write the script**

```r
# generate_book_posts.R
# Reads personal_files/goodreads.csv and generates monthly book review
# posts in blog/books/. Skips months that already have a .qmd on disk.

library(tidyverse)
library(lubridate)
library(here)

# ---- Read and filter data ----
books = read_csv(here("personal_files", "goodreads.csv")) |>
  filter(`Exclusive Shelf` == "read", !is.na(`Date Read`), `Date Read` != "") |>
  mutate(
    date_read = ymd(`Date Read`),
    year_month = floor_date(date_read, "month"),
    month_label = format(year_month, "%B %Y"),           # e.g., "June 2024"
    file_slug = format(year_month, "%Y-%m"),              # e.g., "2024-06"
    # last day of month for the post date
    post_date = ceiling_date(year_month, "month") - days(1),
    post_date_str = format(post_date, "%Y-%m-%d"),
    # star rating
    stars = strrep("\U2B50", as.integer(`My Rating`)),
    # clean review: convert HTML to markdown
    review_clean = `My Review` |>
      str_replace_all("<br/>\\s*<br/>", "\n\n") |>   # double breaks -> paragraphs
      str_replace_all("<br/>", "\n") |>              # single breaks -> newlines
      str_replace_all("</?i>", "*") |>               # <i>text</i> -> *text*
      str_replace_all("</?b>", "**") |>              # <b>text</b> -> **text**
      str_replace_all("<[^>]+>", "") |>              # strip remaining HTML tags
      str_trim()
  ) |>
  arrange(date_read)

# ---- Group by month and generate .qmd files ----
output_dir = here("blog", "books")

books |>
  group_by(file_slug) |>
  group_walk(\(month_books, key) {
    slug = key$file_slug
    filepath = file.path(output_dir, paste0(slug, ".qmd"))

    # skip if file already exists
    if (file.exists(filepath)) {
      message("Skipping ", slug, " (already exists)")
      return()
    }

    # grab metadata from the first row (same for all rows in group)
    month_label = month_books$month_label[1]
    post_date = month_books$post_date_str[1]

    # build YAML front matter
    yaml = paste0(
      "---\n",
      'title: "Books: ', month_label, '"\n',
      'date: "', post_date, '"\n',
      'author: "Juan Tellez"\n',
      "categories:\n",
      "  - books\n",
      "---\n"
    )

    # build body: one section per book
    body = month_books |>
      pmap_chr(\(...) {
        row = list(...)
        header = paste0("## *", row$Title, "* \U2014 ", row$Author, "\n")
        rating = if (row$stars != "") paste0(row$stars, "\n") else ""
        review = if (!is.na(row$review_clean) && row$review_clean != "") {
          paste0("\n", row$review_clean, "\n")
        } else {
          ""
        }
        paste0(header, "\n", rating, review)
      }) |>
      paste(collapse = "\n")

    writeLines(paste0(yaml, "\n", body), filepath)
    message("Generated ", slug)
  })

message("Done!")
```

**Step 2: Commit the script**

```bash
git add personal_files/generate_book_posts.R
git commit -m "Add R script to generate monthly book review posts from Goodreads CSV"
```

---

### Task 3: Run the script and verify output

**Step 1: Run the generation script**

```bash
cd /Users/juan/Library/CloudStorage/Dropbox/websites/juanftellez.com
Rscript personal_files/generate_book_posts.R
```

Expected: messages like "Generated 2024-06", "Generated 2024-08", etc. for ~39 months.

**Step 2: Verify file count and spot-check a file**

```bash
ls blog/books/*.qmd | wc -l
cat blog/books/2024-06.qmd
```

Expected: ~39 files. The June 2024 file should have "Books: June 2024" as title and include "The Wages of Destruction" review.

**Step 3: Commit generated files**

```bash
git add blog/books/
git commit -m "Add monthly book review posts generated from Goodreads CSV"
```

---

### Task 4: Verify site builds and listing works

**Step 1: Render the site**

```bash
quarto render
```

Expected: clean build, no errors. Blog page should show monthly book posts under "Book Reviews."

**Step 2: Spot-check rendered output**

Open `_site/blog.html` and verify:
- Book Reviews section shows monthly posts sorted by date
- A monthly post page (e.g., `_site/blog/books/2024-06.html`) renders with correct formatting, stars, and review text

**Step 3: Final commit if any adjustments needed**
