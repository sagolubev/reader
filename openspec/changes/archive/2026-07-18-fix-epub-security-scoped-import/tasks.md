## 1. Tests

- [x] 1.1 Add a failing source-level regression test for immediate
  security-scoped access in the EPUB/file import path.

## 2. Implementation

- [x] 2.1 Start security-scoped access before async import work and stop it
  after import completes.
- [x] 2.2 Remove the extra async hop/yield from file selection.

## 3. Verification

- [x] 3.1 Run the targeted regression test.
- [x] 3.2 Run `swift test`.
- [x] 3.3 Run `openspec validate fix-epub-security-scoped-import --strict`.
- [x] 3.4 Run the iPhone 17 simulator app/unit/UI suite.
