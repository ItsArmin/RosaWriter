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
private let forceUseFallback = true

enum AIStoryError: Error {
  case generationFailed
  case parsingFailed
  case invalidResponse
  case notAvailable

  var localizedDescription: String {
    switch self {
    case .generationFailed:
      return "Failed to generate story"
    case .parsingFailed:
      return "Failed to parse AI response"
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
          print("🔍 Apple Intelligence availability check: ❌ Not Available (Device doesn't support Apple Intelligence)")
        }
        return isAvailable
      #endif
    #else
      print("🔍 Apple Intelligence availability check: ❌ FoundationModels framework not available")
      return false
    #endif
  }

  // MARK: - Story Generation

  /// Generate a new story using Apple Intelligence
  func generateStory(
    pageCount: Int = 5,
    theme: String? = nil,
    coverColor: CoverColor? = nil
  ) async throws -> Book {
    isGenerating = true
    progress = 0.0
    defer {
      isGenerating = false
      progress = 0.0
    }

    // Generate the prompt
    let prompt = StoryPrompts.randomStoryPrompt(
      pageCount: pageCount,
      theme: theme
    )
    progress = 0.1

    // Retry logic for AI generation (sometimes first attempts fail)
    var lastError: Error?
    for attempt in 1...3 {
      do {
        print("📝 Generation attempt \(attempt)/3")

        // Call Apple Intelligence API
        let response = try await callAppleIntelligence(prompt: prompt)
        progress = 0.5 + (0.2 * Double(attempt) / 3.0)

        // Parse the response
        let aiStory = try parseAIResponse(response)
        progress = 0.9

        // Convert to Book format
        let book = convertToBook(aiStory, coverColor: coverColor ?? .blue)
        progress = 1.0

        return book
      } catch {
        lastError = error
        print("⚠️ Attempt \(attempt) failed: \(error.localizedDescription)")
        if attempt < 3 {
          print("🔄 Retrying...")
          try? await Task.sleep(nanoseconds: 500_000_000)  // 0.5 second delay
        }
      }
    }

    // All attempts failed
    throw lastError ?? AIStoryError.generationFailed
  }

  /// Generate a story with specific characters and objects
  func generateStoryWithAssets(
    characters: [StoryCharacter],
    objects: [StoryObject],
    pageCount: Int = 5,
    theme: String? = nil,
    coverColor: CoverColor? = nil
  ) async throws -> Book {
    isGenerating = true
    progress = 0.0
    defer {
      isGenerating = false
      progress = 0.0
    }

    let prompt = StoryPrompts.generateStoryPrompt(
      characters: characters,
      objects: objects,
      pageCount: pageCount,
      theme: theme
    )
    progress = 0.1

    // Retry logic for AI generation (sometimes first attempts fail)
    var lastError: Error?
    for attempt in 1...3 {
      do {
        print("📝 Generation attempt \(attempt)/3")

        let response = try await callAppleIntelligence(prompt: prompt)
        progress = 0.5 + (0.2 * Double(attempt) / 3.0)

        let aiStory = try parseAIResponse(response)
        progress = 0.9

        let book = convertToBook(aiStory, coverColor: coverColor ?? .blue)
        progress = 1.0

        return book
      } catch {
        lastError = error
        print("⚠️ Attempt \(attempt) failed: \(error.localizedDescription)")
        if attempt < 3 {
          print("🔄 Retrying...")
          try? await Task.sleep(nanoseconds: 500_000_000)  // 0.5 second delay
        }
      }
    }

    // All attempts failed
    throw lastError ?? AIStoryError.generationFailed
  }

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

        let response = try await callAppleIntelligence(prompt: prompt)
        progress = 0.5 + (0.2 * Double(attempt) / 3.0)

        let aiStory = try parseAIResponse(response)
        progress = 0.9

        let book = convertToBook(aiStory, coverColor: coverColor ?? .blue)
        progress = 1.0

