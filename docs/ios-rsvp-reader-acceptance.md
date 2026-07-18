# iOS RSVP Reader Acceptance Notes

## Scope

The first release scope is a native SwiftUI iOS RSVP reader based on the practical
workflow of `thomaskolmans/rsvp-reading`:

- import text-based PDF or EPUB content;
- keep multiple imported books in a local library;
- display words with centered ORP highlighting;
- control playback, speed, pauses, progress, jump, and focus mode;
- save and resume progress per book;
- add and revisit per-book bookmarks;
- delete bookmarks with swipe or long-press actions;
- switch between persisted warm light and dark themes;
- handle iOS lifecycle, Reduce Motion, and accessibility labels.

## Implemented Capabilities

- RSVP parsing, tokenization, ORP splitting, and multi-word frames live in
  `Reader/Domain/RSVPTextProcessor.swift`.
- Playback state, progress, jump, WPM, punctuation pauses, long-word timing, and
  remaining time live in `Reader/Domain/ReadingSession.swift`,
  `Reader/Domain/ReaderSettings.swift`, and `Reader/Domain/WordTiming.swift`.
- PDF and EPUB import are handled through
  `Reader/Domain/DocumentImportService.swift`, `PDFKitTextExtractor.swift`, and
  `EPUBTextExtractor.swift`.
- Import safety limits cover document and EPUB resource bytes, PDF page count,
  EPUB spine and text-segment counts, extracted characters, and parsed tokens.
- Local books and bookmarks are stored through `BookLibraryStore`,
  `StoredBookRecord`, and `StoredBookmarkRecord`.
- SwiftUI reader UI, loading, settings, jump, controls, RSVP display, and resume
  prompt live under `Reader/App/`.
- Library and bookmark UI live in `Reader/App/LibraryView.swift` and
  `Reader/App/BookmarksView.swift`.
- Legacy single-session behavior remains in `Reader/Domain/SessionStore.swift`
  for compatibility tests, but the app launch path now uses the library store.

## Supported Formats

- Text-based PDFs readable by PDFKit.
- Standard ZIP-based EPUB files and Apple Books directory packages with readable
  OPF spine XHTML content.
- Multiple local books with independent progress, settings, and bookmarks.

## Known Limitations

- Scanned or image-only PDFs are not OCR-processed.
- Encrypted, malformed, or unusual EPUB packages may fail parsing.
- Documents exceeding import safety limits are rejected.
- Pasted-text loading is not exposed in the current add-book flow.
- There are no folders, tags, search, annotations, table of contents UI, or cloud
  sync in the first library release.
- App Store metadata, TestFlight/App Store export options, and final signing are
  separate release tasks.

## Verification Commands

Run these before release or after touching the relevant areas:

```sh
swift test
```

```sh
xcodebuild -scheme Reader \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -parallel-testing-enabled NO \
  test
```

```sh
xcodebuild -scheme Reader \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -derivedDataPath /tmp/ReaderSimulatorBuild \
  build
```

```sh
xcodebuild -scheme Reader \
  -destination 'generic/platform=iOS' \
  -archivePath /tmp/Reader.xcarchive \
  CODE_SIGNING_ALLOWED=NO \
  archive
```

## Manual Smoke Checklist

- Tap the reader header add-book button and confirm it opens file selection
  directly.
- Tap the library add-book button and confirm it opens file selection directly.
- Import a text-based PDF.
- Import a representative EPUB.
- Open a previous book from Library.
- Start, pause, resume, stop, restart, and step playback.
- Change WPM and pause settings during a session.
- Jump by word number and percentage.
- Toggle a bookmark, open the bookmark list, and jump back to the bookmark.
- Delete a bookmark by swipe and long press.
- Switch between warm light and dark themes, relaunch, and confirm the selection
  persists.
- Close, reopen, and confirm the last book resumes at its saved position.
- Confirm the RSVP word display does not overlap controls on iPhone-sized
  screens.
- Confirm progress text remains readable in both themes.
