## Context

The app already has a local `BookLibraryStore`, a `BookmarksView` sheet, and an
AppIcon asset catalog. Book deletion already uses both swipe and long-press
context menu affordances in `LibraryView`, which gives a local SwiftUI pattern
to mirror for bookmark deletion.

## Decisions

- Add `onDeleteBookmark` to `BookmarksView` instead of giving the view direct
  persistence access. This keeps persistence owned by `ReaderView` and
  `BookLibraryStore`.
- Add `BookLibraryStore.deleteBookmark(bookID:wordIndex:)` rather than calling
  `toggleBookmark` from delete UI. Delete actions should be explicit and
  idempotent.
- Keep the bookmarks sheet open after deleting a bookmark. If no bookmarks
  remain, the sheet naturally renders its empty state.
- Store the app display name through existing generated Info.plist project
  settings.
- Generate all icon sizes from one 1024px master so the asset catalog remains
  complete for iPhone, iPad, and marketing.

## Risks

- SwiftData delete by bookmark ID alone could remove the wrong item if future
  data migration creates duplicate IDs. The delete method scopes by book ID and
  word index, matching the current bookmark uniqueness model.
- Cyrillic display names require UTF-8 project file support. The project is
  already UTF-8, and Xcode supports generated Info.plist display name keys.
