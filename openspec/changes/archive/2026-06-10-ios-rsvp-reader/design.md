## Context

The repository starts empty apart from planning artifacts. The target behavior comes from `thomaskolmans/rsvp-reading`, a Svelte RSVP reader with text/PDF/EPUB loading, ORP highlighting, playback timing, settings, progress, jump, and saved sessions.

The iOS app will be native SwiftUI rather than a WebView clone. Core RSVP behavior must be implemented in pure Swift domain code and tested independently from SwiftUI. UI, file import, persistence, and lifecycle handling then compose around that domain layer.

Constraints:

- Minimum target is iOS 17.0.
- Xcode 26.5 and Swift 6.3 are available locally.
- There is no XcodeGen/Tuist installed, so the Xcode project will be checked in directly.
- EPUB parsing quality is a risk and must remain isolated behind an adapter.

## Goals / Non-Goals

**Goals:**

- Match the source reader's practical behavior on iOS.
- Keep RSVP parsing, ORP, timing, jump, progress, and session state unit-testable.
- Use native iOS document import for PDF and EPUB files.
- Persist one resumable reading session with full settings.
- Provide a compact dark reader UI that works on small and large iPhone screens.
- Add accessibility labels, Reduce Motion handling, and background pause behavior.

**Non-Goals:**

- No WebView wrapper.
- No OCR for scanned PDFs in the first implementation.
- No full EPUB reader renderer, table of contents, annotations, bookmarks, or library management.
- No cloud sync.
- No iPad-specific multi-column layout in the first pass.
- No App Store metadata or signing setup beyond a buildable local project.

## Decisions

### Native SwiftUI app

Build a SwiftUI iOS app with a direct `.xcodeproj`. The alternative was embedding the existing Svelte app in a WebView, but that would keep browser storage/import assumptions and make iOS lifecycle, accessibility, document picker, and App Store polish harder.

### Domain-first architecture

Place the core logic in `Reader/Domain`:

- `RSVPTextProcessor`: tokenization, ORP, display splitting, word frames.
- `WordTiming`: WPM, punctuation, long-word, and periodic pause logic.
- `ReadingSession`: state transitions, progress, jump, and playback scheduling.
- `ReaderSettings`: source-compatible settings and defaults.

SwiftUI views call this layer instead of duplicating logic in view bodies. This keeps the test surface stable and avoids UI-only behavior bugs.

### Testable playback scheduling

Use an injectable playback scheduler/clock abstraction for `ReadingSession`. Unit tests advance the scheduler manually instead of sleeping. The production implementation schedules on the main actor with cancellable tasks/timers.

### Persistence through SwiftData

Use SwiftData for the saved session model because the target is iOS 17+. Store the full text, current index, total words, settings as codable fields, and timestamp. The app only needs one resumable session at first, so `SessionStore` clears/replaces the existing record on save.

### Native import adapters

Use `PDFKit` for text-based PDF extraction with `PDFDocument`. Isolate EPUB support behind `EPUBTextExtractor`; first evaluate a Swift Package Manager EPUB library against a fixture, and fall back to a minimal ZIP/OPF/XHTML extraction pipeline if the dependency is unstable or unsuitable.

### UI composition

`ReaderView` owns high-level modal state and renders:

- `RSVPDisplayView` for fixed-center word/ORP display.
- `ProgressBarView` for progress and seek.
- `PlaybackControlsView` for play/pause/resume/stop/restart.
- `SettingsView`, `LoadContentView`, `JumpToPositionView`, and `ResumeSessionView` as sheets or overlays.

Use a monospaced font and split the current word into before/ORP/after segments positioned around the horizontal center. This preserves the visual focal point across word changes.

### Source-compatible settings

Keep the source defaults and ranges:

- WPM: 300 default, 50-1000 range, 25 step.
- Fade enabled: true, 150 ms default, 50-300 ms range.
- Punctuation pause enabled: true, multiplier 2.0 default, 1-4 range.
- Long-word multiplier: 5% default, 0-50 range.
- Pause every N words: 0/off default.
- Pause duration: 500 ms default.
- Frame word count: 1 default, odd values 1-7.

## Risks / Trade-offs

- EPUB parsing may not handle every EPUB variant -> keep EPUB code behind `EPUBTextExtractor`, add fixtures, and document limitations.
- PDFKit cannot read scanned/image-only PDFs -> show a clear empty-extraction error; OCR is explicitly out of scope.
- Direct `.xcodeproj` edits are verbose -> keep project structure simple and verify with `xcodebuild` after project changes.
- Timer behavior may drift around app lifecycle events -> centralize cancellation and pause on scene phase background/inactive.
- Long words can overflow on small devices -> use responsive monospaced layout, minimum scale factor, and screenshot checks on small and large simulators.
- SwiftData is iOS 17+ -> acceptable for this first implementation; if iOS 16 becomes required, replace with JSON persistence.

## Migration Plan

This is a new app, so there is no data migration.

Implementation sequence:

1. Create project scaffold and default reader shell.
2. Implement domain tests and domain logic.
3. Add SwiftUI reader UI.
4. Add import pipeline.
5. Add settings, save/resume, lifecycle, and accessibility.
6. Run full build, tests, and simulator smoke checks.

Rollback strategy is simple while unshipped: revert the change or delete the generated app project.

## Open Questions

- Final bundle identifier and signing team are not specified; use `com.sigius.reader` placeholder locally.
- Final app name can remain `Reader` unless the user chooses a branded name later.
- EPUB dependency choice remains open until Task 6 evaluation.
