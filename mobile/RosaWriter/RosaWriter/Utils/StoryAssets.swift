//
//  StoryAssets.swift
//  RosaWriter
//
//  Created by Armin on 10/26/25.
//

import Foundation

// MARK: - Story Asset Models

struct StoryCharacter: Equatable, Hashable {
    let id: String
    let imageName: String
    let displayName: String
    let description: String

    init(
        id: String,
        imageName: String,
        displayName: String,
        description: String = ""
    ) {
        self.id = id
        self.imageName = imageName
        self.displayName = displayName
        self.description = description
    }
}

struct StoryObject {
    let id: String
    let imageName: String
    let displayName: String
    let description: String

    init(
        id: String,
        imageName: String,
        displayName: String,
        description: String = ""
    ) {
        self.id = id
        self.imageName = imageName
        self.displayName = displayName
        self.description = description
    }
}

// MARK: - Asset Collections

struct StoryAssets {

    // MARK: - Characters

    static let MARIO = StoryCharacter(
        id: "MARIO",
        imageName: "mario",
        displayName: "Mario",
        description: "A brave and adventurous hero in red overalls"
    )

    static let LUIGI = StoryCharacter(
        id: "LUIGI",
        imageName: "luigi",
        displayName: "Luigi",
        description: "Mario's kind and clever brother in green overalls"
    )

    static let PEACH = StoryCharacter(
        id: "PEACH",
        imageName: "peach",
        displayName: "Princess Peach",
        description:
            "A kind and graceful princess who rules the Mushroom Kingdom"
    )

    static let BOWSER = StoryCharacter(
        id: "BOWSER",
        imageName: "bowser",
        displayName: "Bowser",
        description:
            "A large, sometimes grumpy character who can be a friend or foe"
    )

    static let allCharacters: [StoryCharacter] = [
        MARIO,
        LUIGI,
        PEACH,
        BOWSER,
    ]

    // MARK: - Objects

    static let ONE_UP = StoryObject(
        id: "ONE_UP",
        imageName: "1up",
        displayName: "1-Up Mushroom",
        description:
            "A magical green mushroom that grants an extra life or special power"
    )

    static let COIN = StoryObject(
        id: "COIN",
        imageName: "coin",
        displayName: "Gold Coin",
        description:
            "A shiny golden coin that can be collected or used as treasure"
    )

    static let STAR = StoryObject(
        id: "STAR",
        imageName: "star",
        displayName: "Power Star",
        description:
            "A magical star that grants special powers or makes wishes come true"
    )

    static let FIRE_FLOWER = StoryObject(
        id: "FIRE_FLOWER",
        imageName: "fireflower",
        displayName: "Fire Flower",
        description: "A special flower with magical fire powers"
    )

    static let SPAGHETTI = StoryObject(
        id: "SPAGHETTI",
        imageName: "spaghetti",
        displayName: "Spaghetti",
        description: "A delicious plate of Italian pasta"
    )

    static let GOOMBA = StoryObject(
        id: "GOOMBA",
        imageName: "goomba",
        displayName: "Goomba",
        description:
            "A small mushroom creature that can be friendly or mischievous"
    )

    static let allObjects: [StoryObject] = [
        ONE_UP,
        COIN,
        STAR,
        FIRE_FLOWER,
        SPAGHETTI,
        GOOMBA,
    ]

    // MARK: - Helper Methods

    /// Get a character by its ID
    static func character(for id: String) -> StoryCharacter? {
        allCharacters.first { $0.id == id }
    }

    /// Get an object by its ID
    static func object(for id: String) -> StoryObject? {
        allObjects.first { $0.id == id }
    }

    /// Get a random selection of characters
    static func randomCharacters(count: Int) -> [StoryCharacter] {
        Array(allCharacters.shuffled().prefix(count))
    }

    /// Get a random selection of objects
    static func randomObjects(count: Int) -> [StoryObject] {
        Array(allObjects.shuffled().prefix(count))
    }

