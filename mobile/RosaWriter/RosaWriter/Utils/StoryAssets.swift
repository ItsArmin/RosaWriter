//
//  StoryAssets.swift
//  RosaWriter
//
//  Created by Armin on 10/26/25.
//

import Foundation

// MARK: - Story Asset Models

enum StoryAssetSize {
    case small
    case large
}

struct StoryCharacter: Equatable, Hashable {
    let id: String
    let imageName: String
    let displayName: String
    let description: String
    let size: StoryAssetSize
    let pronounSubjective: String  // he, she, they
    let pronounPossessive: String   // his, her, their
    let pronounObjective: String    // him, her, them

    init(
        id: String,
        imageName: String,
        displayName: String,
        description: String = "",
        size: StoryAssetSize = .large,
        pronounSubjective: String,
        pronounPossessive: String,
        pronounObjective: String
    ) {
        self.id = id
        self.imageName = imageName
        self.displayName = displayName
        self.description = description
        self.size = size
        self.pronounSubjective = pronounSubjective
        self.pronounPossessive = pronounPossessive
        self.pronounObjective = pronounObjective
    }
}

struct StoryObject {
    let id: String
    let imageName: String
    let displayName: String
    let description: String
    let size: StoryAssetSize

    init(
        id: String,
        imageName: String,
        displayName: String,
        description: String = "",
        size: StoryAssetSize = .small
    ) {
        self.id = id
        self.imageName = imageName
        self.displayName = displayName
        self.description = description
        self.size = size
    }
}

// MARK: - Asset Collections

struct StoryAssets {

    // MARK: - Characters

    static let MR_DOG = StoryCharacter(
        id: "MR_DOG",
        imageName: "mrDog",
        displayName: "Mr. Dog",
        description: "A friendly, happy-go-lucky optimistic dog",
        size: .large,
        pronounSubjective: "he",
        pronounPossessive: "his",
        pronounObjective: "him"
    )

    static let SIR_WHISKERS = StoryCharacter(
        id: "SIR_WHISKERS",
        imageName: "sirWhiskers",
        displayName: "Sir Whiskers",
        description: "A prim and proper cat who speaks with a whimsical British accent",
        size: .small,
        pronounSubjective: "he",
        pronounPossessive: "his",
        pronounObjective: "him"
    )

    static let PROFESSOR_SEAL = StoryCharacter(
        id: "PROFESSOR_SEAL",
        imageName: "professorSeal",
        displayName: "Professor Seal",
        description: "A wise and logical educator seal",
        size: .large,
        pronounSubjective: "he",
        pronounPossessive: "his",
        pronounObjective: "him"
    )

    static let MS_COW = StoryCharacter(
        id: "MS_COW",
        imageName: "msCow",
        displayName: "Ms. Cow",
        description: "A kind and simple cow who speaks with a southern accent",
        size: .large,
        pronounSubjective: "she",
        pronounPossessive: "her",
        pronounObjective: "her"
    )

    static let allCharacters: [StoryCharacter] = [
        MR_DOG,
        SIR_WHISKERS,
        PROFESSOR_SEAL,
        MS_COW,
    ]

    // MARK: - Objects

    static let APPLE = StoryObject(
        id: "APPLE",
        imageName: "apple",
        displayName: "Apple",
        description: "A shiny red apple, healthy and delicious"
    )

    static let BALLOON = StoryObject(
        id: "BALLOON",
        imageName: "balloon",
        displayName: "Balloon",
        description: "A colorful balloon that floats in the air",
        size: .large
    )

    static let BASKETBALL = StoryObject(
        id: "BASKETBALL",
        imageName: "basketball",
        displayName: "Basketball",
        description: "An orange basketball for playing and bouncing"
    )

    static let BOOK = StoryObject(
        id: "BOOK",
        imageName: "book",
        displayName: "Book",
        description: "A book full of stories and knowledge"
    )

    static let BURGER = StoryObject(
        id: "BURGER",
        imageName: "burger",
        displayName: "Burger",
        description: "A tasty burger with all the fixings"
    )

    static let CAKE = StoryObject(
        id: "CAKE",
        imageName: "cake",
        displayName: "Cake",
        description: "A delicious cake perfect for celebrations"
    )

    static let CRAYON = StoryObject(
        id: "CRAYON",
        imageName: "crayon",
        displayName: "Crayon",
        description: "A colorful crayon for drawing and creating art"
    )

    static let TEDDY = StoryObject(
        id: "TEDDY",
        imageName: "teddy",
        displayName: "Teddy Bear",
        description: "A soft and cuddly teddy bear"
    )

    static let allObjects: [StoryObject] = [
        APPLE,
        BALLOON,
        BASKETBALL,
        BOOK,
        BURGER,
        CAKE,
        CRAYON,
        TEDDY,
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

    /// Get size for a given image name
    static func size(forImageName name: String) -> StoryAssetSize {
        if let char = allCharacters.first(where: { $0.imageName == name }) {
            return char.size
        }
        if let obj = allObjects.first(where: { $0.imageName == name }) {
            return obj.size
        }
        return .small // Default fallback
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
