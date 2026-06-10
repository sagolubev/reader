# EPUB Import Evaluation

## Decision

Use `ZIPFoundation` as the ZIP container dependency for EPUB files, pinned through Swift Package Manager with `.upToNextMajor(from: "0.9.0")`.

`EPUBTextExtractor` remains our boundary for EPUB semantics. The dependency should only open the archive and read entries; package discovery, OPF parsing, spine ordering, XHTML cleanup, and reader-facing errors stay in app code.

## Evidence

- Swift Package Index lists `0.9.20` as the latest release, with iOS 12.0+ support.
- The upstream README describes ZIPFoundation as a Swift library for creating, reading, and modifying ZIP archives.
- The package has no third-party dependencies on Apple platforms and is based on Apple's compression stack.

Sources checked on 2026-06-10:

- https://swiftpackageindex.com/weichsel/ZIPFoundation
- https://github.com/weichsel/ZIPFoundation/releases

## Fixture Scope

The EPUB fixture for implementation should include:

- `mimetype`
- `META-INF/container.xml`
- `OEBPS/content.opf`
- two XHTML chapter files referenced by the OPF spine

Acceptance criteria:

- Extract chapter text in OPF spine order.
- Strip XML/HTML tags.
- Decode basic entities used in XHTML text.
- Return `DocumentImportError.emptyExtractedText` when no readable chapter text remains.
- Keep encrypted EPUB, malformed OPF, alternate table-of-contents metadata, images, CSS, and advanced XHTML cleanup out of scope for the first pass.
