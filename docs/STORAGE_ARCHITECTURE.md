# Storage Architecture

## Overview

RosaWriter uses SwiftData for persistent storage of books/stories. The architecture separates the data model from the UI representation, allowing efficient storage and retrieval.

## Data Models

### StoryData (SwiftData Model)

The persistent storage model with the following fields:

-   `id: UUID` - Unique identifier (matches Book.id)
-   `createdAt: Date` - Creation timestamp
-   `title: String` - Story title
-   `coverImage: String?` - Optional cover image name
-   `wordCount: Int?` - Cached word count for display
-   `storyJson: String` - Full book data serialized as JSON

### Book (UI Model)

The in-memory model used by the UI:

-   `id: UUID`
-   `title: String`
-   `pages: [BookPage]`
-   `createdAt: Date`
-   `updatedAt: Date`

## StorageService

The `StorageService` class handles all persistence operations:

### Key Methods

#### Saving

```swift
func saveStoryData(_ book: Book, context: ModelContext) throws
```

-   Converts Book to JSON
-   Calculates metadata (wordCount, coverImage)
-   Updates existing or creates new StoryData
-   Called after AI generation or manual book creation

#### Loading

```swift
func loadAllStoryData(context: ModelContext) throws -> [StoryData]
```

-   Returns lightweight StoryData (no JSON parsing)
-   Used for bookshelf view display
-   Sorted by creation date (newest first)

```swift
func loadAllBooks(context: ModelContext) throws -> [Book]
```

-   Parses JSON for all stories
-   Returns full Book objects
-   Use sparingly (prefer loading specific books on demand)

```swift
func loadStoryData(id: UUID, context: ModelContext) throws -> Book?
```

-   Loads a specific book by ID
-   Parses JSON only for that book
-   Called when opening a book to read

#### Deleting

```swift
func deleteStoryData(id: UUID, context: ModelContext) throws
```

-   Deletes a story by ID
-   Updates database immediately

#### First Launch

```swift
func populateWithSampleData(context: ModelContext) throws
```

-   Called automatically on first launch
-   Populates database with sample books from `SampleData`
-   Provides good onboarding experience

## JSON Conversion

Books are serialized to JSON using Codable wrappers:

-   `CodableBook` - wrapper for Book
-   `CodablePage` - wrapper for BookPage
-   `CodableImageLayout` - wrapper for PageImageLayout

This approach allows:

-   Flexible schema evolution
-   Easy export/import of stories
-   Debugging (JSON is human-readable)

## Usage in Views

### BookshelfView

```swift
@Environment(\.modelContext) private var modelContext
```

-   Loads StoryData on first appear
-   Populates with sample data if empty
-   Converts to Book objects for display
-   Saves new books after creation
-   Deletes books through StorageService

### Future: BookView

When opening a book, it should:

1. Receive the Book object directly from BookshelfView
2. Or load by ID using `StorageService.shared.loadStoryData(id:context:)`

## Sample Data Integration

`SampleData` is still used for:

-   First launch experience
-   Demonstration books
-   Testing/development

The sample books are automatically saved to SwiftData on first launch via `populateWithSampleData()`.

## Future Enhancements

1. **Incremental Loading** - Load StoryData for bookshelf, parse JSON only when opening
2. **Background Sync** - Sync with iCloud using CloudKit
3. **Export/Import** - Easy sharing of stories via JSON files
4. **Backup** - Periodic backups of the database
5. **Search** - Full-text search across all stories
6. **Categories/Tags** - Organize stories by themes or characters

## Performance Considerations

-   ✅ Bookshelf loads quickly (no JSON parsing)
-   ✅ Word count and cover image cached in StoryData
-   ✅ Books only fully parsed when needed
-   ✅ Deletion is immediate
-   ⚠️ `loadAllBooks()` parses all JSON - use sparingly

## Error Handling

All StorageService methods throw errors. Views should handle:

-   `StorageError.encodingFailed` - Failed to convert Book to JSON
-   `StorageError.decodingFailed` - Failed to convert JSON to Book
-   SwiftData errors (fetch, save, delete failures)

Currently errors are logged to console. Future: show user-friendly error messages.
