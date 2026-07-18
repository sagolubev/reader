# reader-bookmarks Specification

## Purpose
Define creation, display, navigation, deletion, and per-book isolation of saved
reading positions.
## Requirements
### Requirement: Bookmark current position
The system SHALL allow users to bookmark the current word position for the
active book.

#### Scenario: Add bookmark
- **WHEN** the user taps the bookmark control while a book is open
- **THEN** the system stores a bookmark for the active book at the current word
  index with a short text preview and creation timestamp

#### Scenario: Avoid duplicate bookmark
- **WHEN** the user taps the bookmark control at a word index that is already
  bookmarked for the active book
- **THEN** the system removes the existing bookmark instead of creating a
  duplicate

### Requirement: Bookmark list
The system SHALL show bookmarks for the active book.

#### Scenario: Show active book bookmarks
- **WHEN** the user opens the bookmark list for a book
- **THEN** the system shows that book's bookmarks ordered by word position with
  preview text

#### Scenario: Empty bookmark list
- **WHEN** the active book has no bookmarks
- **THEN** the system shows an empty state instead of bookmarks from other books

### Requirement: Jump to bookmark
The system SHALL allow users to jump to a saved bookmark.

#### Scenario: Select bookmark
- **WHEN** the user selects a bookmark
- **THEN** the reader moves the active book to that bookmark's word index and
  stops active playback

### Requirement: Bookmark isolation
The system SHALL keep bookmarks scoped to their owning book.

#### Scenario: Switch books
- **WHEN** the user opens a different book
- **THEN** the bookmark button and bookmark list reflect only the newly active
  book's bookmarks

### Requirement: Delete bookmark
The system SHALL allow users to remove a bookmark from the bookmark list.

#### Scenario: Delete with list action
- **WHEN** the user deletes a bookmark with a swipe or long-press action
- **THEN** that bookmark is removed while the owning book and its other
  bookmarks remain unchanged
