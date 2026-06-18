## 1. Tests

- [x] 1.1 Add a failing source-level regression test that the file picker
  allows provider-specific book/content identifiers.

## 2. Implementation

- [x] 2.1 Add a system content UTType fallback.
- [x] 2.2 Include that fallback in `SupportedBookFileTypes.documentTypes`.

## 3. Verification

- [x] 3.1 Run the targeted regression test.
- [x] 3.2 Run `swift test`.
- [x] 3.3 Run `openspec validate fix-book-file-picker-disabled-books --strict`.
- [x] 3.4 Run the iPhone 17 simulator app/unit/UI suite.
