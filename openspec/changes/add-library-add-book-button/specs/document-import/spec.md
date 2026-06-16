## REMOVED Requirements

### Requirement: Pasted text import
The system SHALL allow users to paste or type text and load it as a persisted
library book that becomes the active reading book.

#### Scenario: Load pasted text
- **WHEN** the user enters non-empty text and confirms loading
- **THEN** the text is normalized, saved as a new library book, opened in the
  reader, and word parsing runs on it

#### Scenario: Reject blank pasted text
- **WHEN** the user attempts to load blank text
- **THEN** no library book is created and the active book is not replaced
