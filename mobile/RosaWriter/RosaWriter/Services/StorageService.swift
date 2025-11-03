//
//  StorageService.swift
//  RosaWriter
//
//  Created by Armin on 10/26/25.
//

import Foundation
import SwiftData

@MainActor
class StorageService {
  static let shared = StorageService()

  private init() {}
  
  // MARK: - Sample Book Version Management

  /// Current version of sample books - increment this when you update sample content
  private let currentSampleBooksVersion = 3
  private let sampleBooksVersionKey = "sampleBooksVersion"

  /// Check if sample books need updating
  private func needsSampleBookUpdate() -> Bool {
    let storedVersion = UserDefaults.standard.integer(forKey: sampleBooksVersionKey)
    return storedVersion < currentSampleBooksVersion
  }

  /// Mark sample books as updated to current version
  private func markSampleBooksUpdated() {
    UserDefaults.standard.set(currentSampleBooksVersion, forKey: sampleBooksVersionKey)
  }

  // MARK: - Book to JSON Conversion

  /// Convert a Book to JSON string
  func bookToJson(_ book: Book) throws -> String {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.outputFormatting = .prettyPrinted

    let bookData = CodableBook(from: book)
    let jsonData = try encoder.encode(bookData)

    guard let jsonString = String(data: jsonData, encoding: .utf8) else {
      throw StorageError.encodingFailed
    }

    return jsonString
  }

  /// Convert JSON string back to Book
  func jsonToBook(_ jsonString: String) throws -> Book {
    guard let jsonData = jsonString.data(using: .utf8) else {
      throw StorageError.decodingFailed
    }

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601

    let codableBook = try decoder.decode(CodableBook.self, from: jsonData)
    return codableBook.toBook()
  }

  // MARK: - Storage Operations

  /// Save a book to SwiftData
  func saveStoryData(_ book: Book, context: ModelContext) throws {
    // Convert book to JSON
    let jsonString = try bookToJson(book)

    // Get cover image name if available
    let coverImageName = book.pages.first { $0.isCover }?.imageLayout.imageName

    // Calculate word count
    let wordCount = book.pages.reduce(0) { count, page in
      count + page.text.split(separator: " ").count
    }

    // Check if story already exists
    let bookId = book.id
    let fetchDescriptor = FetchDescriptor<StoryData>(
      predicate: #Predicate { $0.id == bookId }
    )

    let existingStories = try context.fetch(fetchDescriptor)

    if let existingStory = existingStories.first {
      // Update existing story
      existingStory.title = book.title
      existingStory.coverImage = coverImageName
      existingStory.wordCount = wordCount
      existingStory.storyJson = jsonString
      existingStory.isSample = book.isSample
      existingStory.lastModified = Date()
      existingStory.schemaVersion = 2
    } else {
      // Create new story
      let storyData = StoryData(
        id: book.id,
        createdAt: book.createdAt,
        title: book.title,
        coverImage: coverImageName,
        wordCount: wordCount,
        storyJson: jsonString,
        schemaVersion: 2,
        isSample: book.isSample,
        lastModified: Date()
      )
      context.insert(storyData)
    }

    try context.save()
  }

  /// Load a specific book by ID
  func loadStoryData(id: UUID, context: ModelContext) throws -> Book? {
    let storyId = id
    let fetchDescriptor = FetchDescriptor<StoryData>(
      predicate: #Predicate { $0.id == storyId }
    )

    let stories = try context.fetch(fetchDescriptor)
    guard let storyData = stories.first else {
      return nil
    }

    return try jsonToBook(storyData.storyJson)
  }

  /// Load all stories (returns lightweight StoryData for bookshelf view)
  func loadAllStoryData(context: ModelContext) throws -> [StoryData] {
    let fetchDescriptor = FetchDescriptor<StoryData>(
      sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
    )

    return try context.fetch(fetchDescriptor)
  }
  
