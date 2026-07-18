## MODIFIED Requirements

### Requirement: Bookmark list
The system SHALL show valid bookmarks for the active book and SHALL exclude
persisted bookmarks whose word indexes are outside that book's text.

#### Scenario: Show active book bookmarks
- **WHEN** the user opens the bookmark list for a book
- **THEN** the system shows that book's valid bookmarks ordered by word position
  with preview text

#### Scenario: Ignore malformed persisted bookmark
- **WHEN** a persisted bookmark has a negative index or an index at or beyond the
  owning book's word count
- **THEN** the bookmark is not returned to the bookmark list
- **AND** other valid bookmarks remain visible

#### Scenario: Empty bookmark list
- **WHEN** the active book has no valid bookmarks
- **THEN** the system shows an empty state instead of bookmarks from other books

### Requirement: Jump to bookmark
The system SHALL allow users to jump to a valid saved bookmark.

#### Scenario: Select bookmark
- **WHEN** the user selects a valid bookmark
- **THEN** the reader moves the active book to that bookmark's word index and
  stops active playback

#### Scenario: Invalid bookmark cannot be selected
- **WHEN** persisted bookmark data refers outside the owning book's word range
- **THEN** no selectable bookmark is exposed for that row
