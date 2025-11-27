//
//  StoryTemplate.swift
//  RosaWriter
//
//  Created by Armin on 11/15/25.
//

import Foundation

// MARK: - Template Models

/// A story template with placeholders for dynamic content
struct StoryTemplate: Codable {
  let id: String
  let mood: StoryMood
  let theme: StoryTheme
  let pageCount: Int?  // Optional for backwards compatibility
  let title: String  // Can contain placeholders like {{MAIN_CHARACTER}}
  let titleVariants: [String]?  // Optional alternative title formats
  let pages: [TemplatePage]

  enum CodingKeys: String, CodingKey {
    case id, mood, theme, pageCount, title, titleVariants, pages
  }
}

/// A single page within a template
struct TemplatePage: Codable {
  let pageNumber: Int
  let text: String  // Can contain placeholders
  let textVariants: [String]?  // Optional alternate phrasings
  let suggestedImages: [String]  // Can contain placeholders like {{MAIN_CHARACTER}}
  let imageVariants: [[String]]?  // Optional alternate image combinations
}

// MARK: - Template Bank

/// Container for all story templates
struct TemplateBank: Codable {
  let templates: [StoryTemplate]
  let version: String
}

// MARK: - Placeholder Keys

/// Standard placeholder tokens used in templates
struct TemplatePlaceholders {
  // Main character
  static let mainCharacter = "{{MAIN_CHARACTER}}"
  static let mainCharacterPronounSubjective = "{{PRONOUN_SUBJECTIVE}}"
  static let mainCharacterPronounPossessive = "{{PRONOUN_POSSESSIVE}}"
  static let mainCharacterPronounObjective = "{{PRONOUN_OBJECTIVE}}"
  
  // Main character voice/lexicon
  static let mainCharacterGreeting = "{{VOICE_GREETING}}"
  static let mainCharacterFarewell = "{{VOICE_FAREWELL}}"
  static let mainCharacterExcited = "{{VOICE_EXCITED}}"
  static let mainCharacterThinking = "{{VOICE_THINKING}}"
  static let mainCharacterAgreement = "{{VOICE_AGREEMENT}}"
  static let mainCharacterSurprise = "{{VOICE_SURPRISE}}"

  // Side character
  static let sideCharacter = "{{SIDE_CHARACTER}}"
  static let sideCharacterPronounSubjective = "{{SIDE_PRONOUN_SUBJECTIVE}}"
  static let sideCharacterPronounPossessive = "{{SIDE_PRONOUN_POSSESSIVE}}"
  static let sideCharacterPronounObjective = "{{SIDE_PRONOUN_OBJECTIVE}}"
  
  // Side character voice/lexicon
  static let sideCharacterGreeting = "{{SIDE_VOICE_GREETING}}"
  static let sideCharacterFarewell = "{{SIDE_VOICE_FAREWELL}}"
  static let sideCharacterExcited = "{{SIDE_VOICE_EXCITED}}"
  static let sideCharacterThinking = "{{SIDE_VOICE_THINKING}}"
  static let sideCharacterAgreement = "{{SIDE_VOICE_AGREEMENT}}"
  static let sideCharacterSurprise = "{{SIDE_VOICE_SURPRISE}}"

  // Objects (without article - for when object is already introduced)
  static let object1 = "{{OBJECT_1}}"
  static let object2 = "{{OBJECT_2}}"
  static let object3 = "{{OBJECT_3}}"
  
  // Objects with article (e.g., "an apple", "a book")
  static let object1WithArticle = "{{A_OBJECT_1}}"
  static let object2WithArticle = "{{A_OBJECT_2}}"
  static let object3WithArticle = "{{A_OBJECT_3}}"
}
