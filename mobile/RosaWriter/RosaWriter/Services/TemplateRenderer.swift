//
//  TemplateRenderer.swift
//  RosaWriter
//
//  Created by Armin on 11/15/25.
//

import Foundation

/// Renders story templates by substituting placeholders and applying optional randomization
class TemplateRenderer {

  private let templateBank: TemplateBank

  // MARK: - Initialization

  init() throws {
    // Load template bank from bundle
    guard let url = Bundle.main.url(forResource: "story_templates", withExtension: "json") else {
      throw TemplateError.fileNotFound
    }

    let data = try Data(contentsOf: url)
    self.templateBank = try JSONDecoder().decode(TemplateBank.self, from: data)

    print(
      "✅ [TemplateRenderer] Loaded \(templateBank.templates.count) templates (v\(templateBank.version))"
    )
  }

  // MARK: - Template Selection
  
  /// Explicit mapping of mood+theme combinations to template mood+theme
  /// This ensures every user selection maps to an intentionally chosen template
  private static let templateMappings: [String: (mood: StoryMood, theme: StoryTheme)] = [
    // Fantasy mood mappings
    "Fantasy+Birthday": (.adventure, .birthday),      // Birthday adventure with magical elements
    "Fantasy+Adventure": (.fantasy, .adventure),      // Direct match
    "Fantasy+Friendship": (.friendship, .friendship), // Friendship focus
    "Fantasy+Mystery": (.mystery, .mystery),          // Mystery with wonder
    "Fantasy+Learning": (.learning, .learning),       // Learning with imagination
    "Fantasy+Celebration": (.silly, .celebration),    // Fun celebration
    
    // Silly mood mappings
    "Silly+Birthday": (.adventure, .birthday),        // Fun birthday adventure
    "Silly+Adventure": (.adventure, .adventure),      // Silly adventure
    "Silly+Friendship": (.friendship, .adventure),    // Fun with friends
    "Silly+Mystery": (.mystery, .mystery),            // Silly mystery
    "Silly+Learning": (.learning, .learning),         // Fun learning
    "Silly+Celebration": (.silly, .celebration),      // Direct match
    
    // Learning mood mappings
    "Learning+Birthday": (.adventure, .birthday),     // Learning through birthday fun
    "Learning+Adventure": (.adventure, .adventure),   // Learning expedition
    "Learning+Friendship": (.friendship, .friendship),// Learning about friendship
    "Learning+Mystery": (.mystery, .mystery),         // Mystery solving = learning
    "Learning+Learning": (.learning, .learning),      // Direct match
    "Learning+Celebration": (.silly, .celebration),   // Celebration of learning
    
    // Courage mood mappings
    "Courage+Birthday": (.adventure, .birthday),      // Brave birthday quest
    "Courage+Adventure": (.courage, .adventure),      // Direct match
    "Courage+Friendship": (.kindness, .friendship),   // Courage to help friends
    "Courage+Mystery": (.mystery, .mystery),          // Brave detective
    "Courage+Learning": (.learning, .learning),       // Courage to learn new things
    "Courage+Celebration": (.silly, .celebration),    // Celebrating bravery
    
    // Friendship mood mappings
    "Friendship+Birthday": (.adventure, .birthday),   // Birthday with friends
    "Friendship+Adventure": (.friendship, .adventure),// Direct match
    "Friendship+Friendship": (.friendship, .friendship),// Direct match
    "Friendship+Mystery": (.mystery, .mystery),       // Friends solve mystery together
    "Friendship+Learning": (.learning, .learning),    // Learning together
    "Friendship+Celebration": (.silly, .celebration), // Celebrating friendship
    
    // Adventure mood mappings
    "Adventure+Birthday": (.adventure, .birthday),    // Direct match
    "Adventure+Adventure": (.adventure, .adventure),  // Direct match
    "Adventure+Friendship": (.friendship, .adventure),// Adventure with friends
    "Adventure+Mystery": (.mystery, .mystery),        // Mystery adventure
    "Adventure+Learning": (.learning, .learning),     // Learning adventure
    "Adventure+Celebration": (.silly, .celebration),  // Adventure celebration
    
    // Mystery mood mappings
    "Mystery+Birthday": (.adventure, .birthday),      // Birthday mystery hunt
    "Mystery+Adventure": (.mystery, .mystery),        // Mystery adventure
    "Mystery+Friendship": (.kindness, .friendship),   // Mystery with friends
    "Mystery+Mystery": (.mystery, .mystery),          // Direct match
    "Mystery+Learning": (.learning, .learning),       // Learning through mystery
    "Mystery+Celebration": (.silly, .celebration),    // Mystery party
    
    // Kindness mood mappings
    "Kindness+Birthday": (.adventure, .birthday),     // Kind birthday gestures
    "Kindness+Adventure": (.kindness, .friendship),   // Helping on adventure
    "Kindness+Friendship": (.kindness, .friendship),  // Direct match
    "Kindness+Mystery": (.mystery, .mystery),         // Kind resolution to mystery
    "Kindness+Learning": (.learning, .learning),      // Learning kindness
    "Kindness+Celebration": (.silly, .celebration),   // Celebrating kindness
  ]

