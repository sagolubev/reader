# Reader

Native SwiftUI RSVP reader for iOS. The app ports the practical workflow from
`thomaskolmans/rsvp-reading`: load text, PDF, or EPUB content, read it through a
centered RSVP display with ORP highlighting, tune playback settings, jump through
the text, and resume a saved session later.

## Requirements

- Xcode 26.5 or newer
- iOS 17.0 minimum target
- Swift Package Manager access to `ZIPFoundation`

The local placeholder bundle identifier is `com.sigius.reader`. A real
development team and signing profile are still required before device
distribution or App Store export.

## Load content

Use the load button in the reader header to paste text directly or import a file
through the native document picker. Text-based PDFs are extracted with PDFKit.
EPUB files are read through the app's `EPUBTextExtractor`, which supports
standard OPF spine ordering for readable XHTML content.

Scanned PDFs, encrypted EPUBs, malformed EPUB packages, OCR, bookmarks, and a
library view are out of scope for this first version.

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

Use the save control to store one local reading session. The saved session
includes the source text, current word position, total word count, reader
settings, and save timestamp. On the next launch, Reader offers to resume the
session or start fresh.

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
