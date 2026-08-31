# Quick Reference: Storage & Migration

## Summary of Changes

We've implemented a **versioned storage system** with automatic migrations and sample book updates. Here's what changed:

### ✅ What We Added

1. **Sample Book Versioning**: Sample books can now be updated without affecting user data
2. **Schema Migrations**: New fields added with backward compatibility
3. **Efficient Queries**: Added `isSample` field to filter books faster
4. **Auto-Updates**: Sample books update automatically on app launch when new versions are available
5. **User Control**: Users can reset sample books via Settings

### 📁 Files Modified

- `StoryData.swift` - Added: `schemaVersion`, `isSample`, `lastModified`
- `StorageService.swift` - Added: Version tracking, migration logic, new query methods
- `SplashView.swift` - Added: App initialization with migrations
- `SettingsView.swift` - Already had reset button (no changes needed)

---

## Common Tasks

### 1. Update Sample Books

**When**: You want to fix typos, add content, or change sample books

```swift
// Step 1: Edit SampleData.swift
static func marioAdventure() -> Book {
  var book = Book(title: "Mario's NEW Adventure", isSample: true)
  // ... your changes ...
  return book
}

// Step 2: Update version in StorageService.swift
private let currentSampleBooksVersion = 2  // Increment this

// Step 3: Deploy! Users get updates automatically
```

### 2. Add a New Optional Field

**When**: Adding a new feature (e.g., "genre", "rating", "author")

```swift
// Step 1: Add to StoryData.swift
@Model
final class StoryData {
  // ... existing fields ...
  var genre: String?  // ← New field
}

// Step 2: Update init in StoryData.swift
init(
  // ... existing params ...
  genre: String? = nil
) {
  // ... existing ...
  self.genre = genre
}

// Step 3: Update StorageService.saveStoryData()
existingStory.genre = book.genre  // For updates
// or
let storyData = StoryData(
  // ... existing ...
  genre: book.genre
)

// Done! SwiftData handles migration automatically
```

### 3. Query Books

```swift
// Get all books
let all = try StorageService.shared.loadAllStoryData(context: context)

// Get only user-created books
let userBooks = try StorageService.shared.loadUserStoryData(context: context)

// Get only sample books
let samples = try StorageService.shared.loadSampleStoryData(context: context)
```

### 4. Reset Sample Books (User Action)

Already implemented in Settings! Users can tap:
**Settings → Reset Sample Books → Reset**

Programmatically:
```swift
try StorageService.shared.resetSampleBooks(context: modelContext)
```

---

## Version Numbers

### Current Versions

- **Schema Version**: 2
- **Sample Books Version**: 1

### When to Increment

**Schema Version** (in `StoryData.swift`):
- Change: Increment when adding fields or changing structure
- Current: `var schemaVersion: Int? = 2`

**Sample Books Version** (in `StorageService.swift`):
- Change: Increment when updating sample book content
- Current: `private let currentSampleBooksVersion = 1`

---

## Migration Flow (Automatic)

```
App Launch (SplashView)
    ↓
1. migrateToLatestSchema()
   - Checks if stories need schema update
   - Migrates old records to new schema
    ↓
2. updateSampleBooksIfNeeded()
   - Checks sample book version
   - Updates if new version available
    ↓
3. populateWithSampleData() (first launch only)
   - Adds sample books if database empty
    ↓
App Ready!
```

---

## Testing Checklist

Before deploying changes:

- [ ] Increment version number (schema or sample books)
- [ ] Test on fresh install
- [ ] Test on existing install with old data
- [ ] Check console logs for migration messages
- [ ] Verify sample books update correctly
- [ ] Test Settings → Reset Sample Books button
- [ ] Ensure user books are not affected

---

## Console Messages to Look For

**Successful Migration**:
```
🔄 Checking for schema migrations...
✅ All stories are up to date (schema version 2)
📚 Sample books are up to date (version 1)
✅ App initialization complete
```

**First Launch**:
```
📚 First launch detected - populating with sample data
✅ App initialization complete
```

**Sample Book Update**:
```
📚 Updating sample books to version 2...
✅ Sample books updated successfully!
```

---

## Need More Details?

See `STORAGE_AND_MIGRATION_GUIDE.md` for:
- Detailed architecture explanation
- Complex migration scenarios
- Step-by-step field addition guide
- Best practices and gotchas
