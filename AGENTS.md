# Agent Instructions

This repository contains a native SwiftUI iOS RSVP reader.

## Project Layout

- `Reader/Domain/` is the Swift Package target `ReaderCore`. Keep reader logic,
  parsing, timing, persistence policy, and import behavior here when possible.
- `Reader/App/` contains SwiftUI screens and app wiring for the iOS target.
- `ReaderCoreTests/` covers package/domain behavior and source-level guards.
- `ReaderTests/` and `ReaderUITests/` cover Xcode app and UI behavior.
- `openspec/` contains OpenSpec proposals, tasks, and specs. Keep related
  artifacts in sync when implementing OpenSpec-scoped changes.

## Development Rules

- Prefer small, focused Swift changes that follow existing SwiftUI and domain
  patterns.
- Keep business logic testable in `Reader/Domain/`; avoid putting parsing,
  timing, or persistence decisions directly inside SwiftUI views.
- Do not rewrite `Reader.xcodeproj/project.pbxproj` for style-only reasons.
  Xcode signing changes may be user-owned; preserve unrelated project-file
  edits unless explicitly asked to change them.
- Keep UI readable on real iPhone sizes. After changing reader layout, verify
  that RSVP words, controls, and progress text do not overlap.
- Use ASCII in new text/code unless a file already uses non-ASCII for a clear
  reason.

## Verification

Run package tests after domain or source-guard changes:

```sh
swift test
```

Run the app/unit/UI suite on an iOS simulator after app UI or lifecycle changes:

```sh
xcodebuild -scheme Reader \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -parallel-testing-enabled NO \
  test
```

Build for simulator when checking local installability:

```sh
xcodebuild -scheme Reader \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -derivedDataPath /tmp/ReaderSimulatorBuild \
  build
```

For unsigned archive checks:

```sh
xcodebuild -scheme Reader \
  -destination 'generic/platform=iOS' \
  -archivePath /tmp/Reader.xcarchive \
  CODE_SIGNING_ALLOWED=NO \
  archive
```

Before claiming completion, run the narrowest relevant verification command and
report any command that could not be run.
