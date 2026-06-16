## Why

The library currently lets users open and delete books, but adding a new book is only available from the main reader header. Users who are already managing their library need a direct add-book action in that same library surface.

The main reader add/load button still presents the legacy `Load Content` sheet before file selection. The app should use one add-book interaction everywhere: tapping add book opens file selection directly.

## What Changes

- Add an explicit add-book control to the library view.
- Make the control available when the library is empty and when it contains books.
- Tapping the library add-book control opens the system document picker directly
  for file-based books instead of presenting the `Load Content` sheet.
- Tapping the main reader add-book control also opens the system document picker
  directly.
- Remove the legacy `Load Content` sheet and pasted-text loading entry point
  from the app UI.
- Reuse existing PDF and EPUB import behavior after the user picks a file.
- After a successful import, preserve the current behavior: create a persisted library book and open it in the reader.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `reader-library`: The library must expose an add-book action that starts direct file selection for a new book.
- `native-reader-ui`: The main reader surface must expose an add-book action
  that starts direct file selection.
- `document-import`: File imports remain supported; pasted-text loading is no
  longer exposed from the app UI.

## Impact

- `Reader/App/LibraryView.swift`: add the visible add-book control and callback.
- `Reader/App/ReaderHeaderView.swift`: rename the main header action around
  adding a book instead of loading content.
- `Reader/App/ReaderView.swift`: route add-book actions to direct file selection
  and existing file import handling.
- `Reader/App/LoadContentView.swift` and related pasted-text state: remove the
  legacy sheet from the app.
- `ReaderTests/`, `ReaderUITests/`, and `ReaderCoreTests/`: cover the new UI
  wiring/source behavior.
- `openspec/specs/reader-library/spec.md`: receives the archived requirement after implementation.
