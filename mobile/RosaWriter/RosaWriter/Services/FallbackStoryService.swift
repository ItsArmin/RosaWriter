//
//  FallbackStoryService.swift
//  RosaWriter
//
//  Created by Armin on 11/15/25.
//

import Foundation

enum FallbackStoryError: LocalizedError {
  case templatesUnavailable
  case noMatchingTemplate

  var errorDescription: String? {
    switch self {
    case .templatesUnavailable:
      "Story generation is temporarily unavailable. Please try again later."
    case .noMatchingTemplate:
      "Unable to create story. Please try a different combination."
    }
  }
}

/// Template-based story generation service for devices without Apple Intelligence
@MainActor
class FallbackStoryService {
  static let shared = FallbackStoryService()

  private let renderer: TemplateRenderer?

  /// Rendering a template is nearly instant, which makes a story feel pulled
  /// off a shelf rather than written. A short pause sells the writing.
  private let writingPause = Duration.seconds(1.5)

  private init() {
    do {
      self.renderer = try TemplateRenderer()
      print("✅ [Fallback] Template renderer initialized successfully")
    } catch {
      print("❌ [Fallback] Failed to initialize template renderer: \(error)")
      print("⚠️ [Fallback] Template-based story generation will not be available")
      self.renderer = nil
    }
  }

  // MARK: - Story Generation

  /// Generate a story using templates
  /// - Parameters:
  ///   - mainCharacter: The main character
  ///   - mood: Story mood
  ///   - theme: Story theme
  ///   - sideCharacter: Optional side character (randomly selected if nil)
  ///   - coverColor: Cover color for the book
  /// - Returns: Generated book
  func generateCustomStory(
    mainCharacter: StoryCharacter,
    mood: StoryMood,
    theme: StoryTheme,
    sideCharacter: StoryCharacter? = nil,
    coverColor: CoverColor? = nil
  ) async throws -> Book {
    try await Task.sleep(for: writingPause)

    print("📚 [Fallback] Template generation starting...")
    print("   Character: \(mainCharacter.displayName)")
    print("   Mood: \(mood.rawValue)")
    print("   Theme: \(theme.rawValue)")

    // Check if renderer is available
    guard let templateRenderer = renderer else {
      print("❌ [Fallback] Template renderer not available - templates could not be loaded")
      print("   This usually means story_templates.json is missing or malformed")

      throw FallbackStoryError.templatesUnavailable
    }

    // Find matching template (with fallback logic)
    guard let template = templateRenderer.findTemplate(mood: mood, theme: theme) else {
      // This should rarely happen now with fallback logic, but just in case
      let available = templateRenderer.availableCombinations()
      let availableStr = available.map { "\($0.mood.rawValue) + \($0.theme.rawValue)" }.joined(
        separator: ", ")

      print("❌ [Fallback] No template found even with fallbacks!")
      print("   Requested: \(mood.rawValue) + \(theme.rawValue)")
      print("   Available combinations: \(availableStr)")

      throw FallbackStoryError.noMatchingTemplate
    }

    print("✅ [Fallback] Found template: \(template.id)")

    // Select random objects
    let objects = StoryAssets.randomObjects(count: 2)
    print("   Using objects: \(objects.map { $0.displayName }.joined(separator: ", "))")

    if let side = sideCharacter {
      print("   Using side character: \(side.displayName)")
    } else {
      print("   Side character will be randomly selected")
    }

    // Render the template
    let renderedStory = templateRenderer.render(
      template: template,
      mainCharacter: mainCharacter,
      sideCharacter: sideCharacter,
      objects: objects,
      enableRandomization: true
    )

    print("✅ [Fallback] Template rendered: \(renderedStory.title)")
    print("   Pages: \(renderedStory.pages.count)")

    // Debug: Print images for each page
    for page in renderedStory.pages {
      print("   Page \(page.pageNumber) images: \(page.suggestedImages)")
    }

    // Convert to Book format
    let book = convertToBook(
      renderedStory: renderedStory,
      mainCharacter: mainCharacter,
      coverColor: coverColor ?? .blue
    )

    print("✅ [Fallback] Story generation complete!")

    return book
  }

  // MARK: - Private Helpers

  private func convertToBook(
    renderedStory: RenderedStory,
    mainCharacter: StoryCharacter,
    coverColor: CoverColor
  ) -> Book {
    let pages = renderedStory.pages.map { page in
      DraftPage(
        pageNumber: page.pageNumber,
        text: page.text,
        assetIDs: page.suggestedImages
      )
    }

    return BookBuilder.makeBook(
      title: renderedStory.title,
      pages: pages,
      mainCharacter: mainCharacter,
      coverColor: coverColor
    )
  }
}