  /// Load only user-created stories (excludes sample books)
  func loadUserStoryData(context: ModelContext) throws -> [StoryData] {
    let fetchDescriptor = FetchDescriptor<StoryData>(
      predicate: #Predicate { story in
        story.isSample != true
      },
      sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
    )

    return try context.fetch(fetchDescriptor)
  }

  /// Load only sample stories
  func loadSampleStoryData(context: ModelContext) throws -> [StoryData] {
    let fetchDescriptor = FetchDescriptor<StoryData>(
      predicate: #Predicate { story in
        story.isSample == true
      },
      sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
    )

    return try context.fetch(fetchDescriptor)
  }

  /// Load all books (parses JSON for each - use sparingly)
  func loadAllBooks(context: ModelContext) throws -> [Book] {
    let storyDataList = try loadAllStoryData(context: context)

    return storyDataList.compactMap { storyData in
      try? jsonToBook(storyData.storyJson)
    }
  }

  /// Delete a story
  func deleteStoryData(id: UUID, context: ModelContext) throws {
    let storyId = id
    let fetchDescriptor = FetchDescriptor<StoryData>(
      predicate: #Predicate { $0.id == storyId }
    )

    let stories = try context.fetch(fetchDescriptor)
    if let story = stories.first {
      context.delete(story)
      try context.save()
    }
  }

  /// Populate database with sample data (call on first launch)
  func populateWithSampleData(context: ModelContext) throws {
    let sampleBooks = BookService.shared.loadAllSampleBooks()

    for book in sampleBooks {
      try saveStoryData(book, context: context)
    }
    
    markSampleBooksUpdated()
  }

  /// Update sample books if there's a new version available
  func updateSampleBooksIfNeeded(context: ModelContext) throws {
    guard needsSampleBookUpdate() else {
      print("📚 Sample books are up to date (version \(currentSampleBooksVersion))")
      return
    }

    print("📚 Updating sample books to version \(currentSampleBooksVersion)...")

    // Delete all existing sample books
    // Try the efficient way first (using isSample field), fall back to JSON parsing
    let fetchDescriptor = FetchDescriptor<StoryData>(
      predicate: #Predicate { story in
        (story.isSample == true) || story.storyJson.contains("\"isSample\" : true")
          || story.storyJson.contains("\"isSample\":true")
      }
    )

    let sampleStories = try context.fetch(fetchDescriptor)
    for story in sampleStories {
      context.delete(story)
    }

    // Add fresh sample books
    let sampleBooks = BookService.shared.loadAllSampleBooks()
    for book in sampleBooks {
      try saveStoryData(book, context: context)
    }

    try context.save()
    markSampleBooksUpdated()

    print("✅ Sample books updated successfully!")
  }

  /// Reset sample books to their original state (user-triggered action)
  func resetSampleBooks(context: ModelContext) throws {
    print("📚 Resetting sample books...")

    // Delete all existing sample books
    // Try the efficient way first (using isSample field), fall back to JSON parsing
    let fetchDescriptor = FetchDescriptor<StoryData>(
      predicate: #Predicate { story in
        (story.isSample == true) || story.storyJson.contains("\"isSample\" : true")
          || story.storyJson.contains("\"isSample\":true")
      }
    )

    let sampleStories = try context.fetch(fetchDescriptor)
    for story in sampleStories {
      context.delete(story)
    }

    // Recreate them fresh
    let sampleBooks = BookService.shared.loadAllSampleBooks()
    for book in sampleBooks {
      try saveStoryData(book, context: context)
    }

    try context.save()
    markSampleBooksUpdated()

    print("✅ Sample books reset successfully!")
  }

  // MARK: - Migration Utilities

  /// Migrate old StoryData records to the new schema
  /// Call this on app launch to ensure all records are up to date
  func migrateToLatestSchema(context: ModelContext) throws {
    print("🔄 Checking for schema migrations...")

    // Fetch all stories that need migration (schemaVersion < 2 or nil)
    let fetchDescriptor = FetchDescriptor<StoryData>(
      predicate: #Predicate { story in
        (story.schemaVersion ?? 0) < 2
      }
    )

    let oldStories = try context.fetch(fetchDescriptor)

    guard !oldStories.isEmpty else {
      print("✅ All stories are up to date (schema version 2)")
      return
    }

    print("🔄 Migrating \(oldStories.count) stories to schema version 2...")

    for story in oldStories {
      // Parse the JSON to determine if it's a sample book
      if let book = try? jsonToBook(story.storyJson) {
        story.isSample = book.isSample
        story.lastModified = book.updatedAt
      } else {
        story.isSample = false
        story.lastModified = story.createdAt
      }

      story.schemaVersion = 2
    }

    try context.save()
    print("✅ Migration complete!")
  }
}

