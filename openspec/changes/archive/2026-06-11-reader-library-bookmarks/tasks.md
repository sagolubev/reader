## 1. Library Domain Model

- [x] 1.1 Add failing tests for book source kind, book snapshots, title generation, and session restoration
- [x] 1.2 Implement library domain snapshots and helpers
- [x] 1.3 Add failing tests for bookmark preview generation and duplicate-position matching
- [x] 1.4 Implement bookmark snapshots and preview helpers

## 2. SwiftData Library Store

- [x] 2.1 Add failing tests for creating, listing, opening, updating, and deleting books
- [x] 2.2 Implement SwiftData book records and `BookLibraryStore`
- [x] 2.3 Add failing tests for per-book settings/progress persistence
- [x] 2.4 Implement per-book progress and settings updates
- [x] 2.5 Add failing tests for bookmark toggle, listing, jumping data, and book deletion cleanup
- [x] 2.6 Implement SwiftData bookmark records and bookmark actions

## 3. Import And Launch Flow

- [x] 3.1 Add failing tests/source guards for import-to-library behavior
- [x] 3.2 Update load/import flow to create and open books
- [x] 3.3 Add failing tests/source guards for last-opened launch behavior
- [x] 3.4 Replace single-session launch prompt with last-opened book/library behavior
- [x] 3.5 Add failing tests for legacy single-session migration
- [x] 3.6 Migrate old saved session into the library on launch

## 4. Reader UI

- [x] 4.1 Add failing source/UI tests for library button and library list
- [x] 4.2 Implement `LibraryView` and reader library navigation
- [x] 4.3 Add failing source/UI tests for bookmark button, bookmark list, and bookmark jump
- [x] 4.4 Implement bookmark controls, bookmark list, and jump-to-bookmark behavior
- [x] 4.5 Update accessibility identifiers and labels for new controls
- [x] 4.6 Add failing source test for bookmark toggle placement under speed controls
- [x] 4.7 Move bookmark toggle from header to the lower speed-control area
- [x] 4.8 Add failing source test for bookmark toggle primary size
- [x] 4.9 Size bookmark toggle like the primary play control

## 5. Documentation And Verification

- [x] 5.1 Update README and acceptance docs for library and bookmarks
- [x] 5.2 Run `openspec validate reader-library-bookmarks --strict`
- [x] 5.3 Run `swift test`
- [x] 5.4 Run Xcode simulator tests
- [x] 5.5 Run iOS Simulator build
