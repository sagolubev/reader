# Design

## Root Cause

Apple Books exported the selected `.epub` as a filesystem package directory:

- `META-INF/container.xml`
- `OPS/content.opf`
- `OPS/*.xhtml`

`EPUBTextExtractor` assumed every EPUB URL was a ZIP archive and constructed
`Archive(url:accessMode:)` before reading `container.xml`. Directory packages
therefore failed before OPF parsing.

## Approach

Add a small internal EPUB container abstraction:

- ZIP EPUBs continue to read entries through ZIPFoundation.
- Directory-package EPUBs read files relative to the package root.
- Both container types share the same `container.xml`, OPF manifest, spine, and
  XHTML text extraction pipeline.

Normalize manifest hrefs by stripping fragments/query strings, decoding percent
escapes, and standardizing relative paths before entry lookup. Directory reads
are constrained to the package root so EPUB metadata cannot escape the selected
package.

## Risks

- Some EPUBs may still contain malformed XHTML or DRM-protected content. Those
  should continue to surface a parse or empty-text import error.
