//
//  AIStoryService.swift
//  RosaWriter
//
//  Created by Armin on 10/26/25.
//

import Combine
import Foundation
import SwiftUI

#if canImport(FoundationModels)
  import FoundationModels
#endif

// 🔧 DEBUG: Set to true to force fallback to template stories (even on devices with Apple Intelligence)
private let forceUseFallback = false

enum AIStoryError: Error {
  case generationFailed
  case invalidResponse
  case notAvailable

  var localizedDescription: String {
    switch self {
    case .generationFailed:
      return "Failed to generate story"
    case .invalidResponse:
      return "Invalid response from AI"
    case .notAvailable:
      return "AI features not available on this device"
    }
  }
}

@MainActor
class AIStoryService: ObservableObject {
  static let shared = AIStoryService()

  @Published var isGenerating = false
  @Published var progress: Double = 0.0

  private init() {}

  // MARK: - Availability Check

  /// Check if Apple Intelligence is available on this device
  /// Note: iOS Simulator does NOT support Apple Intelligence, even if your Mac does
  static func isAppleIntelligenceAvailable() -> Bool {
    // Debug override to force fallback
    if forceUseFallback {
      print("🔍 Apple Intelligence availability check: ❌ Forced OFF (debug flag)")
      return false
    }

    #if canImport(FoundationModels)
      let model = SystemLanguageModel.default
      let isAvailable = model.isAvailable

      #if targetEnvironment(simulator)
        print("🔍 Apple Intelligence availability check: ❌ Not Available (iOS Simulator)")
        print("   Note: Simulator does not support Apple Intelligence - use a physical device")
        return false
      #else
        if isAvailable {
          print("🔍 Apple Intelligence availability check: ✅ Available (Physical Device)")
        } else {
          print(
            "🔍 Apple Intelligence availability check: ❌ Not Available (Device doesn't support Apple Intelligence)"
          )
        }
        return isAvailable
      #endif
    #else
      print("🔍 Apple Intelligence availability check: ❌ FoundationModels framework not available")
      return false
    #endif
  }

  // MARK: - Story Generation

  /// Generate a custom story with user-selected options
  func generateCustomStory(
    mainCharacter: StoryCharacter,
    mood: StoryMood,
    spark: StorySpark,
    pageCount: Int = 5,
    coverColor: CoverColor? = nil
  ) async throws -> Book {
    isGenerating = true
    progress = 0.0
    defer {
      isGenerating = false
      progress = 0.0
    }

    print("🎨 Generating custom story...")
    print("   Character: \(mainCharacter.displayName)")
    print("   Mood: \(mood.rawValue)")
    print("   Spark: \(spark.rawValue)")

    let prompt = StoryPrompts.generateCustomStoryPrompt(
      mainCharacter: mainCharacter,
      mood: mood,
      spark: spark,
      pageCount: pageCount
    )
    progress = 0.1

    // Retry logic for AI generation (sometimes first attempts fail)
    var lastError: Error?
    for attempt in 1...3 {
      do {
        print("📝 Generation attempt \(attempt)/3")

        let aiStory = try await callAppleIntelligence(
          prompt: prompt,
          expectedPageCount: pageCount
        )
        progress = 0.5 + (0.2 * Double(attempt) / 3.0)

        progress = 0.9

        let book = convertToBook(
          aiStory, mainCharacter: mainCharacter, coverColor: coverColor ?? .blue)
        progress = 1.0

        return book
      } catch {
        lastError = error
        print("⚠️ Attempt \(attempt) failed: \(error.localizedDescription)")
        if attempt < 3 {
          print("🔄 Retrying...")
          try? await Task.sleep(for: .milliseconds(500))
        }
      }
    }

    // All attempts failed
    throw lastError ?? AIStoryError.generationFailed
  }

  // MARK: - Private Methods

  private func callAppleIntelligence(
    prompt: String,
    expectedPageCount: Int
  ) async throws -> AIStoryResponse {
    #if canImport(FoundationModels)
      // Use Apple Intelligence on-device model
      let model = SystemLanguageModel.default

      guard model.isAvailable else {
        print("⚠️ Apple Intelligence model is not available on this device")
        throw AIStoryError.notAvailable
      }

      print("✅ Apple Intelligence is available, generating story...")

      let session = LanguageModelSession {
        StoryPrompts.systemPrompt
      }

      print("📝 Sending prompt to Apple Intelligence...")

      let response = try await session.respond(
        to: prompt,
        generating: AIStoryResponse.self
      )

      print("✅ Received response from Apple Intelligence")

      return try validated(
        response.content,
        expectedPageCount: expectedPageCount
      )
    #else
      // FoundationModels not available in this build
      print("❌ FoundationModels framework not available")
      throw AIStoryError.notAvailable
    #endif
  }

  private func validated(
    _ story: AIStoryResponse,
    expectedPageCount: Int
  ) throws -> AIStoryResponse {
    guard !story.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
      story.pages.count == expectedPageCount
    else {
      throw AIStoryError.invalidResponse
    }

    let sortedPages = story.pages.sorted { $0.pageNumber < $1.pageNumber }
    for (index, page) in sortedPages.enumerated() {
      guard page.pageNumber == index + 1,
        !page.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      else {
        throw AIStoryError.invalidResponse
      }
    }

    var validatedStory = story
    validatedStory.pages = sortedPages
    return validatedStory
  }

  private func convertToBook(
    _ aiStory: AIStoryResponse,
    mainCharacter: StoryCharacter,
    coverColor: CoverColor
  ) -> Book {
    let pages = aiStory.pages.map { page in
      DraftPage(
        pageNumber: page.pageNumber,
        text: page.text,
        assetIDs: assetIDs(for: page, mainCharacter: mainCharacter)
      )
    }

    return BookBuilder.makeBook(
      title: aiStory.title,
      pages: pages,
      mainCharacter: mainCharacter,
      coverColor: coverColor
    )
  }

  /// The model picks its own illustrations, except that page 1 always shows
  /// the main character.
  private func assetIDs(
    for page: AIStoryPage,
    mainCharacter: StoryCharacter
  ) -> [String] {
    let suggested = page.suggestedImages.map {
      $0.assetID(mainCharacterID: mainCharacter.id)
    }

    guard page.pageNumber == 1, !suggested.contains(mainCharacter.id) else {
      return suggested
    }

    return Array(([mainCharacter.id] + suggested).prefix(2))
  }
}
