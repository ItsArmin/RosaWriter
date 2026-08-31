//
//  BookService.swift
//  RosaWriter
//
//  Created by Armin on 10/19/25.
//

import Foundation

@MainActor
class BookService {
  static let shared = BookService()

  private init() {}

  func loadAllSampleBooks() -> [Book] {
    return SampleData.allSampleBooks
  }

  // MARK: - Story Creation

  /// Writes a book for the given request, preferring Apple Intelligence and
  /// falling back to the bundled templates when it is unavailable or fails.
  func makeBook(for request: StoryRequest) async throws -> Book {
    var book = try await generateStory(for: request)

    // A user-made character can be edited or deleted later, so the book takes
    // its own copy of the photo rather than pointing at the character's.
    if let photo = request.customPhoto {
      let snapshot = try await BookImageSnapshotService.shared.createSnapshot(
        sourceFileName: photo.fileName,
        crop: photo.crop,
        bookID: book.id
      )
      book.replaceImageReference(
        request.mainCharacter.imageName,
        with: snapshot.storedValue
      )
    }

    return book
  }

  private func generateStory(for request: StoryRequest) async throws -> Book {
    let pageCount = AppConstants.randomAIBookPageCount

    if AIStoryService.isAppleIntelligenceAvailable() {
      do {
        return try await AIStoryService.shared.generateCustomStory(
          mainCharacter: request.mainCharacter,
          mood: request.mood,
          spark: request.spark,
          pageCount: pageCount,
          coverColor: request.coverColor
        )
      } catch {
        print("⚠️ [Books] Apple Intelligence failed, using templates: \(error)")
      }
    }

    return try await FallbackStoryService.shared.generateCustomStory(
      mainCharacter: request.mainCharacter,
      mood: request.mood,
      theme: theme(for: request.spark),
      coverColor: request.coverColor
    )
  }

  /// The template library is organized by theme rather than by spark.
  private func theme(for spark: StorySpark) -> StoryTheme {
    switch spark {
    case .birthday:
      return .birthday
    case .treasureHunt, .magicalDiscovery, .lostAndFound:
      return .adventure
    case .helpingFriend, .buildingSomething:
      return .friendship
    case .solvingProblem:
      return .mystery
    case .findingFood:
      return .celebration
    case .random:
      return StoryTheme.allCases.randomElement() ?? .adventure
    }
  }
}
