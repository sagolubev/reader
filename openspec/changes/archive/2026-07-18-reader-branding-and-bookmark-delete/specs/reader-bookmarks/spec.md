## ADDED Requirements

### Requirement: Delete bookmark from bookmark list
The system SHALL allow users to delete a saved bookmark from the bookmarks list.

#### Scenario: Delete bookmark by swipe
- **WHEN** the user swipes a bookmark row and confirms delete
- **THEN** the bookmark is removed from the active book
- **AND** the bookmark list refreshes without closing the sheet

#### Scenario: Delete bookmark by long press
- **WHEN** the user long-presses a bookmark row and chooses Delete
- **THEN** the bookmark is removed from the active book
- **AND** the bookmark list refreshes without closing the sheet
