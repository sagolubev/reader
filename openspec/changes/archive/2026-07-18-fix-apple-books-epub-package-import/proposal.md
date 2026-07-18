# Fix Apple Books EPUB Package Import

## Problem

EPUB files exported from Apple Books can appear as `.epub` package directories
instead of ZIP archives. The current EPUB extractor opens every `.epub` URL with
ZIPFoundation, so these package-directory EPUBs fail immediately with the
generic "The EPUB file could not be parsed." error.

## Goals

- Import Apple Books `.epub` package directories using the existing OPF/spine
  extraction path.
- Preserve support for ZIP-based EPUB files.
- Keep import failures explicit for invalid or unreadable EPUBs.

## Non-Goals

- Do not add EPUB rendering, table of contents, DRM handling, or annotations.
- Do not change PDF import behavior or library persistence.
