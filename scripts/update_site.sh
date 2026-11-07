#!/usr/bin/env bash
# update_site.sh ------------------------------------------------------------
# One-command refresh of juanftellez.com.
#
#   scripts/update_site.sh            # pull pubs, render, publish to Netlify
#   scripts/update_site.sh --no-pub   # everything except the final publish
#   scripts/update_site.sh --skip-pull  # don't re-download the Google Sheet
#
# Steps:
#   1. Pull the "pubs" tab of the CV Google Sheet into personal_files/pubs.csv
#   2. Clear the research page's freeze cache so its R code re-runs
#   3. Full `quarto render` (full, not per-file, so every page shares the
#      same content-hashed CSS -- per-file renders leave stale navbars)
#   4. `quarto publish netlify`
#
# Run it from anywhere; it cd's to the site root on its own.
set -euo pipefail

SITE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SITE_ROOT"

PULL=1
PUBLISH=1
for arg in "$@"; do
  case "$arg" in
    --skip-pull) PULL=0 ;;
    --no-pub)    PUBLISH=0 ;;
    -h|--help)   sed -n '2,17p' "$0"; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

if [[ $PULL -eq 1 ]]; then
  echo "==> Pulling publications from the CV Google Sheet"
  Rscript personal_files/pull_pubs.R
  echo "==> Changes to pubs.csv vs last commit (if tracked) / previous snapshot:"
  git diff --stat -- personal_files/pubs.csv || true
fi

echo "==> Clearing research freeze cache so it re-executes"
rm -rf _freeze/research

# Dropbox must NOT sync _site/ or .quarto/ while Quarto writes them, or it
# keeps the old file and shunts the fresh render into a "conflicted copy"
# (which would then get published). This Dropbox runs through macOS File
# Provider (~/Library/CloudStorage), which only honors the
# com.apple.fileprovider.ignore#P attribute; com.dropbox.ignored is the
# legacy-Dropbox flag and is kept as a harmless fallback. Re-apply both in
# case the dirs were recreated.
for d in _site .quarto; do
  mkdir -p "$d"
  xattr -w 'com.apple.fileprovider.ignore#P' 1 "$d"
  xattr -w com.dropbox.ignored 1 "$d"
done

echo "==> Rendering the whole site"
quarto render

# Belt and braces: refuse to publish a build that contains conflicted copies.
# Dropbox can create them a few seconds AFTER the render ends, so wait first.
sleep 20
n_conflicts=$(find _site -name "*conflicted copy*" | wc -l | tr -d ' ')
if [[ "$n_conflicts" -gt 0 ]]; then
  echo "!! Found $n_conflicts Dropbox conflicted-copy files in _site/. Delete them and re-run." >&2
  find _site -name "*conflicted copy*" >&2
  exit 1
fi

if [[ $PUBLISH -eq 1 ]]; then
  echo "==> Publishing to Netlify"
  # --no-render: we just rendered and checked the build; publish that exact one
  quarto publish netlify --no-prompt --no-browser --no-render
  echo "==> Live at https://juanftellez.com"
else
  echo "==> Skipped publish (--no-pub). Preview with: quarto preview"
fi
