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
            You MUST respond with ONLY a valid JSON object, no additional text before or after.
            Use proper JSON escaping for quotes and special characters in the text field.
            
            Format:
            {
              "title": "Story Title",
              "pages": [
                {
                  "pageNumber": 1,
                  "text": "Once upon a time...",
                  "suggestedImages": ["MARIO", "COIN"]
                },
                {
                  "pageNumber": 2,
                  "text": "The next day...",
                  "suggestedImages": ["LUIGI"]
                }
              ]
            }

            IMPORTANT:
            - Respond with ONLY the JSON object, nothing else
            - Use proper JSON string escaping (escape quotes with backslash)
            - For suggestedImages, use these IDs: \(availableAssetIDs().joined(separator: ", "))
            - Each page can have 0-2 suggested images
            - Make sure all JSON is valid and properly closed
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
    
  /// Generates a custom story prompt with user-selected options
  static func generateCustomStoryPrompt(
    mainCharacter: StoryCharacter,
    mood: StoryMood,
    spark: StorySpark,
    pageCount: Int = 5
  ) -> String {
    // All character bios for context
    let allCharacterBios = StoryAssets.allCharacters.map {
      "- \($0.displayName): \($0.description)"
    }.joined(separator: "\n")

    // All available objects
    let allObjectsList = StoryAssets.allObjects.map {
      "- \($0.displayName): \($0.description)"
    }.joined(separator: "\n")

    let prompt = """
      Create a children's story with exactly \(pageCount) pages (excluding the cover page).

      CHARACTER REFERENCE:
      Here are all available characters for context:
      \(allCharacterBios)

      AVAILABLE OBJECTS TO USE IN THE STORY:
      \(allObjectsList)

      STORY REQUIREMENTS:

      Main Character: \(mainCharacter.displayName)
      - This character MUST be the protagonist and appear throughout the story
      - Other characters can appear as supporting characters

      Story Mood: \(mood.rawValue)
      - \(mood.description)
      - The tone and feel of the story should match this mood

      Story Premise: \(spark.rawValue)
      - \(spark.promptText)
      - Build the story around this central idea

      Additional Requirements:
      - Use at least 2-3 of the available objects naturally in the story
      - Each page should have 2-4 sentences (50-150 words per page)
      - The story should have a clear beginning, middle, and end
      - Make it engaging and fun for children aged 5-10
      - Include moments where characters interact with the objects

      RESPONSE FORMAT:
      You MUST respond with ONLY a valid JSON object, no additional text before or after.
      Use proper JSON escaping for quotes and special characters in the text field.

      Format:
      {
        "title": "Story Title",
        "pages": [
          {
            "pageNumber": 1,
            "text": "Once upon a time...",
            "suggestedImages": ["MARIO", "COIN"]
          },
          {
            "pageNumber": 2,
            "text": "The next day...",
            "suggestedImages": ["LUIGI"]
          }
        ]
      }

      IMPORTANT:
      - Respond with ONLY the JSON object, nothing else
      - Use proper JSON string escaping (escape quotes with backslash)
      - For suggestedImages, use these IDs: \(availableAssetIDs().joined(separator: ", "))
      - Each page can have 0-2 suggested images
      - Make sure all JSON is valid and properly closed
      - Feature \(mainCharacter.displayName) prominently as the main character
      """

    return prompt
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
