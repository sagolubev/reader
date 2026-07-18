## Why

After replacing the old Load Content flow with direct file selection, EPUB files
selected from the iOS document picker can fail to open on device. The selected
URL is security-scoped, but the reader currently delays starting access until
after an async hop, which can leave EPUB parsing without permission to read the
archive contents.

## What Changes

- Start security-scoped access immediately when a file URL is selected.
- Keep that access active until import parsing and library creation finish.
- Remove the extra async yield before opening the selected file.

## Impact

- `Reader/App/ReaderView.swift`: tighten selected-file import lifetime.
- `ReaderCoreTests/LibraryFlowSourceTests.swift`: guard EPUB file selection
  wiring against delayed security-scoped access.
