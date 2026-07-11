//
//  CustomCharacter.swift
//  RosaWriter
//
//  Created by Cursor on 7/10/26.
//

import Foundation
import SwiftData

enum CustomCharacterKind: String, CaseIterable, Codable, Identifiable {
  case person
  case pet
  case animal
  case creature
  case toy
  case other

  var id: String { rawValue }
  var displayName: String { rawValue.capitalized }
}

enum CharacterPronouns: String, CaseIterable, Codable, Identifiable {
  case heHim
  case sheHer
  case theyThem

  var id: String { rawValue }

  var displayName: String {
    switch self {
    case .heHim: "He / Him"
    case .sheHer: "She / Her"
    case .theyThem: "They / Them"
    }
  }

  var subjective: String {
    switch self {
    case .heHim: "he"
    case .sheHer: "she"
    case .theyThem: "they"
    }
  }

  var possessive: String {
    switch self {
    case .heHim: "his"
    case .sheHer: "her"
    case .theyThem: "their"
    }
  }

  var objective: String {
    switch self {
    case .heHim: "him"
    case .sheHer: "her"
    case .theyThem: "them"
    }
  }
}

enum CharacterPersonality: String, CaseIterable, Codable, Identifiable {
  case cheerful
  case brave
  case silly
  case curious
  case kind
  case calm
  case shy
  case clever

  var id: String { rawValue }
  var displayName: String { rawValue.capitalized }
}

enum CharacterVoicePreset: String, CaseIterable, Codable, Identifiable {
  case upbeat
  case gentle
  case playful
  case thoughtful
  case bold

  var id: String { rawValue }
  var displayName: String { rawValue.capitalized }

  var speakingStyle: String {
    switch self {
    case .upbeat:
      "bright, optimistic, and encouraging"
    case .gentle:
      "warm, patient, and reassuring"
    case .playful:
      "silly, energetic, and lighthearted"
    case .thoughtful:
      "curious, observant, and careful"
    case .bold:
      "brave, direct, and adventurous"
    }
  }

  var voice: CharacterVoice {
    switch self {
    case .upbeat: .upbeat
    case .gentle: .gentle
    case .playful: .playful
    case .thoughtful: .thoughtful
    case .bold: .bold
    }
  }

  static func suggested(for personality: CharacterPersonality) -> CharacterVoicePreset {
    switch personality {
    case .cheerful:
      .upbeat
    case .kind, .calm, .shy:
      .gentle
    case .silly:
      .playful
    case .curious, .clever:
      .thoughtful
    case .brave:
      .bold
    }
  }
}

enum CharacterPhotoAspect: String, CaseIterable, Codable, Identifiable {
  case square
  case portrait

  var id: String { rawValue }

  var displayName: String {
    switch self {
    case .square: "Square"
    case .portrait: "Portrait"
    }
  }
}

@Model
final class CustomCharacter {
  static let maximumCount = 10

  @Attribute(.unique) var id: UUID
  var createdAt: Date
  var updatedAt: Date
  var name: String
  var kindRawValue: String
  var pronounsRawValue: String
  var biography: String
  var primaryPersonalityRawValue: String
  var secondaryPersonalityRawValue: String?
  var voicePresetRawValue: String
  var imageFileName: String
  var photoAspectRawValue: String
  var cropCenterX: Double
  var cropCenterY: Double
  var cropScale: Double

  init(
    id: UUID = UUID(),
    createdAt: Date = Date(),
    name: String,
    kind: CustomCharacterKind,
    pronouns: CharacterPronouns,
    biography: String,
    primaryPersonality: CharacterPersonality,
    secondaryPersonality: CharacterPersonality? = nil,
    voicePreset: CharacterVoicePreset? = nil,
    imageFileName: String,
    photoAspect: CharacterPhotoAspect = .portrait,
    cropCenterX: Double = 0.5,
    cropCenterY: Double = 0.5,
    cropScale: Double = 1
  ) {
    self.id = id
    self.createdAt = createdAt
    self.updatedAt = createdAt
    self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
    self.kindRawValue = kind.rawValue
    self.pronounsRawValue = pronouns.rawValue
    self.biography = biography.trimmingCharacters(in: .whitespacesAndNewlines)
    self.primaryPersonalityRawValue = primaryPersonality.rawValue
    self.secondaryPersonalityRawValue =
      secondaryPersonality == primaryPersonality ? nil : secondaryPersonality?.rawValue
    self.voicePresetRawValue =
      (voicePreset ?? .suggested(for: primaryPersonality)).rawValue
    self.imageFileName = imageFileName
    self.photoAspectRawValue = photoAspect.rawValue
    self.cropCenterX = min(max(cropCenterX, 0), 1)
    self.cropCenterY = min(max(cropCenterY, 0), 1)
    self.cropScale = max(cropScale, 1)
  }

  var kind: CustomCharacterKind {
    get { CustomCharacterKind(rawValue: kindRawValue) ?? .other }
    set { kindRawValue = newValue.rawValue }
  }

  var pronouns: CharacterPronouns {
    get { CharacterPronouns(rawValue: pronounsRawValue) ?? .theyThem }
    set { pronounsRawValue = newValue.rawValue }
  }

  var primaryPersonality: CharacterPersonality {
    get { CharacterPersonality(rawValue: primaryPersonalityRawValue) ?? .cheerful }
    set { primaryPersonalityRawValue = newValue.rawValue }
  }

  var secondaryPersonality: CharacterPersonality? {
    get {
      guard let secondaryPersonalityRawValue else { return nil }
      return CharacterPersonality(rawValue: secondaryPersonalityRawValue)
    }
    set {
      secondaryPersonalityRawValue =
        newValue == primaryPersonality ? nil : newValue?.rawValue
    }
  }

  var voicePreset: CharacterVoicePreset {
    get { CharacterVoicePreset(rawValue: voicePresetRawValue) ?? .upbeat }
    set { voicePresetRawValue = newValue.rawValue }
  }

  var photoAspect: CharacterPhotoAspect {
    get { CharacterPhotoAspect(rawValue: photoAspectRawValue) ?? .portrait }
    set { photoAspectRawValue = newValue.rawValue }
  }

  var storyCharacterID: String {
    "CUSTOM_\(id.uuidString.replacingOccurrences(of: "-", with: "_"))"
  }

  func makeStoryCharacter(imageName: String) -> StoryCharacter {
    let personalityDescription = [primaryPersonality, secondaryPersonality]
      .compactMap { $0?.displayName.lowercased() }
      .joined(separator: " and ")

    return StoryCharacter(
      id: storyCharacterID,
      imageName: imageName,
      displayName: name,
      description: biography,
      size: .large,
      pronounSubjective: pronouns.subjective,
      pronounPossessive: pronouns.possessive,
      pronounObjective: pronouns.objective,
      speakingStyle:
        "\(voicePreset.speakingStyle); \(personalityDescription)",
      voice: voicePreset.voice
    )
  }

  func updateCrop(
    centerX: Double,
    centerY: Double,
    scale: Double,
    aspect: CharacterPhotoAspect
  ) {
    cropCenterX = min(max(centerX, 0), 1)
    cropCenterY = min(max(centerY, 0), 1)
    cropScale = max(scale, 1)
    photoAspect = aspect
    updatedAt = Date()
  }
}
