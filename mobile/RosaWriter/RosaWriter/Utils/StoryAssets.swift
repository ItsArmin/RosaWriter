//
//  StoryAssets.swift
//  RosaWriter
//
//  Created by Armin on 10/26/25.
//

import Foundation

// MARK: - Character Voice / Lexicon

/// A collection of character-specific phrases for personalized dialogue
/// Used both in templates (direct usage) and AI prompts (as guidance)
struct CharacterVoice: Equatable, Hashable {
    let greeting: [String]
    let farewell: [String]
    let excited: [String]
    let thinking: [String]
    let agreement: [String]
    let surprise: [String]
    
    /// Get a random phrase for a category
    func randomGreeting() -> String { greeting.randomElement() ?? "Hello!" }
    func randomFarewell() -> String { farewell.randomElement() ?? "Goodbye!" }
    func randomExcited() -> String { excited.randomElement() ?? "Wow!" }
    func randomThinking() -> String { thinking.randomElement() ?? "Hmm..." }
    func randomAgreement() -> String { agreement.randomElement() ?? "Yes!" }
    func randomSurprise() -> String { surprise.randomElement() ?? "Oh!" }
    
    /// Format for AI prompt inclusion
    var promptDescription: String {
        """
        Greetings: \(greeting.joined(separator: ", "))
        Farewells: \(farewell.joined(separator: ", "))
        When excited: \(excited.joined(separator: ", "))
        When thinking: \(thinking.joined(separator: ", "))
        Agreement: \(agreement.joined(separator: ", "))
        Surprise: \(surprise.joined(separator: ", "))
        """
    }
    
    /// Generates a concise list of signature phrases for prompt injection
    /// Picks the most distinctive phrases that ONLY this character should use
    func signaturePhrases() -> String {
        // Pick 2-3 most distinctive phrases from key categories
        let signatures = [
            excited.first,
            greeting.first,
            surprise.first
        ].compactMap { $0 }
        
        return signatures.prefix(3).map { "\"\($0)\"" }.joined(separator: ", ")
    }
}

// MARK: - Predefined Character Voices

extension CharacterVoice {
    /// Mr. Dog - Enthusiastic, friendly, playful
    static let mrDog = CharacterVoice(
        greeting: ["Woof! Hello there!", "Hey friend!", "Hi hi hi!"],
        farewell: ["See ya later!", "Bye-bye, friend!", "Catch you soon!"],
        excited: ["Oh boy, oh boy!", "This is pawsome!", "Yippee!"],
        thinking: ["Hmm, let me sniff this out...", "I wonder...", "Ooh, what's that?"],
        agreement: ["You bet!", "Absolutely!", "Let's do it!"],
        surprise: ["Whoa!", "No way!", "Woof!"]
    )
    
    /// Sir Whiskers - Formal, British, dignified
    static let sirWhiskers = CharacterVoice(
        greeting: ["Good day to you!", "Greetings, dear friend.", "Ah, splendid to see you!"],
        farewell: ["Cheerio!", "Farewell, old chap!", "Until we meet again!"],
        excited: ["How delightful!", "Splendid!", "Most excellent!"],
        thinking: ["Let me ponder this...", "Curious, most curious...", "I do believe..."],
        agreement: ["Indeed!", "Quite right!", "Precisely so!"],
        surprise: ["Good heavens!", "My word!", "I say!"]
    )
    
    /// Professor Seal - Wise, thoughtful, educational
    static let professorSeal = CharacterVoice(
        greeting: ["Greetings, young learner!", "Hello there!", "Ah, welcome!"],
        farewell: ["Keep learning!", "Until next time!", "Stay curious!"],
        excited: ["Fascinating!", "Remarkable!", "What a discovery!"],
        thinking: ["Let me think...", "According to my research...", "Aha!"],
        agreement: ["Correct!", "Exactly right!", "Well reasoned!"],
        surprise: ["Extraordinary!", "How unexpected!", "Incredible!"]
    )
    
    /// Ms. Cow - Warm, Southern, nurturing
    static let msCow = CharacterVoice(
        greeting: ["Well, hello there, sugar!", "Howdy, y'all!", "Hey there, sweetpea!"],
        farewell: ["Y'all come back now!", "Take care, hon!", "Bye-bye, darlin'!"],
        excited: ["Well, I'll be!", "Hot diggity!", "Ain't that somethin'!"],
        thinking: ["Now let me think on that...", "Well, I reckon...", "Hmm, sugar..."],
        agreement: ["Bless your heart, yes!", "You got that right!", "Mhm, sure thing!"],
        surprise: ["Oh my stars!", "Well, I never!", "Goodness gracious!"]
    )
}

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
    let voice: CharacterVoice       // Character-specific phrases/lexicon

    init(
        id: String,
        imageName: String,
        displayName: String,
        description: String = "",
        size: StoryAssetSize = .large,
        pronounSubjective: String,
        pronounPossessive: String,
        pronounObjective: String,
        voice: CharacterVoice
    ) {
        self.id = id
        self.imageName = imageName
        self.displayName = displayName
        self.description = description
        self.size = size
        self.pronounSubjective = pronounSubjective
        self.pronounPossessive = pronounPossessive
        self.pronounObjective = pronounObjective
        self.voice = voice
    }
    
    /// Generates ownership rule for this character's unique voice
    /// Example: "Mr. Dog: says "Oh boy!", "Woof!" - ONLY Mr. Dog uses these"
    func voiceOwnershipRule() -> String {
        let signatures = voice.signaturePhrases()
        return "- \(displayName): says \(signatures) - ONLY \(displayName) uses these"
    }
}

