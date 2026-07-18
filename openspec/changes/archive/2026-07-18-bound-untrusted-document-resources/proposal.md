# Bound untrusted document resources

## Why

The security review confirmed five local denial-of-service paths. PDF and EPUB
imports perform unbounded parsing and allocation, full-document tokenization
creates unbounded owned strings, and display processing scans arbitrarily large
tokens. All paths require explicit user selection, but a crafted document can
freeze or terminate Reader.

## What Changes

- Apply one explicit resource policy to PDF, EPUB, normalized text, tokens, and
  display words.
- Reject over-budget input with a distinct resource-limit error.
- Share one cumulative budget across every EPUB resource.
- Reject EPUB XML that creates excessive text-node allocation work even when
  its byte and character totals remain below their limits.
- Preserve ordinary PDF, EPUB, library, and RSVP behavior below the limits.
- Add regression tests for every confirmed security finding and nearby bypasses.

## Success Criteria

- ZIP and directory EPUB resources cannot exceed per-resource or cumulative
  budgets.
- Segmented XHTML cannot create an unbounded number of retained text parts.
- PDFs over the page or decoded-text budget are rejected before full joining.
- Imported text cannot exceed the normalized-character or token-count budget.
- A giant token is rejected before Unicode-wide ORP scanning or substring copies.
- Existing package and app tests pass.
