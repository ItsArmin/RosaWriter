//
//  StoryAssets.swift
//  RosaWriter
//
//  Created by Armin on 10/26/25.
//

import Foundation

// MARK: - Story Asset Models

struct StoryCharacter {
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