    /// Get all asset image names (useful for validation)
    static var allImageNames: [String] {
        allCharacters.map { $0.imageName } + allObjects.map { $0.imageName }
    }
}

// MARK: - Story Configuration Options

enum StoryMood: String, CaseIterable, Identifiable, Codable {
  case fantasy = "Fantasy"
  case silly = "Silly"
  case learning = "Learning"
  case courage = "Courage"
  case friendship = "Friendship"
  case adventure = "Adventure"
  case mystery = "Mystery"
  case kindness = "Kindness"

  var id: String { rawValue }

  var description: String {
    switch self {
    case .fantasy:
      return "Magical and imaginative with wonder and enchantment"
    case .silly:
      return "Fun and playful with lots of laughs and surprises"
    case .learning:
      return "Educational and curious about discovering new things"
    case .courage:
      return "Brave and bold about facing challenges"
    case .friendship:
      return "Warm and heartfelt about friendship and togetherness"
    case .adventure:
      return "Exciting and action-packed with exploration"
    case .mystery:
      return "Curious and engaging with puzzles to solve"
    case .kindness:
      return "Gentle and caring about helping others"
    }
  }
}

/// Theme categorizes the story's central concept for template matching
enum StoryTheme: String, Codable, CaseIterable, Identifiable {
  case birthday = "Birthday"
  case adventure = "Adventure"
  case friendship = "Friendship"
  case mystery = "Mystery"
  case learning = "Learning"
  case celebration = "Celebration"

  var id: String { rawValue }

  var description: String {
    switch self {
    case .birthday:
      return "Birthday parties and celebrations"
    case .adventure:
      return "Exciting journeys and exploration"
    case .friendship:
      return "Stories about friends helping each other"
    case .mystery:
      return "Solving puzzles and uncovering secrets"
    case .learning:
      return "Discovering new things and learning"
    case .celebration:
      return "Special occasions and festivities"
    }
  }
}

enum StorySpark: String, CaseIterable, Identifiable, Codable {
  case treasureHunt = "Treasure Hunt"
  case findingFood = "Finding Something to Eat"
  case helpingFriend = "Helping a Friend"
  case lostAndFound = "Lost and Found"
  case magicalDiscovery = "Magical Discovery"
  case birthday = "Birthday Celebration"
  case buildingSomething = "Building Something Together"
  case solvingProblem = "Solving a Problem"
  case random = "Surprise Me!"

  var id: String { rawValue }

  var promptText: String {
    switch self {
    case .treasureHunt:
      return "The character discovers a map and goes on a treasure hunt"
    case .findingFood:
      return "The character is hungry and goes on a quest to find something delicious to eat"
    case .helpingFriend:
      return "The character's friend needs help with something important"
    case .lostAndFound:
      return "The character loses something precious and must find it"
    case .magicalDiscovery:
      return "The character discovers something magical that changes everything"
    case .birthday:
      return "The character is planning a special birthday celebration"
    case .buildingSomething:
      return "The character and friends work together to build or create something amazing"
    case .solvingProblem:
      return "The character faces a tricky problem that needs a clever solution"
    case .random:
      return "Choose any creative premise that would make an engaging children's story"
    }
  }
}

// MARK: - Character Pronoun Helpers

extension StoryCharacter {
  /// Returns subject pronouns (he, she, they)
  var pronounSubjective: String {
    switch id {
    case "MARIO", "LUIGI", "BOWSER":
      return "he"
    case "PEACH":
      return "she"
    default:
      return "they"
    }
  }

  /// Returns possessive pronouns (his, her, their)
  var pronounPossessive: String {
    switch id {
    case "MARIO", "LUIGI", "BOWSER":
      return "his"
    case "PEACH":
      return "her"
    default:
      return "their"
    }
  }

  /// Returns object pronouns (him, her, them)
  var pronounObjective: String {
    switch id {
    case "MARIO", "LUIGI", "BOWSER":
      return "him"
    case "PEACH":
      return "her"
    default:
      return "them"
    }
  }
}