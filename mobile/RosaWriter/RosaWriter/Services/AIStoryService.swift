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

    // Call Apple Intelligence API
    // Note: This is where you'll integrate with Apple's Writing Tools or Intelligence API
    // For now, we'll create a placeholder that simulates the process

    let response = try await callAppleIntelligence(prompt: prompt)
    progress = 0.7

    // Parse the response
    let aiStory = try parseAIResponse(response)
    progress = 0.9

    // Convert to Book format
    let book = convertToBook(aiStory, coverColor: coverColor ?? .blue)
    progress = 1.0

    return book
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

    let response = try await callAppleIntelligence(prompt: prompt)
    progress = 0.7

    let aiStory = try parseAIResponse(response)
    progress = 0.9

    let book = convertToBook(aiStory, coverColor: coverColor ?? .blue)
    progress = 1.0

    return book
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

    // Remove markdown code blocks if present
    var cleanedResponse =
      response
      .replacingOccurrences(of: "```json", with: "")
      .replacingOccurrences(of: "```", with: "")
      .trimmingCharacters(in: .whitespacesAndNewlines)

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
      print("📄 Response preview: \(cleanedResponse.prefix(200))...")
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
