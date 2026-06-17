## Why

Reader needs final lightweight branding and bookmark management polish before
daily use on iPhone. The empty-library default text should introduce RSVP in
Russian, the app should be named `Быстрочиталка`, and the selected app icon
should replace the placeholder icon. Users also need to remove saved bookmarks
directly from the bookmarks sheet.

## What Changes

- Replace the default no-book text with the provided Russian RSVP explanation.
- Set the iOS display name to `Быстрочиталка`.
- Replace AppIcon images with the approved warm graphite/paper RSVP icon.
- Add bookmark deletion from the bookmarks sheet using row swipe actions and
  long-press context menu.

## Impact

- `Reader/App/ReaderView.swift`: update default text and wire bookmark deletion.
- `Reader/App/BookmarksView.swift`: add destructive delete affordances.
- `Reader/Domain/BookLibraryStore.swift`: add explicit bookmark deletion.
- `Reader.xcodeproj/project.pbxproj`: update generated display name settings.
- `Reader/Assets.xcassets/AppIcon.appiconset/`: regenerate icon PNGs.
- `ReaderCoreTests/` and `ReaderTests/`: cover source wiring and domain delete.
