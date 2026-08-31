# Storage & Migration Guide for RosaWriter

## Table of Contents
1. [Storage Architecture](#storage-architecture)
2. [Sample Books Management](#sample-books-management)
3. [Schema Migration Strategy](#schema-migration-strategy)
4. [How to Update Sample Books](#how-to-update-sample-books)
5. [How to Add New Fields](#how-to-add-new-fields)
6. [Best Practices](#best-practices)

## Storage Architecture

### Current Setup

RosaWriter uses a hybrid storage approach:

- **SwiftData** for persistent storage
- **JSON serialization** for flexible book data storage
- **Version tracking** for sample books and schema migrations

### Data Models

```
Book (In-Memory) 
  ↓ JSON Serialization
StoryData (SwiftData @Model)
  ↓ Database
SQLite Database
```

### Key Files

- `Book.swift` - In-memory book model
- `BookPage.swift` - In-memory page model
- `StoryData.swift` - SwiftData persistent model
- `StorageService.swift` - Storage and migration logic
- `SampleData.swift` - Hardcoded sample book definitions

## Sample Books Management

### Problem We Solved

Previously, sample books were stored in the database just like user books. This meant:
- ❌ Updates to sample books wouldn't reach existing users
- ❌ Sample books cluttered the user's database
- ❌ No way to refresh sample content without reinstalling

### New Solution

Sample books are now **versioned and managed separately**:

1. **Version Tracking**: Each sample book update increments `currentSampleBooksVersion`
2. **Automatic Updates**: On app launch, sample books are updated if needed
3. **User Reset**: Users can reset sample books via settings
4. **Efficient Queries**: `isSample` field allows fast filtering

### How It Works

```swift
// Version tracking in StorageService.swift
private let currentSampleBooksVersion = 1  // Increment this when updating samples

// On app launch
try StorageService.shared.updateSampleBooksIfNeeded(context: context)

// User-triggered reset
try StorageService.shared.resetSampleBooks(context: context)
```

## Schema Migration Strategy

### Adding New Optional Fields (Recommended for Most Cases)

**When to use**: Adding new features that don't affect existing data

**Steps**:

1. Add the new field to `StoryData.swift` as **optional**:
```swift
@Model
final class StoryData {
  // ... existing fields ...
  
  /// New field - optional for backward compatibility
  var myNewField: String?
}
```

2. Update the initializer to include the new field:
```swift
init(
  // ... existing params ...
  myNewField: String? = nil
) {
  // ... existing assignments ...
  self.myNewField = myNewField
}
```

3. Update `StorageService.saveStoryData()` to populate the field:
```swift
storyData.myNewField = "some value"
```

**Pros**: 
- ✅ Automatic migration (SwiftData handles it)
- ✅ No data loss
- ✅ Works instantly
- ✅ Backward compatible

**Cons**:
- ⚠️ All new fields are optional (need nil checks)

### Using Schema Versioning (For Complex Changes)

**When to use**: Renaming fields, changing types, or complex data transformations

**Steps**:

1. Increment the `schemaVersion` constant in your models:
```swift
// In StoryData.swift
var schemaVersion: Int? = 3  // Was 2, now 3
```

2. Add migration logic to `StorageService.migrateToLatestSchema()`:
```swift
func migrateToLatestSchema(context: ModelContext) throws {
  let fetchDescriptor = FetchDescriptor<StoryData>(
    predicate: #Predicate { story in
      (story.schemaVersion ?? 0) < 3
    }
  )
  
  let oldStories = try context.fetch(fetchDescriptor)
  
  for story in oldStories {
    // Perform migration logic here
    // e.g., transform old field to new field
    story.schemaVersion = 3
  }
  
  try context.save()
}
```

3. Call migration on app launch:
```swift
// In your app initialization
try StorageService.shared.migrateToLatestSchema(context: context)
```

## How to Update Sample Books

### Step 1: Edit Sample Content

Edit the sample books in `SampleData.swift`:

```swift
static func marioAdventure() -> Book {
  var book = Book(title: "Mario's NEW Adventure", isSample: true)
  // ... update pages, text, images ...
  return book
}
```

### Step 2: Increment Version

Update the version number in `StorageService.swift`:

```swift
// Old
private let currentSampleBooksVersion = 1

// New
private let currentSampleBooksVersion = 2
```

### Step 3: Test

Run the app and check the console:

```
📚 Updating sample books to version 2...
✅ Sample books updated successfully!
```

### Step 4: Deploy

Users will automatically get updated sample books on next app launch!

## How to Add New Fields

### Example: Adding a `genre` Field

#### Step 1: Add to Book Model

```swift
// Book.swift
struct Book: Identifiable, Hashable {
  // ... existing fields ...
  var genre: String?  // New field
  
  init(title: String, pages: [BookPage] = [], isSample: Bool = false, genre: String? = nil) {
    // ... existing init ...
    self.genre = genre
  }
}
```

#### Step 2: Add to StoryData Model

```swift
// StoryData.swift
@Model
final class StoryData {
  // ... existing fields ...
  var genre: String?  // New field - optional for migration
}
```

#### Step 3: Update Codable Wrappers

```swift
// StorageService.swift - CodableBook
private struct CodableBook: Codable {
  // ... existing fields ...
  let genre: String?
  
  init(from book: Book) {
    // ... existing ...
    self.genre = book.genre
  }
  
  func toBook() -> Book {
    // ... update to pass genre ...
  }
}
```

#### Step 4: Update Storage Logic

```swift
// StorageService.swift - saveStoryData
if let existingStory = existingStories.first {
  // ... existing updates ...
  existingStory.genre = book.genre
}
```

#### Step 5: Test & Deploy

The field is now available! Existing books will have `nil` for genre, new books can set it.

## Best Practices

### DO ✅

- **Always use optional fields** for new additions
- **Increment schema version** for complex migrations
- **Test migrations** with real data before deploying
- **Document breaking changes** in release notes
- **Use the `isSample` field** to filter sample books efficiently
- **Call `migrateToLatestSchema()`** on app launch

### DON'T ❌

- **Don't remove fields** without migration (data loss!)
- **Don't change field types** without migration
- **Don't assume non-nil values** for optional fields
- **Don't forget to increment** `currentSampleBooksVersion` when updating samples
- **Don't delete user data** without explicit user action

### Query Patterns

```swift
// Get all books (including samples)
let allBooks = try StorageService.shared.loadAllStoryData(context: context)

// Get only user-created books
let userBooks = try StorageService.shared.loadUserStoryData(context: context)

// Get only sample books
let sampleBooks = try StorageService.shared.loadSampleStoryData(context: context)
```

### App Initialization Pattern

```swift
// In your app's main initialization
@MainActor
func initializeApp() async {
  do {
    // 1. Migrate schema if needed
    try StorageService.shared.migrateToLatestSchema(context: context)
    
    // 2. Update sample books if needed
    try StorageService.shared.updateSampleBooksIfNeeded(context: context)
    
    // 3. Check if this is first launch
    let stories = try StorageService.shared.loadAllStoryData(context: context)
    if stories.isEmpty {
      try StorageService.shared.populateWithSampleData(context: context)
    }
  } catch {
    print("❌ Initialization error: \(error)")
  }
}
```

## Migration History

### Schema Version 1 (Initial)
- Basic fields: `id`, `createdAt`, `title`, `coverImage`, `wordCount`, `storyJson`

### Schema Version 2 (Current)
- Added: `schemaVersion`, `isSample`, `lastModified`
- Purpose: Enable efficient sample book filtering and future migrations
- Migration: Auto-parses JSON to populate `isSample` field

### Sample Books Version History
- **Version 1**: Initial sample books (Mario, Luigi, Rosalina, Peach)

---

## Questions?

If you need to make complex schema changes or aren't sure about migration strategy, refer to:
- SwiftData documentation: https://developer.apple.com/documentation/swiftdata
- This guide's examples above
- Ask in code review before deploying breaking changes!