  /// Find a template matching the given criteria
  /// Priority: 1) Explicit mapping, 2) Exact match, 3) Mood match, 4) Theme match, 5) Random
  func findTemplate(mood: StoryMood, theme: StoryTheme, preferredPageCount: Int? = nil) -> StoryTemplate? {
    let templates = templateBank.templates
    let key = "\(mood.rawValue)+\(theme.rawValue)"
    
    // 1. Check explicit mapping first
    if let mapping = Self.templateMappings[key] {
      let candidates = templates.filter { $0.mood == mapping.mood && $0.theme == mapping.theme }
      if !candidates.isEmpty {
        print("📖 [TemplateRenderer] Using mapped template: \(key) → \(mapping.mood.rawValue)+\(mapping.theme.rawValue)")
        return selectByPageCount(from: candidates, preferredPageCount: preferredPageCount)
      }
    }
    
    // 2. Try exact match (mood + theme)
    var candidates = templates.filter { $0.mood == mood && $0.theme == theme }
    if !candidates.isEmpty {
      print("📖 [TemplateRenderer] Found exact match for \(key)")
      return selectByPageCount(from: candidates, preferredPageCount: preferredPageCount)
    }
    
    // 3. If no exact match, try mood match only
    candidates = templates.filter { $0.mood == mood }
    if !candidates.isEmpty {
      print("⚠️ [TemplateRenderer] No exact match for \(key), using mood match")
      return selectByPageCount(from: candidates, preferredPageCount: preferredPageCount)
    }
    
    // 4. If still no match, try theme match only
    candidates = templates.filter { $0.theme == theme }
    if !candidates.isEmpty {
      print("⚠️ [TemplateRenderer] No mood match, using theme match for \(theme.rawValue)")
      return selectByPageCount(from: candidates, preferredPageCount: preferredPageCount)
    }
    
    // 5. If still no match, use any template
    print("⚠️ [TemplateRenderer] No mood/theme match, using random template")
    return selectByPageCount(from: templates, preferredPageCount: preferredPageCount)
  }
  
  /// Helper to select template by page count preference
  private func selectByPageCount(from candidates: [StoryTemplate], preferredPageCount: Int?) -> StoryTemplate? {
    guard !candidates.isEmpty else { return nil }
    
    if let pageCount = preferredPageCount {
      let pageMatches = candidates.filter { $0.pageCount == pageCount }
      if !pageMatches.isEmpty {
        return pageMatches.randomElement()
      }
    }
    return candidates.randomElement()
  }

  /// Get all available mood + theme combinations
  func availableCombinations() -> [(mood: StoryMood, theme: StoryTheme)] {
    return templateBank.templates.map { ($0.mood, $0.theme) }
  }

  // MARK: - Rendering

  /// Render a story from template with user selections
  /// - Parameters:
  ///   - template: The template to render
  ///   - mainCharacter: Main character
  ///   - sideCharacter: Side character (optional, randomly selected if nil)
  ///   - objects: List of objects (1-3 items)
  ///   - enableRandomization: Whether to use text/image variants
  /// - Returns: Rendered story ready for display
  func render(
    template: StoryTemplate,
    mainCharacter: StoryCharacter,
    sideCharacter: StoryCharacter? = nil,
    objects: [StoryObject],
    enableRandomization: Bool = true
  ) -> RenderedStory {
            // Select side character if not provided
        let selectedSideCharacter = sideCharacter ?? selectRandomSideCharacter(excluding: mainCharacter)
        
        // Choose title (variant or original)
        var titleTemplate = template.title
        if enableRandomization,
           let variants = template.titleVariants,
           !variants.isEmpty {
            // Randomly pick a variant or use original
            let allTitleOptions = [template.title] + variants
            titleTemplate = allTitleOptions.randomElement() ?? template.title
        }
        
        // Render title with placeholders
        let renderedTitle = substitutePlaceholders(
            in: titleTemplate,
            mainCharacter: mainCharacter,
            sideCharacter: selectedSideCharacter,
            objects: objects
        )

    // Render pages
    let renderedPages = template.pages.map { templatePage in
      renderPage(
        templatePage,
        mainCharacter: mainCharacter,
        sideCharacter: selectedSideCharacter,
        objects: objects,
        enableRandomization: enableRandomization
      )
    }

    return RenderedStory(
      title: renderedTitle,
      pages: renderedPages,
      templateId: template.id
    )
  }

