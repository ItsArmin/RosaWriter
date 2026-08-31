//
//  CustomCharacter.swift
//  RosaWriter
//
//  Created by Cursor on 7/10/26.
//

import Foundation
import SwiftData

enum CustomCharacterKind: String, CaseIterable, Codable, Identifiable, Sendable {
  case person
  case pet
  case animal
  case creature
  case toy
  case other

  var id: String { rawValue }
  var displayName: String { rawValue.capitalized }
}

enum CharacterPronouns: String, CaseIterable, Codable, Identifiable, Sendable {
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

enum CharacterPersonality: String, CaseIterable, Codable, Identifiable, Sendable {
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

enum CharacterDialogueStyle: String, CaseIterable, Codable, Identifiable,
  Sendable
{
  case casual
  case formal
  case western
  case silly
  case gentle
  case bold

  var id: String { rawValue }

  var displayName: String {
    switch self {
    case .casual: "Friendly & Casual"
    case .formal: "Formal & Proper"
    case .western: "Western & Folksy"
    case .silly: "Silly & Playful"
    case .gentle: "Soft & Gentle"
    case .bold: "Bold & Adventurous"
    }
  }

  var speakingStyle: String {
    switch self {
    case .casual:
      "friendly, relaxed, and conversational"
    case .formal:
      "polite, proper, and carefully spoken"
    case .western:
      "folksy Western style with light trail expressions"
    case .silly:
      "silly, energetic, and lighthearted"
    case .gentle:
      "warm, patient, and reassuring"
    case .bold:
      "brave, direct, and adventurous"
    }
  }

  var voice: CharacterVoice {
    switch self {
    case .casual: .upbeat
    case .formal: .formal
    case .western: .western
    case .silly: .playful
    case .gentle: .gentle
    case .bold: .bold
    }
  }

  static func suggested(
    for personality: CharacterPersonality
  ) -> CharacterDialogueStyle {
    switch personality {
    case .cheerful:
      .casual
    case .kind, .calm, .shy:
      .gentle
    case .silly:
      .silly
    case .curious, .clever:
      .formal
    case .brave:
      .bold
    }
  }

  static func fromStoredValue(_ value: String) -> CharacterDialogueStyle {
    if let style = CharacterDialogueStyle(rawValue: value) {
      return style
    }

    return switch value {
    case "upbeat": .casual
    case "playful": .silly
    case "thoughtful": .formal
    default: .casual
    }
  }
}

enum CharacterInterest: String, CaseIterable, Codable, Identifiable, Sendable {
  case animals
  case art
  case books
  case building
  case cooking
  case exploring
  case magic
  case music
  case nature
  case science
  case sports
  case helpingOthers

  var id: String { rawValue }

  var displayName: String {
    switch self {
    case .helpingOthers: "Helping Others"
    default: rawValue.capitalized
    }
  }
}

enum CharacterAdventureStyle: String, CaseIterable, Codable, Identifiable,
  Sendable
{
  case explorer
  case helper
  case inventor
  case detective
  case dreamer
  case jokester

  var id: String { rawValue }
  var displayName: String { rawValue.capitalized }

  var promptDescription: String {
    switch self {
    case .explorer: "eager to discover new places"
    case .helper: "quick to notice when someone needs help"
    case .inventor: "always ready to build a clever solution"
    case .detective: "curious about clues and mysteries"
    case .dreamer: "guided by imagination and wonder"
    case .jokester: "fond of solving problems with humor"
    }
  }
}

enum CharacterPhotoAspect: String, CaseIterable, Codable, Identifiable, Sendable {
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

struct CharacterPhotoCrop: Equatable, Sendable {
  let centerX: Double
  let centerY: Double
  let scale: Double
  let aspect: CharacterPhotoAspect
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
  var primaryInterestRawValue: String?
  var secondaryInterestRawValue: String?
  var adventureStyleRawValue: String?
  var catchphrase: String?
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
    dialogueStyle: CharacterDialogueStyle? = nil,
    primaryInterest: CharacterInterest? = nil,
    secondaryInterest: CharacterInterest? = nil,
    adventureStyle: CharacterAdventureStyle = .explorer,
    catchphrase: String? = nil,
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
      (dialogueStyle ?? .suggested(for: primaryPersonality)).rawValue
    self.primaryInterestRawValue = primaryInterest?.rawValue
    self.secondaryInterestRawValue =
      secondaryInterest == primaryInterest ? nil : secondaryInterest?.rawValue
    self.adventureStyleRawValue = adventureStyle.rawValue
    let trimmedCatchphrase = catchphrase?.trimmingCharacters(
      in: .whitespacesAndNewlines
    )
    self.catchphrase =
      trimmedCatchphrase?.isEmpty == true
      ? nil : trimmedCatchphrase
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

