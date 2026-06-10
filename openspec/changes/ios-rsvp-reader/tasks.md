## 1. Project Scaffold

- [x] 1.1 Create the checked-in SwiftUI iOS project with app, unit test, and UI test targets
- [x] 1.2 Add the initial app entry point and root reader shell
- [x] 1.3 Verify the empty app builds with `xcodebuild`

## 2. RSVP Domain Logic

- [x] 2.1 Add failing unit tests for text tokenization and empty input
- [x] 2.2 Implement text tokenization until tokenization tests pass
- [x] 2.3 Add failing unit tests for ORP calculation across Latin, Cyrillic, punctuation, CJK, RTL, and non-letter tokens
- [x] 2.4 Implement ORP and word display splitting until ORP tests pass
- [ ] 2.5 Add failing unit tests for single-word and multi-word frame extraction
- [ ] 2.6 Implement word frame extraction until frame tests pass

## 3. Timing And Session State

- [ ] 3.1 Add failing unit tests for reader settings defaults and word timing
- [ ] 3.2 Implement settings and word timing until timing tests pass
- [ ] 3.3 Add failing unit tests for remaining-time formatting and periodic pause checks
- [ ] 3.4 Implement remaining-time formatting and periodic pause checks
- [ ] 3.5 Add failing unit tests for load, play, pause, resume, stop, restart, step, seek, and jump state transitions
- [ ] 3.6 Implement the reading session state machine with a testable scheduler

## 4. Native Reader UI

- [ ] 4.1 Add the main `ReaderView` connected to the domain session
- [ ] 4.2 Add `RSVPDisplayView` with fixed-center ORP alignment and focus marker
- [ ] 4.3 Add progress and playback controls
- [ ] 4.4 Add focus mode state and layout behavior
- [ ] 4.5 Add small and large device previews or simulator screenshot checks

## 5. Content Import

- [ ] 5.1 Add failing tests for import type dispatch, unsupported files, and text normalization
- [ ] 5.2 Implement `DocumentImportService` and normalization
- [ ] 5.3 Implement PDF extraction through PDFKit and an empty-extraction error
- [ ] 5.4 Evaluate EPUB extraction dependency or fallback parser against a fixture
- [ ] 5.5 Implement EPUB extraction behind `EPUBTextExtractor`
- [ ] 5.6 Add the load content UI with paste text and file importer

## 6. Settings And Controls

- [ ] 6.1 Add settings UI for WPM, fade, punctuation, long-word, periodic pause, and frame count
- [ ] 6.2 Wire settings changes into live playback timing and display
- [ ] 6.3 Add touch controls for back/forward and slower/faster
- [ ] 6.4 Add hardware keyboard shortcuts for source-compatible actions

## 7. Persistence And Resume

- [ ] 7.1 Add failing tests for saving, loading, clearing, and restoring settings
- [ ] 7.2 Implement the SwiftData saved session model and session store
- [ ] 7.3 Add save action and resume/start-fresh prompt
- [ ] 7.4 Add jump sheet and tappable progress seek behavior

## 8. Accessibility, Lifecycle, And Verification

- [ ] 8.1 Add accessibility labels for icon-only and compact controls
- [ ] 8.2 Respect Reduce Motion and pause playback on app backgrounding
- [ ] 8.3 Add UI smoke tests for load, playback, jump, save, and resume
- [ ] 8.4 Run the full unit/UI test suite
- [ ] 8.5 Run an iOS archive build and update user-facing documentation
