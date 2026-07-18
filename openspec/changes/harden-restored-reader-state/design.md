## Context

`ReaderSettings` uses synthesized `Codable`, and current persistence adapters return decoded values without normalizing them. Valid JSON can therefore contain integer or floating-point extrema that later overflow in frame selection, speed adjustment, settings rendering, or playback delay conversion. Persisted bookmark rows similarly bypass the clamping used when new bookmarks are created.

The application is local and sandboxed, so these are robustness issues rather than reportable remote vulnerabilities. They are still worth fixing because corrupted stores and restored backups should not make the app repeatedly crash.

## Goals / Non-Goals

**Goals:**

- Establish one domain-level normalization boundary for decoded `ReaderSettings`.
- Ensure every current and legacy persistence restore path uses that boundary.
- Prevent invalid persisted bookmark indexes from reaching list rendering or navigation.
- Make WPM and playback-delay arithmetic safe even if malformed values reach domain methods directly.
- Preserve valid persisted behavior and the existing SwiftData schema.

**Non-Goals:**

- Replacing `PDFKit` or attempting to sandbox system PDF parsing inside the app process.
- Automatically deleting entire books or resetting the complete library when one field is invalid.
- Changing supported WPM, frame-size, pause, bookmark, or document-import behavior.
- Adding a new migration version or external dependency.

## Decisions

### Normalize at persistence ingress and retain arithmetic guards

Decoded settings will be normalized before a store returns a domain snapshot or migrates a legacy record. This prevents malformed state from spreading through the app. Arithmetic consumers will also avoid trapping on overflow so direct construction in tests or future call sites remains safe.

Alternative: normalize only in SwiftUI views. Rejected because playback and session methods consume settings before every view can repair them.

Alternative: implement custom `Codable` validation that rejects an entire settings payload. Rejected because one invalid field would discard otherwise recoverable user preferences and complicate backwards compatibility.

### Repair settings, filter invalid bookmarks

Reader settings have clear supported ranges, so malformed values will clamp to the nearest supported value. Bookmark indexes identify a specific word; an out-of-range persisted row has no safe semantic target, so it will be omitted from returned snapshots rather than silently moved to another word.

Alternative: clamp invalid bookmark indexes. Rejected because that could redirect a bookmark to unrelated text.

Alternative: delete invalid bookmark rows immediately. Rejected because read paths should not introduce hidden persistence mutations; filtering is deterministic and non-destructive.

### Use overflow-safe adjustment and finite bounded delays

WPM adjustment will calculate within the supported range without performing a potentially trapping intermediate addition. Playback timing will use normalized settings and return a finite delay bounded to a value that can safely convert to the sleep duration type.

Alternative: rely solely on ingress normalization. Rejected because domain types remain directly constructible and future callers could bypass persistence.

### Keep PDF handling unchanged

Reader already applies encoded-size, page-count, extracted-character, token-count, and token-size limits. `PDFDocument(url:)` must parse enough structure before page limits are observable, and Reader cannot completely bound system `PDFKit` internals without replacing or isolating the parser. The scan's final policy classified the residual path as transient, explicit-selection self-denial-of-service.

## Risks / Trade-offs

- [Risk] Filtering a malformed bookmark hides corrupted data without repairing storage. → Tests will prove valid bookmarks remain visible; persistent cleanup can be a separate migration if product evidence requires it.
- [Risk] Clamping malformed settings changes restored values. → Only values outside documented control ranges change; valid values remain byte-for-byte equivalent after decode.
- [Risk] Multiple normalization call sites drift. → A single domain helper will own normalization and all persistence adapters will call it.
- [Risk] Delay caps subtly change valid timing. → The cap will sit above every delay producible by supported settings, and existing timing tests will remain unchanged.

## Migration Plan

No schema migration is required. Existing records are normalized or filtered when read. Rolling back restores the previous read behavior without changing stored data.

## Open Questions

None.
