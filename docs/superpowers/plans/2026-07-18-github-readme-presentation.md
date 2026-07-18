# GitHub README Presentation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Publish a modern product-minimal GitHub README with an authentic warm-theme screenshot of Reader running in an iPhone Simulator.

**Architecture:** Build and launch the existing `Reader` scheme without changing application behavior. Capture the simulator framebuffer into a repository-owned asset, then restructure the root README around the real product image, implemented capabilities, safety boundaries, architecture, and reproducible development commands.

**Tech Stack:** SwiftUI, Xcode, iOS Simulator, `xcrun simctl`, Markdown, OpenSpec

---

### Task 1: Capture the Running Application

**Files:**
- Create: `docs/assets/reader-screenshot.png`

- [ ] **Step 1: Discover or boot the target simulator**

Run:

```sh
xcrun simctl list devices available
```

Use an available `iPhone 17` simulator. If it is shut down, boot it with:

```sh
xcrun simctl boot "iPhone 17"
open -a Simulator
```

Expected: `xcrun simctl list devices booted` shows one booted iPhone 17.

- [ ] **Step 2: Build the app for the simulator**

Run:

```sh
xcodebuild -scheme Reader \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -derivedDataPath /tmp/ReaderSimulatorBuild \
  build
```

Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 3: Install and launch Reader**

Run:

```sh
xcrun simctl install booted /tmp/ReaderSimulatorBuild/Build/Products/Debug-iphonesimulator/Reader.app
xcrun simctl launch --terminate-running-process booted com.sigius.reader
```

Expected: `com.sigius.reader` launches in the booted simulator.

- [ ] **Step 4: Prepare the warm-theme reader screen**

Inspect the launched app and ensure the primary reader screen is visible in the
warm light theme with representative text, progress, and controls. Stop or pause
playback so the screenshot is deterministic.

- [ ] **Step 5: Capture the real simulator framebuffer**

Run:

```sh
mkdir -p docs/assets
xcrun simctl io booted screenshot docs/assets/reader-screenshot.png
sips -g pixelWidth -g pixelHeight docs/assets/reader-screenshot.png
```

Expected: a non-empty PNG matching the simulator display dimensions.

- [ ] **Step 6: Inspect the screenshot**

Open `docs/assets/reader-screenshot.png` and verify that Reader fills the screen,
the warm theme is active, the RSVP text is readable, controls do not overlap,
and no simulator alerts or unrelated windows are present.

### Task 2: Restructure the Root README

**Files:**
- Modify: `README.md`
- Test: `ReaderCoreTests/DocumentationSourceTests.swift`

- [ ] **Step 1: Add the product header**

Keep `# Reader`, add the concise product description, and add static badges for
Swift 6, SwiftUI, and iOS 17+ without external build-status claims.

- [ ] **Step 2: Embed the authentic screenshot**

Add the repository-relative image directly after the introduction:

```markdown
<p align="center">
  <img src="docs/assets/reader-screenshot.png" alt="Reader running in the warm light theme on iPhone" width="390">
</p>
```

- [ ] **Step 3: Organize product and technical sections**

Use this order:

1. `Features`
2. `Supported content`
3. `Safety limits`
4. `Architecture`
5. `Requirements`
6. `Build and test`
7. `Documentation`
8. `Limitations`

Preserve the verified behavior already documented for themes, bookmarks,
library persistence, import formats, lifecycle, accessibility, and signing.

- [ ] **Step 4: Keep documentation source coverage compatible**

Ensure the README still contains the snippets required by
`DocumentationSourceTests`, including `Add books`, `Library`, `Bookmarks`,
`RSVP playback`, `Save and resume`, `swift test`, the `xcodebuild` command,
`-parallel-testing-enabled NO`, `archive`, and the acceptance-document path.

### Task 3: Verify and Publish

**Files:**
- Verify: `README.md`
- Verify: `docs/assets/reader-screenshot.png`
- Verify: `docs/ios-rsvp-reader-acceptance.md`
- Verify: `openspec/specs/*/spec.md`

- [ ] **Step 1: Run documentation tests**

Run:

```sh
swift test --filter DocumentationSourceTests
```

Expected: the selected test passes with zero failures.

- [ ] **Step 2: Validate OpenSpec**

Run:

```sh
openspec validate --all --strict --no-interactive
```

Expected: all changes and specs pass.

- [ ] **Step 3: Validate repository changes**

Run:

```sh
git diff --check
git status --short
```

Expected: no whitespace errors; only intended documentation and screenshot
changes are present.

- [ ] **Step 4: Commit the presentation update**

Run:

```sh
git add README.md docs/assets/reader-screenshot.png \
  docs/ios-rsvp-reader-acceptance.md openspec/specs
git commit -m "docs: polish GitHub project presentation"
```

Expected: one focused documentation commit.

- [ ] **Step 5: Push and verify GitHub**

Run:

```sh
git push origin master
gh repo view sagolubev/reader --web
git status --short --branch
```

Expected: `master` tracks `origin/master` with no unpushed commits, and GitHub
renders the screenshot from the README-relative path.
