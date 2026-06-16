## Why

The reader currently behaves like a single-session tool: importing content
replaces the active text and saving stores only one resumable session. The user
now needs a real reader workflow where multiple books can stay in a local
library and each book can have bookmarks.

## What Changes

- Add a persistent local library of books.
- Treat every paste/PDF/EPUB import as adding a new book to the library and
  opening it immediately.
- Persist reading progress and reader settings per book.
- Add a library screen where users can open previously imported books.
- Add a bookmark control in the reader.
- Add per-book bookmarks at word positions with a short preview.
- Replace the single saved-session resume prompt with last-opened book/library
  behavior.

## Capabilities

### New Capabilities

- `reader-library`: Local multi-book library, book metadata, per-book progress,
  settings, and last-opened behavior.
- `reader-bookmarks`: Per-book bookmark creation, removal, listing, and jump
  behavior.

### Modified Capabilities

- `document-import`: Imported pasted text, PDFs, and EPUBs create library books
  and open them instead of only replacing transient active text.
- `native-reader-ui`: Reader UI exposes library navigation and bookmark controls.
- `reader-session-persistence`: Saved progress/settings become per-book library
  state instead of one global saved session.

## Impact

- Adds SwiftData records for books and bookmarks.
- Adds domain/store actions for creating, opening, updating, and deleting local
  books and bookmarks.
- Updates `ReaderView`, launch flow, load flow, header controls, and UI tests.
- Keeps existing RSVP parsing, timing, settings, PDF extraction, and EPUB
  extraction behavior.
