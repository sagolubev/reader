## Why

The user needs a native iOS version of `thomaskolmans/rsvp-reading` with the same practical reading workflow: load text/PDF/EPUB content, read it using RSVP with ORP highlighting, tune speed and pauses, jump around, and resume later.

Building this as native SwiftUI avoids the file access, persistence, accessibility, app lifecycle, and App Store polish problems that a WebView clone would inherit.

## What Changes

- Add a new SwiftUI iOS app named `Reader`.
- Port the RSVP domain behavior from the source web project into tested Swift code.
- Add native content import for pasted text, text-based PDFs, and EPUB files.
- Add a dark reader interface with centered ORP display, focus mode, playback controls, progress, and seek/jump controls.
- Add reader settings matching the source ranges and defaults.
- Add local save/resume of the current reading text, position, and settings.
- Add iOS-specific lifecycle and accessibility behavior.

## Capabilities

### New Capabilities

- `rsvp-playback`: Text tokenization, ORP calculation, word timing, playback state, progress, seeking, and jump behavior.
- `document-import`: Pasted text, PDF, and EPUB content loading into normalized readable text.
- `reader-session-persistence`: Local save, restore, and clear behavior for active reading sessions and settings.
- `native-reader-ui`: SwiftUI reader surface, focus mode, controls, settings, accessibility, and lifecycle behavior.

### Modified Capabilities

- None.

## Impact

- New iOS application project in this repository.
- New SwiftUI, SwiftData, PDFKit, XCTest, and XCUITest code.
- Possible Swift Package Manager dependency for EPUB parsing after evaluation.
- OpenSpec artifacts, task tracking with `br`, and TDD implementation workflow.