struct StoryObject {
    let id: String
    let imageName: String
    let displayName: String
    let displayNameWithArticle: String  // e.g., "an apple", "a book"
    let description: String
    let size: StoryAssetSize

    init(
        id: String,
        imageName: String,
        displayName: String,
        displayNameWithArticle: String? = nil,
        description: String = "",
        size: StoryAssetSize = .small
    ) {
        self.id = id
        self.imageName = imageName
        self.displayName = displayName
        // Use provided article form, or auto-generate from displayName
        if let articleForm = displayNameWithArticle, !articleForm.trimmingCharacters(in: .whitespaces).isEmpty {
            self.displayNameWithArticle = articleForm
        } else {
            // Auto-generate: use "an" for vowel sounds, "a" otherwise
            let startsWithVowel = displayName.lowercased().first.map { "aeiou".contains($0) } ?? false
            self.displayNameWithArticle = startsWithVowel ? "an \(displayName)" : "a \(displayName)"
        }
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
        pronounObjective: "him",
        voice: .mrDog
    )

    static let SIR_WHISKERS = StoryCharacter(
        id: "SIR_WHISKERS",
        imageName: "sirWhiskers",
        displayName: "Sir Whiskers",
        description: "A prim and proper cat who speaks with a whimsical British accent",
        size: .small,
        pronounSubjective: "he",
        pronounPossessive: "his",
        pronounObjective: "him",
        voice: .sirWhiskers
    )

    static let PROFESSOR_SEAL = StoryCharacter(
        id: "PROFESSOR_SEAL",
        imageName: "professorSeal",
        displayName: "Professor Seal",
        description: "A wise and logical educator seal",
        size: .large,
        pronounSubjective: "he",
        pronounPossessive: "his",
        pronounObjective: "him",
        voice: .professorSeal
    )

    static let MS_COW = StoryCharacter(
        id: "MS_COW",
        imageName: "msCow",
        displayName: "Ms. Cow",
        description: "A kind and simple cow who speaks with a southern accent",
        size: .large,
        pronounSubjective: "she",
        pronounPossessive: "her",
        pronounObjective: "her",
        voice: .msCow
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
        displayName: "apple",
        displayNameWithArticle: "an apple",
        description: "a shiny red apple, healthy and delicious"
    )

    static let BALLOON = StoryObject(
        id: "BALLOON",
        imageName: "balloon",
        displayName: "balloon",
        displayNameWithArticle: "a balloon",
        description: "a colorful balloon that floats in the air",
        size: .large
    )

    static let BASKETBALL = StoryObject(
        id: "BASKETBALL",
        imageName: "basketball",
        displayName: "basketball",
        displayNameWithArticle: "a basketball",
        description: "an orange basketball for playing and bouncing"
    )

    static let BOOK = StoryObject(
        id: "BOOK",
        imageName: "book",
        displayName: "book",
        displayNameWithArticle: "a book",
        description: "a book full of stories and knowledge"
    )

    static let BURGER = StoryObject(
        id: "BURGER",
        imageName: "burger",
        displayName: "burger",
        displayNameWithArticle: "a burger",
        description: "a tasty burger with all the fixings"
    )

    static let CAKE = StoryObject(
        id: "CAKE",
        imageName: "cake",
        displayName: "cake",
        displayNameWithArticle: "a cake",
        description: "a delicious cake perfect for celebrations"
    )

    static let CRAYON = StoryObject(
        id: "CRAYON",
        imageName: "crayon",
        displayName: "crayon",
        displayNameWithArticle: "a crayon",
        description: "a colorful crayon for drawing and creating art"
    )

    static let TEDDY = StoryObject(
        id: "TEDDY",
        imageName: "teddy",
        displayName: "teddy bear",
        displayNameWithArticle: "a teddy bear",
        description: "a soft and cuddly teddy bear"
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

/// Theme categorizes the story's central concept for template matching.
/// Used by FallbackStoryService to find appropriate story templates when
/// Apple Intelligence is not available.
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
