## MODIFIED Requirements

### Requirement: Save session
The system SHALL save progress and reader settings for each persisted library
book.

#### Scenario: Save active session
- **WHEN** the active book position or settings change
- **THEN** the corresponding library book is updated with text, position,
  settings, word count, and last-opened timestamp

#### Scenario: Save without content
- **WHEN** no book or words are loaded
- **THEN** no library progress record is written

### Requirement: Resume session
The system SHALL detect the most recently opened library book at app launch and
open it automatically.

#### Scenario: Resume saved session
- **WHEN** the app launches with a persisted last-opened book
- **THEN** the active text, current word index, progress, and settings are
  restored from that book

#### Scenario: Migrate legacy saved session
- **WHEN** the app launches with an old single-session save
- **THEN** the save is converted into a library book or merged into the matching
  existing book
- **AND** the restored library book opens at the legacy word index and settings

#### Scenario: Start fresh
- **WHEN** the library is empty
- **THEN** the default reader state remains active and no resume prompt is shown

### Requirement: Settings persistence in session
The system SHALL persist all reader settings per book needed to reproduce
playback timing and display after reopening that book.

#### Scenario: Restore settings
- **WHEN** a book saved at 450 WPM with punctuation pauses disabled is reopened
- **THEN** the reader uses 450 WPM and punctuation pauses remain disabled for
  that book

## REMOVED Requirements

### Requirement: Clear session
**Reason**: The app no longer stores one global saved session. Progress now
belongs to individual library books.

**Migration**: Users delete a library book to remove its text, progress,
settings, and bookmarks, or open another book to switch sessions.
