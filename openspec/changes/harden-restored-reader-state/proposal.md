## Why

Reader currently trusts numeric settings and bookmark indexes decoded from local persistence. Corrupted stores or restored backups can therefore trigger repeatable crashes or excessive rendering work before the UI has an opportunity to normalize the values.

## What Changes

- Normalize decoded reader settings at the persistence boundary before returning snapshots or migrating legacy sessions.
- Reject or repair invalid persisted bookmark indexes before exposing them to the UI.
- Make WPM adjustments and playback-delay conversion safe for integer and floating-point extremes.
- Preserve all valid saved books, settings, bookmarks, and reading progress.
- Add regression tests that prove malformed persisted values fail safely.
- Retain the existing PDF import limits; system `PDFKit` parser complexity cannot be fully bounded by Reader without replacing the parser.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `reader-session-persistence`: Restored session and book settings are normalized before domain or UI use.
- `reader-bookmarks`: Persisted bookmark indexes are validated against the owning book before display or navigation.
- `rsvp-playback`: Speed adjustment and playback timing remain safe for malformed extreme settings.

## Impact

Affected code is limited to `Reader/Domain/` persistence, settings, timing, and session logic plus focused `ReaderCoreTests/` coverage. Public UI workflows, supported document formats, package dependencies, and storage schema remain unchanged.