  var dialogueStyle: CharacterDialogueStyle {
    get { CharacterDialogueStyle.fromStoredValue(voicePresetRawValue) }
    set { voicePresetRawValue = newValue.rawValue }
  }

  var primaryInterest: CharacterInterest? {
    get {
      guard let primaryInterestRawValue else { return nil }
      return CharacterInterest(rawValue: primaryInterestRawValue)
    }
    set { primaryInterestRawValue = newValue?.rawValue }
  }

  var secondaryInterest: CharacterInterest? {
    get {
      guard let secondaryInterestRawValue else { return nil }
      return CharacterInterest(rawValue: secondaryInterestRawValue)
    }
    set {
      secondaryInterestRawValue =
        newValue == primaryInterest ? nil : newValue?.rawValue
    }
  }

  var adventureStyle: CharacterAdventureStyle {
    get {
      guard let adventureStyleRawValue else { return .explorer }
      return CharacterAdventureStyle(rawValue: adventureStyleRawValue)
        ?? .explorer
    }
    set { adventureStyleRawValue = newValue.rawValue }
  }

  var photoAspect: CharacterPhotoAspect {
    get { CharacterPhotoAspect(rawValue: photoAspectRawValue) ?? .portrait }
    set { photoAspectRawValue = newValue.rawValue }
  }

  var storyCharacterID: String {
    "CUSTOM_\(id.uuidString.replacingOccurrences(of: "-", with: "_"))"
  }

  var photoCrop: CharacterPhotoCrop {
    CharacterPhotoCrop(
      centerX: cropCenterX,
      centerY: cropCenterY,
      scale: cropScale,
      aspect: photoAspect
    )
  }

  func makeStoryCharacter(imageName: String) -> StoryCharacter {
    let personalityDescription = [primaryPersonality, secondaryPersonality]
      .compactMap { $0?.displayName.lowercased() }
      .joined(separator: " and ")
    let interests = [primaryInterest, secondaryInterest]
      .compactMap { $0?.displayName.lowercased() }
      .joined(separator: " and ")
    var profileDescription = biography
    if !interests.isEmpty {
      profileDescription += " Loves \(interests)."
    }
    profileDescription += " \(adventureStyle.promptDescription.capitalized)."

    var storyVoice = dialogueStyle.voice
    if let catchphrase, !catchphrase.isEmpty {
      storyVoice = CharacterVoice(
        greeting: storyVoice.greeting,
        farewell: storyVoice.farewell,
        excited: [catchphrase] + storyVoice.excited,
        thinking: storyVoice.thinking,
        agreement: storyVoice.agreement,
        surprise: storyVoice.surprise
      )
    }

    return StoryCharacter(
      id: storyCharacterID,
      imageName: imageName,
      displayName: name,
      description: profileDescription,
      size: .large,
      pronounSubjective: pronouns.subjective,
      pronounPossessive: pronouns.possessive,
      pronounObjective: pronouns.objective,
      speakingStyle:
        "\(dialogueStyle.speakingStyle); \(personalityDescription)"
        + (catchphrase.map { "; catchphrase: \"\($0)\"" } ?? ""),
      voice: storyVoice
    )
  }

  static func suggestedBiography(
    name: String,
    pronouns: CharacterPronouns,
    primaryPersonality: CharacterPersonality,
    secondaryPersonality: CharacterPersonality?,
    primaryInterest: CharacterInterest?,
    secondaryInterest: CharacterInterest?,
    adventureStyle: CharacterAdventureStyle
  ) -> String {
    let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
    let displayName = trimmedName.isEmpty ? "This character" : trimmedName
    let traits = [primaryPersonality, secondaryPersonality]
      .compactMap { $0?.displayName.lowercased() }
      .joined(separator: " and ")
    let interests = [primaryInterest, secondaryInterest]
      .compactMap { $0?.displayName.lowercased() }
      .joined(separator: " and ")
    let subject = pronouns.subjective.capitalized
    let linkingVerb = pronouns == .theyThem ? "are" : "is"

    var sentences = ["\(displayName) is \(traits)."]
    if !interests.isEmpty {
      sentences.append("\(subject) loves \(interests).")
    }
    sentences.append(
      "\(subject) \(linkingVerb) \(adventureStyle.promptDescription)."
    )
    return sentences.joined(separator: " ")
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