        return book
      } catch {
        lastError = error
        print("⚠️ Attempt \(attempt) failed: \(error.localizedDescription)")
        if attempt < 3 {
          print("🔄 Retrying...")
          try? await Task.sleep(nanoseconds: 500_000_000)  // 0.5 second delay
        }
      }
    }

    // All attempts failed
    throw lastError ?? AIStoryError.generationFailed
    }

  // MARK: - Private Methods

  private func callAppleIntelligence(prompt: String) async throws -> String {
    #if canImport(FoundationModels)
      // Use Apple Intelligence on-device model
      let model = SystemLanguageModel.default

      guard model.isAvailable else {
        print("⚠️ Apple Intelligence model is not available on this device")
        throw AIStoryError.notAvailable
      }

      print("✅ Apple Intelligence is available, generating story...")

      // Create a language model session
      let session = LanguageModelSession()

      // Build the full prompt with system context
      let fullPrompt = """
        \(StoryPrompts.systemPrompt)

        \(prompt)
        """

      print("📝 Sending prompt to Apple Intelligence...")

      // Get response from Apple Intelligence
      let response = try await session.respond(to: fullPrompt)

      print("✅ Received response from Apple Intelligence")

      return response.content
    #else
      // FoundationModels not available in this build
      print("❌ FoundationModels framework not available")
      throw AIStoryError.notAvailable
    #endif
  }

  private func parseAIResponse(_ response: String) throws -> AIStoryResponse {
    print("📖 Parsing AI response...")
    print("📏 Response length: \(response.count) characters")

    // Remove markdown code blocks if present
    var cleanedResponse =
      response
      .replacingOccurrences(of: "```json", with: "")
      .replacingOccurrences(of: "```", with: "")
      .trimmingCharacters(in: .whitespacesAndNewlines)

    // Try to extract JSON if there's extra text before/after
    if let jsonStart = cleanedResponse.firstIndex(of: "{"),
      let jsonEnd = cleanedResponse.lastIndex(of: "}")
    {
      cleanedResponse = String(cleanedResponse[jsonStart...jsonEnd])
    }

    // Parse JSON
    guard let data = cleanedResponse.data(using: .utf8) else {
      print("❌ Failed to convert response to UTF-8 data")
      throw AIStoryError.parsingFailed
    }

    let decoder = JSONDecoder()
    do {
      let aiStory = try decoder.decode(AIStoryResponse.self, from: data)
      print("✅ Successfully parsed story: '\(aiStory.title)' with \(aiStory.pages.count) pages")
      return aiStory
    } catch {
      print("❌ JSON parsing failed: \(error)")
      print("📄 Full response:")
      print(cleanedResponse)
      print("---")
      throw AIStoryError.parsingFailed
        }
    }

  private func convertToBook(
    _ aiStory: AIStoryResponse,
    coverColor: CoverColor
  ) -> Book {
    var book = Book(title: aiStory.title)

    // Create cover page
    let coverImage = selectCoverImage(from: aiStory)
    let coverPage = BookPage(
      text: aiStory.title,
      pageNumber: 0,
      imageLayout: coverImage.map { .single(imageName: $0) } ?? .none,
      isCover: true,
      coverColor: coverColor
    )
    book.addPage(coverPage)

    // Create content pages
    for aiPage in aiStory.pages {
      let imageLayout = determineImageLayout(from: aiPage.suggestedImages)
      let page = BookPage(
        text: aiPage.text,
        pageNumber: aiPage.pageNumber,
        imageLayout: imageLayout
      )
      book.addPage(page)
    }

    return book
  }

  private func selectCoverImage(from story: AIStoryResponse) -> String? {
    // Try to find a main character from the first page
    guard let firstPage = story.pages.first else { return nil }

    for assetId in firstPage.suggestedImages {
      if let character = StoryAssets.character(for: assetId) {
        return character.imageName
      }
    }

    return nil
  }

  private func determineImageLayout(from suggestedImages: [String])
    -> PageImageLayout
  {
    let validImages = suggestedImages.compactMap { assetId -> String? in
      if let character = StoryAssets.character(for: assetId) {
        return character.imageName
      } else if let object = StoryAssets.object(for: assetId) {
        return object.imageName
      }
      return nil
    }

    switch validImages.count {
    case 0:
      return .none
    case 1:
      return .single(imageName: validImages[0])
    case 2...:
      return .staggered(
        topImage: validImages[0],
        bottomImage: validImages[1]
      )
    default:
      return .none
    }
  }
}
