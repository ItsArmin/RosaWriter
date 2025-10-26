//
//  StoryPrompts.swift
//  RosaWriter
//
//  Created by Armin on 10/26/25.
//

import Foundation

struct StoryPrompts {

    // MARK: - System Prompt
    // TODO: improve prompts...
    static let systemPrompt = """
        You are a creative children's story writer. You write engaging, age-appropriate stories \
        for children aged 5-10 years old. Your stories should be:
        - Simple and easy to understand
        - Positive and uplifting with clear moral lessons
        - Appropriate for young children
        - Fun and engaging with vivid descriptions
        - Well-structured with a clear beginning, middle, and end
        """

    // MARK: - Story Generation Prompt

    /// Generates a prompt for creating a complete story
    static func generateStoryPrompt(
        characters: [StoryCharacter],
        objects: [StoryObject],
        pageCount: Int = 5,
        theme: String? = nil
    ) -> String {
        let characterList = characters.map {
            "- \($0.displayName): \($0.description)"
        }.joined(
            separator: "\n"
        )
        let objectList = objects.map {
            "- \($0.displayName): \($0.description)"
        }.joined(
            separator: "\n"
        )

        var prompt = """
            Create a children's story with exactly \(pageCount) pages (excluding the cover page).

            AVAILABLE CHARACTERS:
            \(characterList)

            AVAILABLE OBJECTS:
            \(objectList)

            REQUIREMENTS:
            - Use at least 2 of the available characters
            - Use at least 2 of the available objects
            - Each page should have 2-4 sentences (50-150 words per page)
            - The story should have a clear beginning, middle, and end
            - Include specific moments where characters interact with the objects
            - Make it engaging and fun for children
            """

        if let theme = theme {
            prompt += "\n- Story theme: \(theme)"
        }

        prompt += """


            RESPONSE FORMAT:
            Respond with a JSON object in this exact format:
            {
              "title": "Story Title",
              "pages": [
                {
                  "pageNumber": 1,
                  "text": "Once upon a time...",
                  "suggestedImages": ["CHARACTER_ID or OBJECT_ID", "ANOTHER_ID"]
                },
                // ... more pages
              ]
            }

            For suggestedImages, use the character/object IDs: \(availableAssetIDs().joined(separator: ", "))
            Each page can have 0-2 suggested images.
            """

        return prompt
    }

    // MARK: - Helper Methods

    private static func availableAssetIDs() -> [String] {
        StoryAssets.allCharacters.map { $0.id }
            + StoryAssets.allObjects.map { $0.id }
    }

    /// Generates a prompt for a random story with random assets
    static func randomStoryPrompt(pageCount: Int = 5, theme: String? = nil)
        -> String
    {
        let characters = StoryAssets.randomCharacters(
            count: Int.random(in: 2...3)
        )
        let objects = StoryAssets.randomObjects(count: Int.random(in: 2...4))
        return generateStoryPrompt(
            characters: characters,
            objects: objects,
            pageCount: pageCount,
            theme: theme
        )
    }

    /// Generates a prompt for refining a specific page
    static func refinePagePrompt(originalText: String, instruction: String)
        -> String
    {
        return """
            Refine the following story page text based on this instruction: "\(instruction)"

            Original text:
            \(originalText)

            Provide the refined version that:
            - Maintains the story's flow and context
            - Is appropriate for children aged 5-10
            - Keeps a similar length (50-150 words)

            Respond with only the refined text, no additional formatting or explanation.
            """
    }
}

// MARK: - Story Response Model

struct AIStoryResponse: Codable {
    let title: String
    let pages: [AIStoryPage]
}

struct AIStoryPage: Codable {
    let pageNumber: Int
    let text: String
    let suggestedImages: [String]
}
