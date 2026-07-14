# Design

## Security invariant

Every user-selected document must remain within one repository-owned resource
policy before Reader performs proportional allocation, parsing, tokenization,
or display work. An over-budget document is rejected rather than truncated.

## Enforcement

`ReaderResourceLimits` owns conservative defaults and supports smaller limits
in tests. `DocumentImportError.resourceLimitExceeded` is the common rejection
surface.

- `EPUBTextExtractor` creates one mutable budget and passes it through container,
  package, and chapter reads. Its XHTML delegate also limits text callbacks
  before normalizing or retaining each segment.
- `PDFKitTextExtractor` checks page count and cumulative decoded characters.
- `DocumentImportService` checks final normalized character and token budgets.
- `RSVPTextProcessor` rejects excessive input, token count, and token length
  before expensive work.
- SwiftUI renders a bounded placeholder for a persisted legacy token that
  exceeds the display policy.

## Compatibility

Normal documents below the limits preserve existing output. Apple Books package
directories remain supported. Stored legacy content is not deleted; opening
over-budget legacy content fails safely instead of re-triggering unbounded work.