  // MARK: - Private Helpers

  private func renderPage(
    _ templatePage: TemplatePage,
    mainCharacter: StoryCharacter,
    sideCharacter: StoryCharacter,
    objects: [StoryObject],
    enableRandomization: Bool
  ) -> RenderedPage {
    // Choose text (variant or original)
    var text = templatePage.text
    if enableRandomization,
      let variants = templatePage.textVariants,
      !variants.isEmpty
    {
      // Randomly pick a variant or use original
      let allOptions = [templatePage.text] + variants
      text = allOptions.randomElement() ?? templatePage.text
    }

    // Substitute placeholders in text
    let renderedText = substitutePlaceholders(
      in: text,
      mainCharacter: mainCharacter,
      sideCharacter: sideCharacter,
      objects: objects
    )

    // Choose images (variant or original)
    var images = templatePage.suggestedImages
    if enableRandomization,
      let imageVariants = templatePage.imageVariants,
      !imageVariants.isEmpty,
      Bool.random()
    {
      images = imageVariants.randomElement() ?? templatePage.suggestedImages
    }

    // Substitute placeholders in images and convert to asset IDs
    let renderedImages = images.compactMap { placeholder -> String? in
      substituteImagePlaceholder(
        placeholder,
        mainCharacter: mainCharacter,
        sideCharacter: sideCharacter,
        objects: objects
      )
    }

    return RenderedPage(
      pageNumber: templatePage.pageNumber,
      text: renderedText,
      suggestedImages: renderedImages
    )
  }

