//
//  StoryPrompts.swift
//  RosaWriter
//
//  Created by Armin on 10/26/25.
//

import Foundation

struct StoryPrompts {

    // MARK: - System Prompt
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
        let characterList = characters.map { characterDescription($0) }.joined(separator: "\n")
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
            - Include specific moments where characters interact with the objects
            - Make it engaging and fun for children
            - ALL character dialogue MUST use straight double quotes ("), not curly quotes ("")
              Example: "Hello!" said the character (correct)
              NOT: "Hello!" said the character (wrong - curly quotes)
            
            \(voiceOwnershipRules(for: characters))
            
            \(storyStructureRules(pageCount: pageCount))
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
                  "suggestedImages": ["MR_DOG", "APPLE"]
                },
                {
                  "pageNumber": 2,
                  "text": "The next day...",
                  "suggestedImages": ["SIR_WHISKERS"]
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
    
    /// Maximum characters to include in voice ownership rules (to keep prompts lean)
    private static let maxCharactersForVoiceRules = 5

    private static func availableAssetIDs() -> [String] {
        StoryAssets.allCharacters.map { $0.id }
            + StoryAssets.allObjects.map { $0.id }
    }
    
    /// Formats character info including voice/lexicon for prompts
    private static func characterDescription(_ character: StoryCharacter) -> String {
        """
        - \(character.displayName): \(character.description)
          Pronouns: \(character.pronounSubjective)/\(character.pronounPossessive)/\(character.pronounObjective)
          Voice style - \(character.voice.promptDescription.replacingOccurrences(of: "\n", with: "; "))
        """
    }
    
    /// Formats all characters with their voice info
    private static func allCharactersWithVoice() -> String {
        StoryAssets.allCharacters.map { characterDescription($0) }.joined(separator: "\n")
    }
    
    /// Generates character voice ownership rules for only the characters in the story
    /// This prevents catchphrase mixing by explicitly stating which phrases belong to which character
    private static func voiceOwnershipRules(for characters: [StoryCharacter]) -> String {
        let limitedCharacters = Array(characters.prefix(maxCharactersForVoiceRules))
        let rules = limitedCharacters.map { $0.voiceOwnershipRule() }.joined(separator: "\n")
        
        return """
            CRITICAL - CHARACTER VOICE RULES:
            - Each character has UNIQUE phrases that belong ONLY to them - NEVER swap them
            \(rules)
            - Match each character's dialogue STRICTLY to their assigned voice
            """
    }
    
    /// Generates story structure guidance based on page count
    private static func storyStructureRules(pageCount: Int) -> String {
        return """
            STORY STRUCTURE:
            - Write exactly \(pageCount) content pages with meaningful narrative on each
            - Page 1 MUST feature the main character prominently - include them in suggestedImages for page 1
            - Pace: introduction (pages 1-2), rising action (pages 2-\(max(pageCount - 2, 2))), climax (page \(max(pageCount - 1, 2))), resolution (page \(pageCount))
            - Do NOT write "The End" or any ending phrase - this is added automatically
            - Do NOT pad the story with filler if it concludes early - adjust pacing instead
            - Every single page must move the story forward
            """
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
    // Build a focused character set: main character + up to (maxCharactersForVoiceRules - 1) supporting
    let supportingCharacters = StoryAssets.allCharacters
        .filter { $0.id != mainCharacter.id }
        .shuffled()
        .prefix(maxCharactersForVoiceRules - 1)
    let storyCharacters = [mainCharacter] + Array(supportingCharacters)
    
    // Format character list for the prompt
    let characterList = storyCharacters.map { characterDescription($0) }.joined(separator: "\n")
    
    // All available objects
    let allObjectsList = StoryAssets.allObjects.map {
      "- \($0.displayName): \($0.description)"
    }.joined(separator: "\n")

    let prompt = """
      Create a children's story with exactly \(pageCount) pages (excluding the cover page).

      AVAILABLE CHARACTERS:
      \(characterList)

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
      - Make it engaging and fun for children aged 5-10
      - Include moments where characters interact with the objects
      - ALL character dialogue MUST use straight double quotes ("), not curly quotes ("")
        Example: "Hello!" said Mr. Dog (correct)
        NOT: "Hello!" said Mr. Dog (wrong - curly quotes)
      
      \(voiceOwnershipRules(for: storyCharacters))
      
      \(storyStructureRules(pageCount: pageCount))

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
            "suggestedImages": ["MR_DOG", "APPLE"]
          },
          {
            "pageNumber": 2,
            "text": "The next day...",
            "suggestedImages": ["SIR_WHISKERS"]
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
