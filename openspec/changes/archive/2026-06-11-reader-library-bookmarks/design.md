## Context

The current app has a native RSVP domain and SwiftUI reader UI, but persistence
is centered on one `SavedReadingSessionRecord`. Importing content replaces the
active reading text, and the save/resume flow only restores one global session.

The new behavior turns Reader into a local multi-book reader. Imported content
must become a stored book immediately, and each book needs independent progress,
settings, and bookmarks.

Constraints:

- Keep RSVP parsing, timing, and settings in `Reader/Domain`.
- Keep SwiftData as the local persistence mechanism.
- Preserve existing text/PDF/EPUB extraction behavior.
- Keep the UI compact and readable on iPhone screens.
- Preserve existing user/Xcode signing changes in the project file.

## Goals / Non-Goals

**Goals:**

- Persist multiple local books.
- Open any stored book from a library screen.
- Automatically add paste/PDF/EPUB imports as books and open them.
- Persist progress and settings per book.
- Add a reader bookmark button and per-book bookmark list.
- Launch into the last-opened book when available.

**Non-Goals:**

- No cloud sync.
- No EPUB table of contents or renderer.
- No folders/tags/search in the first library pass.
- No automatic duplicate-content detection.
- No migration UI. Old single-session data is migrated automatically into the
  library on launch.

## Decisions

### Replace one global session with stored books

Add SwiftData records for books and bookmarks:

- `StoredBookRecord`: stable UUID, title, source kind, full text, word count,
  current word index, encoded `ReaderSettings`, added/opened timestamps.
- `StoredBookmarkRecord`: stable UUID, owning book id, word index, preview text,
  created timestamp.

The alternative was to keep `SavedReadingSessionRecord` and add a parallel
library table, but that would duplicate progress state and keep two different
resume concepts alive. A direct book model is clearer and matches the product.

### Keep a testable domain-facing store API

Introduce `BookLibraryStore` plus small domain snapshots/actions:

- `LibraryBookSnapshot`
- `BookmarkSnapshot`
- `BookSourceKind`
- create book from imported text
- load/list/delete/open books
- update progress/settings
- toggle/list/delete bookmarks

SwiftUI views should use snapshots, not SwiftData model objects directly. This
keeps tests focused and avoids SwiftUI depending on persistence internals.

### Import flow creates and opens books

`LoadContentView` continues to extract text and returns normalized text plus
metadata. `ReaderView` will ask the library store to create a book, then restore
the `ReadingSession` from the returned book snapshot. Pasted text gets a default
title from its first words; file imports use the source file name.

### Reader owns active book state

`ReaderView` keeps `activeBookID` and the current `ReadingSession`. Before
opening another book, presenting the library, backgrounding, or changing
settings/position, it saves the current session back to the active book. This
keeps the existing RSVP session logic intact while persistence becomes per-book.

### Bookmark toggle is position-based

The bookmark button toggles the current word index for the active book and lives
below the speed controls, close to the repeated reading actions. It uses the
same visual size as the primary play button so it reads as a first-class reading
action. If a bookmark exists at that position, tapping removes it; otherwise it
creates one. This prevents duplicates and gives the button a predictable state.

### Launch behavior

On launch, the app opens the most recently opened book if one exists. If the
library is empty, it shows the default reader state with load/library actions
available. The old resume prompt is removed from the normal flow.

### Legacy saved sessions migrate into the library

Some installed builds already contain a `SavedReadingSessionRecord`. On launch,
the app reads that legacy record before choosing the last-opened library book.
If a stored book has the same text, the migration updates that book's position
and settings without duplicating it. If no matching book exists, the migration
creates a `Recovered Session` book. After a successful migration, the legacy
record is cleared so future launches use only the library model.

## Risks / Trade-offs

- SwiftData relationship migration could be noisy while unshipped -> keep the
  new model simple and include all model types in the app container at once.
- Saving progress on every minor change could be expensive for large text ->
  save on meaningful actions and lifecycle transitions rather than every
  playback tick.
- Library UI can crowd the existing reader header -> use icon buttons with
  accessibility labels and sheets, matching existing controls.
- Old single-session records may remain on developer devices -> launch migrates
  the latest record into the library before opening a book.

## Migration Plan

1. Add domain snapshots, source kind, and tests.
2. Add SwiftData book/bookmark records and store tests.
3. Update app model container to include the new records.
4. Update import/load flow to create and open books.
5. Add library and bookmark UI.
6. Add legacy single-session migration into the new library model.
7. Update old persistence tests/source guards for per-book persistence.
8. Run package tests, Xcode simulator tests, and simulator build.

Rollback while unshipped is to revert the change and return to the archived
single-session implementation.

## Open Questions

None for the first pass. The user selected automatic import-to-library behavior.