  private func substitutePlaceholders(
    in text: String,
    mainCharacter: StoryCharacter,
    sideCharacter: StoryCharacter,
    objects: [StoryObject]
  ) -> String {
    var result = text

    // Main character substitutions
    result = result.replacingOccurrences(
      of: TemplatePlaceholders.mainCharacter,
      with: mainCharacter.displayName
    )
    result = result.replacingOccurrences(
      of: TemplatePlaceholders.mainCharacterPronounSubjective,
      with: mainCharacter.pronounSubjective
    )
    result = result.replacingOccurrences(
      of: TemplatePlaceholders.mainCharacterPronounPossessive,
      with: mainCharacter.pronounPossessive
    )
    result = result.replacingOccurrences(
      of: TemplatePlaceholders.mainCharacterPronounObjective,
      with: mainCharacter.pronounObjective
    )
    
    // Main character voice substitutions
    result = result.replacingOccurrences(
      of: TemplatePlaceholders.mainCharacterGreeting,
      with: mainCharacter.voice.randomGreeting()
    )
    result = result.replacingOccurrences(
      of: TemplatePlaceholders.mainCharacterFarewell,
      with: mainCharacter.voice.randomFarewell()
    )
    result = result.replacingOccurrences(
      of: TemplatePlaceholders.mainCharacterExcited,
      with: mainCharacter.voice.randomExcited()
    )
    result = result.replacingOccurrences(
      of: TemplatePlaceholders.mainCharacterThinking,
      with: mainCharacter.voice.randomThinking()
    )
    result = result.replacingOccurrences(
      of: TemplatePlaceholders.mainCharacterAgreement,
      with: mainCharacter.voice.randomAgreement()
    )
    result = result.replacingOccurrences(
      of: TemplatePlaceholders.mainCharacterSurprise,
      with: mainCharacter.voice.randomSurprise()
    )

    // Side character substitutions
    result = result.replacingOccurrences(
      of: TemplatePlaceholders.sideCharacter,
      with: sideCharacter.displayName
    )
    result = result.replacingOccurrences(
      of: TemplatePlaceholders.sideCharacterPronounSubjective,
      with: sideCharacter.pronounSubjective
    )
    result = result.replacingOccurrences(
      of: TemplatePlaceholders.sideCharacterPronounPossessive,
      with: sideCharacter.pronounPossessive
    )
    result = result.replacingOccurrences(
      of: TemplatePlaceholders.sideCharacterPronounObjective,
      with: sideCharacter.pronounObjective
    )
    
    // Side character voice substitutions
    result = result.replacingOccurrences(
      of: TemplatePlaceholders.sideCharacterGreeting,
      with: sideCharacter.voice.randomGreeting()
    )
    result = result.replacingOccurrences(
      of: TemplatePlaceholders.sideCharacterFarewell,
      with: sideCharacter.voice.randomFarewell()
    )
    result = result.replacingOccurrences(
      of: TemplatePlaceholders.sideCharacterExcited,
      with: sideCharacter.voice.randomExcited()
    )
    result = result.replacingOccurrences(
      of: TemplatePlaceholders.sideCharacterThinking,
      with: sideCharacter.voice.randomThinking()
    )
    result = result.replacingOccurrences(
      of: TemplatePlaceholders.sideCharacterAgreement,
      with: sideCharacter.voice.randomAgreement()
    )
    result = result.replacingOccurrences(
      of: TemplatePlaceholders.sideCharacterSurprise,
      with: sideCharacter.voice.randomSurprise()
    )

    // Object substitutions (with article - for first mention)
    if objects.count > 0 {
      result = result.replacingOccurrences(
        of: TemplatePlaceholders.object1WithArticle,
        with: objects[0].displayNameWithArticle
      )
    }
    if objects.count > 1 {
      result = result.replacingOccurrences(
        of: TemplatePlaceholders.object2WithArticle,
        with: objects[1].displayNameWithArticle
      )
    }
    if objects.count > 2 {
      result = result.replacingOccurrences(
        of: TemplatePlaceholders.object3WithArticle,
        with: objects[2].displayNameWithArticle
      )
    }
    
    // Object substitutions (without article - for subsequent mentions)
    if objects.count > 0 {
      result = result.replacingOccurrences(
        of: TemplatePlaceholders.object1,
        with: objects[0].displayName
      )
    }
    if objects.count > 1 {
      result = result.replacingOccurrences(
        of: TemplatePlaceholders.object2,
        with: objects[1].displayName
      )
    }
    if objects.count > 2 {
      result = result.replacingOccurrences(
        of: TemplatePlaceholders.object3,
        with: objects[2].displayName
      )
    }

    return result
  }

  private func substituteImagePlaceholder(
    _ placeholder: String,
    mainCharacter: StoryCharacter,
    sideCharacter: StoryCharacter,
    objects: [StoryObject]
  ) -> String? {
    let trimmed = placeholder.trimmingCharacters(in: .whitespacesAndNewlines)

    // Map placeholders to asset IDs
    switch trimmed {
    case TemplatePlaceholders.mainCharacter:
      return mainCharacter.id
    case TemplatePlaceholders.sideCharacter:
      return sideCharacter.id
    case TemplatePlaceholders.object1:
      return objects.indices.contains(0) ? objects[0].id : nil
    case TemplatePlaceholders.object2:
      return objects.indices.contains(1) ? objects[1].id : nil
    case TemplatePlaceholders.object3:
      return objects.indices.contains(2) ? objects[2].id : nil
    default:
      // If it's not a known placeholder, check if it's already an asset ID
      return trimmed.contains("{{") ? nil : trimmed
    }
  }

  private func selectRandomSideCharacter(excluding mainCharacter: StoryCharacter) -> StoryCharacter
  {
    let available = StoryAssets.allCharacters.filter { $0.id != mainCharacter.id }
    return available.randomElement() ?? StoryAssets.allCharacters.first!
  }
}

// MARK: - Rendered Models

/// A story after template rendering (ready for display)
struct RenderedStory {
  let title: String
  let pages: [RenderedPage]
  let templateId: String
}

/// A page after rendering
struct RenderedPage {
  let pageNumber: Int
  let text: String
  let suggestedImages: [String]  // Asset IDs
}

// MARK: - Errors

enum TemplateError: Error, LocalizedError {
  case fileNotFound
  case invalidJSON
  case noMatchingTemplate

  var errorDescription: String? {
    switch self {
    case .fileNotFound:
      return "Template file not found in app bundle"
    case .invalidJSON:
      return "Failed to parse template JSON"
    case .noMatchingTemplate:
      return "No template found for the selected mood and theme"
    }
  }
}
