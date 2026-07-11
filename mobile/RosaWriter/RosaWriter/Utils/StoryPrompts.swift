//
//  StoryPrompts.swift
//  RosaWriter
//
//  Created by Armin on 10/26/25.
//

import Foundation
import FoundationModels

struct StoryPrompts {

    // MARK: - System Prompt
    
    static let systemPrompt = """
        You write simple, folksy children's stories. \
        Short sentences. Clear words. No fancy language. \
        Like a grandparent telling a bedtime story.
        """

    // MARK: - Story Generation Prompts
    
    /// Generates a prompt for creating a story with specific characters and objects
    static func generateStoryPrompt(
        characters: [StoryCharacter],
        objects: [StoryObject],
        pageCount: Int = 5,
        theme: String? = nil
    ) -> String {
        let characterList = characters.map { simpleCharacterDescription($0) }.joined(separator: "\n")
    let objectList = objects.map { $0.displayName }.joined(separator: ", ")
        let mainCharacter = characters.first ?? StoryAssets.allCharacters[0]

        var prompt = """
            Write a \(pageCount)-page children's story featuring \(mainCharacter.displayName) as the main character.

            CHARACTERS:
            \(characterList)

            OBJECTS TO INCLUDE: \(objectList)
            """
        
        if let theme = theme {
            prompt += "\nTHEME: \(theme)"
        }
        
        prompt += """


            WRITING STYLE: Short sentences. Simple words. Clear and folksy, like a bedtime story.

            GUIDELINES:
            - Beginning, middle, and a nice ending
            - \(mainCharacter.displayName) is the main character (show on page 1)
            - Each character sounds different based on their personality
            - Use "straight quotes" for dialogue
            - Don't write "The End"

            Select up to two available story images for each page.
            """

        return prompt
    }

    /// Generates a custom story prompt with user-selected options
    static func generateCustomStoryPrompt(
        mainCharacter: StoryCharacter,
        mood: StoryMood,
        spark: StorySpark,
        pageCount: Int = 5
    ) -> String {
        // Include main character + 2-3 supporting characters
        let supportingCharacters = StoryAssets.allCharacters
            .filter { $0.id != mainCharacter.id }
            .shuffled()
            .prefix(3)
        let storyCharacters = [mainCharacter] + Array(supportingCharacters)
        
        let characterList = storyCharacters.map { simpleCharacterDescription($0) }.joined(separator: "\n")
        let objectList = StoryAssets.allObjects.map { $0.displayName }.joined(separator: ", ")

        let prompt = """
            Write a \(pageCount)-page children's story.

            MAIN CHARACTER: \(mainCharacter.displayName) - the protagonist of this story
            
            OTHER CHARACTERS:
            \(characterList)

            AVAILABLE OBJECTS: \(objectList)

            STORY SETUP:
            - Mood: \(mood.rawValue) - \(mood.description)
            - Premise: \(spark.promptText)

            WRITING STYLE: Short sentences. Simple words. Clear and folksy, like a bedtime story.

            GUIDELINES:
            - Beginning, middle, and a nice ending
            - \(mainCharacter.displayName) is the hero (show on page 1)
            - Each character sounds different based on their personality
            - Include 2-3 objects naturally
            - Use "straight quotes" for dialogue
            - Don't write "The End"

            Select up to two available story images for each page.
            """

        return prompt
    }

    /// Generates a prompt for a random story with random assets
    static func randomStoryPrompt(pageCount: Int = 5, theme: String? = nil) -> String {
        let characters = StoryAssets.randomCharacters(count: Int.random(in: 2...3))
        let objects = StoryAssets.randomObjects(count: Int.random(in: 2...3))
        return generateStoryPrompt(
            characters: characters,
            objects: objects,
            pageCount: pageCount,
            theme: theme
        )
    }

    /// Generates a prompt for refining a specific page
    static func refinePagePrompt(originalText: String, instruction: String) -> String {
        return """
            Refine the following story page based on this instruction: "\(instruction)"

            Original text:
            \(originalText)

            Keep it:
            - Natural and engaging
            - Age-appropriate (5-10 years old)
            - Similar length to the original

            Respond with only the refined text.
            """
    }

    // MARK: - Helper Methods
    
    /// Simple character description for prompts - uses speakingStyle instead of full voice
    private static func simpleCharacterDescription(_ character: StoryCharacter) -> String {
        "- \(character.displayName) (\(character.pronounSubjective)/\(character.pronounPossessive)): \(character.description). Voice: \(character.speakingStyle)"
    }
    
}

// MARK: - Story Response Model

@Generable(description: "A complete children's story")
struct AIStoryResponse {
    @Guide(description: "A short, playful book title")
    var title: String

    @Guide(
        description: "Story pages in numerical order",
        .maximumCount(10)
    )
    var pages: [AIStoryPage]
}

@Generable(description: "One page of a children's story")
struct AIStoryPage {
    @Guide(description: "The page number", .range(1...10))
    var pageNumber: Int

    @Guide(description: "Two to four short, age-appropriate sentences")
    var text: String

    @Guide(
        description: "Visuals that match this page",
        .maximumCount(2)
    )
    var suggestedImages: [GeneratedStoryImage]
}

@Generable(description: "An illustration available inside Rosa Writer")
enum GeneratedStoryImage {
    case mainCharacter
    case mrDog
    case sirWhiskers
    case professorSeal
    case msCow
    case apple
    case balloon
    case basketball
    case book
    case burger
    case cake
    case crayon
    case teddy

    func assetID(mainCharacterID: String) -> String {
        switch self {
        case .mainCharacter: mainCharacterID
        case .mrDog: StoryAssets.MR_DOG.id
        case .sirWhiskers: StoryAssets.SIR_WHISKERS.id
        case .professorSeal: StoryAssets.PROFESSOR_SEAL.id
        case .msCow: StoryAssets.MS_COW.id
        case .apple: StoryAssets.APPLE.id
        case .balloon: StoryAssets.BALLOON.id
        case .basketball: StoryAssets.BASKETBALL.id
        case .book: StoryAssets.BOOK.id
        case .burger: StoryAssets.BURGER.id
        case .cake: StoryAssets.CAKE.id
        case .crayon: StoryAssets.CRAYON.id
        case .teddy: StoryAssets.TEDDY.id
        }
    }
}
