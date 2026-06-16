# Reader

Native SwiftUI RSVP reader for iOS. The app ports the practical workflow from
`thomaskolmans/rsvp-reading`: import PDF or EPUB content, read it through a
centered RSVP display with ORP highlighting, tune playback settings, jump through
the text, and resume a saved session later.

## Requirements

- Xcode 26.5 or newer
- iOS 17.0 minimum target
- Swift Package Manager access to `ZIPFoundation`

The local placeholder bundle identifier is `com.sigius.reader`. A real
development team and signing profile are still required before device
distribution or App Store export.

## Add books

Use the add-book button in the reader header or the library toolbar to open the
native document picker directly. Text-based PDFs are extracted with PDFKit. EPUB
files are read through the app's `EPUBTextExtractor`, which supports standard
OPF spine ordering for readable XHTML content.

Every successful PDF or EPUB import is saved as a local library book and
opened immediately. Books keep their own reading progress and settings.

Scanned PDFs, encrypted EPUBs, malformed EPUB packages, OCR, bookmarks, and a
advanced library management are out of scope for this first version.

## Library

Use the library button in the reader header to open previously imported books.
The library also has its own add-book button for importing another file.
Selecting a book restores its text, position, progress, and settings. Deleting a
book also deletes its bookmarks.

## Bookmarks

Use the bookmark button while a library book is open to toggle a bookmark at the
current word. The bookmarks button shows bookmarks for the active book only, and
selecting a bookmark jumps back to that word.

## RSVP playback

The main reader surface shows a dark, centered RSVP display with a red ORP
letter and center marker. Playback controls support play, pause, resume, stop,
restart, stepping backward or forward, and speed changes. Settings cover WPM,
fade, punctuation pauses, long-word timing, periodic pauses, and multi-word
frames.

Hardware keyboard shortcuts are available for source-compatible actions:
Space, Escape, Arrow Up, Arrow Down, Arrow Left, Arrow Right, `G`, and
Command-S.

## Save and resume

Reader stores progress per library book. The saved state includes source text,
current word position, total word count, reader settings, and timestamps. On the
next launch, Reader opens the most recently used book when one exists.

Playback pauses when the app moves inactive or into the background. Reduce
Motion disables word fade animation without changing the user's fade setting.

## Development

Run the core package tests:

```sh
swift test
```

Run the full app unit and UI suite on the local iPhone 17 simulator:

```sh
xcodebuild -scheme Reader \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -parallel-testing-enabled NO \
  test
```

Create an unsigned local iOS archive build:

```sh
xcodebuild -scheme Reader \
  -destination 'generic/platform=iOS' \
  -archivePath /tmp/Reader.xcarchive \
  CODE_SIGNING_ALLOWED=NO \
  archive
```

For signed distribution, replace the placeholder signing setup with the final
bundle identifier, development team, provisioning profile, and export options.

## Documentation

- `AGENTS.md` documents repository-specific agent rules and verification
  commands.
- `docs/ios-rsvp-reader-acceptance.md` documents implemented scope, supported
  formats, limitations, verification commands, and manual smoke checks.
- `docs/epub-import-evaluation.md` documents the EPUB extraction boundary and
  ZIPFoundation choice.
- `openspec/specs/` contains the archived source-of-truth capability specs after
  the completed `ios-rsvp-reader` change is archived.
