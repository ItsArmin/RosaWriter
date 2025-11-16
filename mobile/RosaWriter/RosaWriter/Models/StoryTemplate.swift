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
  let title: String  // Can contain placeholders like {{MAIN_CHARACTER}}
  let pages: [TemplatePage]

  enum CodingKeys: String, CodingKey {
    case id, mood, theme, title, pages
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
  static let mainCharacter = "{{MAIN_CHARACTER}}"
  static let mainCharacterPronounSubjective = "{{PRONOUN_SUBJECTIVE}}"
  static let mainCharacterPronounPossessive = "{{PRONOUN_POSSESSIVE}}"
  static let mainCharacterPronounObjective = "{{PRONOUN_OBJECTIVE}}"

  static let sideCharacter = "{{SIDE_CHARACTER}}"
  static let sideCharacterPronounSubjective = "{{SIDE_PRONOUN_SUBJECTIVE}}"
  static let sideCharacterPronounPossessive = "{{SIDE_PRONOUN_POSSESSIVE}}"
  static let sideCharacterPronounObjective = "{{SIDE_PRONOUN_OBJECTIVE}}"

  static let object1 = "{{OBJECT_1}}"
  static let object2 = "{{OBJECT_2}}"
  static let object3 = "{{OBJECT_3}}"
}
