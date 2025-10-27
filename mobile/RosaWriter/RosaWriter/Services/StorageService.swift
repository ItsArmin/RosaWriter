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
    } else {
      // Create new story
      let storyData = StoryData(
        id: book.id,
        createdAt: book.createdAt,
        title: book.title,
        coverImage: coverImageName,
        wordCount: wordCount,
        storyJson: jsonString
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

  init(from book: Book) {
    self.id = book.id
    self.title = book.title
    self.pages = book.pages.map { CodablePage(from: $0) }
    self.createdAt = book.createdAt
    self.updatedAt = book.updatedAt
  }

  func toBook() -> Book {
    let bookPages = pages.map { $0.toBookPage() }
    return Book(
      id: id,
      title: title,
      pages: bookPages,
      createdAt: createdAt,
      updatedAt: updatedAt
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
