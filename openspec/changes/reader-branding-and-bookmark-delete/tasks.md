## 1. Tests

- [x] 1.1 Add failing source tests for bookmark swipe and long-press delete affordances.
- [x] 1.2 Add a failing domain test for explicit bookmark deletion.
- [x] 1.3 Add failing source tests for Russian default text and display name branding.

## 2. Bookmark Deletion

- [x] 2.1 Add explicit bookmark deletion to `BookLibraryStore`.
- [x] 2.2 Add `onDeleteBookmark` to `BookmarksView` and expose swipe/context delete actions.
- [x] 2.3 Wire `ReaderView` bookmark deletion to persistence and refresh state.

## 3. Branding

- [x] 3.1 Replace `ReaderView.defaultText` with the provided Russian RSVP text.
- [x] 3.2 Set the iOS display name to `Быстрочиталка`.
- [x] 3.3 Generate the approved AppIcon asset at all required sizes.

## 4. Verification

- [x] 4.1 Run `swift test`.
- [x] 4.2 Run the iPhone 17 simulator app/unit/UI suite.
- [x] 4.3 Run `openspec validate reader-branding-and-bookmark-delete --strict`.