// MARK: - Helper Types

enum StorageError: LocalizedError {
  case encodingFailed
  case decodingFailed

  var errorDescription: String? {
    switch self {
    case .encodingFailed:
      return "Failed to encode book to JSON"
    case .decodingFailed:
      return "Failed to decode JSON to book"
    }
  }
}

// MARK: - Codable Wrappers

private struct CodableBook: Codable {
  let id: UUID
  let title: String
  let pages: [CodablePage]
  let createdAt: Date
  let updatedAt: Date
  let isSample: Bool

  init(from book: Book) {
    self.id = book.id
    self.title = book.title
    self.pages = book.pages.map { CodablePage(from: $0) }
    self.createdAt = book.createdAt
    self.updatedAt = book.updatedAt
    self.isSample = book.isSample
  }

  func toBook() -> Book {
    let bookPages = pages.map { $0.toBookPage() }
    return Book(
      id: id,
      title: title,
      pages: bookPages,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isSample: isSample
    )
  }
}

private struct CodablePage: Codable {
  let id: UUID
  let text: String
  let pageNumber: Int
  let imageLayout: CodableImageLayout
  let isCover: Bool
  let coverColor: String?
  let createdAt: Date
  let updatedAt: Date

  init(from page: BookPage) {
    self.id = page.id
    self.text = page.text
    self.pageNumber = page.pageNumber
    self.imageLayout = CodableImageLayout(from: page.imageLayout)
    self.isCover = page.isCover
    self.coverColor = page.coverColor?.rawValue
    self.createdAt = page.createdAt
    self.updatedAt = page.updatedAt
  }

  func toBookPage() -> BookPage {
    BookPage(
      id: id,
      text: text,
      pageNumber: pageNumber,
      imageLayout: imageLayout.toPageImageLayout(),
      isCover: isCover,
      coverColor: coverColor.flatMap { CoverColor(rawValue: $0) },
      createdAt: createdAt,
      updatedAt: updatedAt
    )
  }
}

private enum CodableImageLayout: Codable {
  case none
  case single(imageName: String)
  case staggered(topImage: String, bottomImage: String)

  init(from layout: PageImageLayout) {
    switch layout {
    case .none:
      self = .none
    case .single(let imageName):
      self = .single(imageName: imageName)
    case .staggered(let topImage, let bottomImage):
      self = .staggered(topImage: topImage, bottomImage: bottomImage)
    }
  }

  func toPageImageLayout() -> PageImageLayout {
    switch self {
    case .none:
      return .none
    case .single(let imageName):
      return .single(imageName: imageName)
    case .staggered(let topImage, let bottomImage):
      return .staggered(topImage: topImage, bottomImage: bottomImage)
    }
  }
}

// MARK: - PageImageLayout Extension

extension PageImageLayout {
  var imageName: String? {
    switch self {
    case .none:
      return nil
    case .single(let imageName):
      return imageName
    case .staggered(let topImage, _):
      return topImage  // Return the first image as the cover image
    }
  }
}
