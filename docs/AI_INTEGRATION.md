# AI Story Generation Integration

This document explains how the app is structured to generate stories using Apple Intelligence.

## Architecture Overview

The AI integration consists of four main components:

### 1. **StoryAssets.swift** - Asset Mapping

Maps story elements to their display properties:

-   `StoryCharacter`: Characters like Mario, Luigi, Peach, and Bowser
-   `StoryObject`: Objects like coins, stars, mushrooms, etc.
-   Each asset has:
    -   `id`: Unique identifier (e.g., "MARIO", "COIN")
    -   `imageName`: Asset catalog image name
    -   `displayName`: Human-readable name
    -   `description`: Brief description for AI context

### 2. **StoryPrompts.swift** - Prompt Templates

Contains all prompts for the AI system:

-   `systemPrompt`: Defines the AI's role as a children's story writer
-   `generateStoryPrompt()`: Creates prompts with specific characters/objects
-   `randomStoryPrompt()`: Generates prompts with random assets
-   `refinePagePrompt()`: Refines existing story pages

The prompts instruct the AI to:

-   Generate age-appropriate stories (5-10 years old)
-   Use specific characters and objects from our asset library
-   Return structured JSON responses
-   Include image placement suggestions

### 3. **AIStoryService.swift** - AI Integration Service

Handles the actual AI communication:

-   `generateStory()`: Generate a random story
-   `generateStoryWithAssets()`: Generate with specific characters/objects
-   Parses AI JSON responses into `AIStoryResponse` models
-   Converts AI responses to `Book` objects
-   Handles errors and provides fallback to sample data

### 4. **BookService.swift** - Main Service Layer

Updated to use AI generation:

-   `createNewBook()`: Now async, attempts AI generation
-   Falls back to sample data if AI is unavailable
-   Provides both simple and parameterized generation methods

## Data Flow

```
User Request
    ↓
BookService.createNewBook()
    ↓
AIStoryService.generateStory()
    ↓
StoryPrompts.randomStoryPrompt()
    ↓
[Apple Intelligence API]
    ↓
Parse JSON Response
    ↓
Convert to Book with mapped images
    ↓
Return to UI
```

## How to Complete the Integration

The placeholder in `AIStoryService.callAppleIntelligence()` needs to be implemented with Apple's actual API.

### Apple Intelligence Options (iOS 18+):

#### Option 1: App Intents with Intelligence

```swift
import AppIntents

// Create an App Intent for story generation
struct GenerateStoryIntent: AppIntent {
    static var title: LocalizedStringResource = "Generate Story"

    @Parameter(title: "Prompt")
    var prompt: String

    func perform() async throws -> some IntentResult {
        // Use Apple Intelligence here
    }
}
```

#### Option 2: Writing Tools Integration

```swift
// Use NSAttributedString with Writing Tools
// This requires iOS 18+ and compatible hardware
```

#### Option 3: OpenAI Integration (Alternative)

If Apple Intelligence is not available, you could integrate with OpenAI:

```swift
import Foundation

private func callAppleIntelligence(prompt: String) async throws -> String {
    let url = URL(string: "https://api.openai.com/v1/chat/completions")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer YOUR_API_KEY", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let body: [String: Any] = [
        "model": "gpt-4",
        "messages": [
            ["role": "system", "content": StoryPrompts.systemPrompt],
            ["role": "user", "content": prompt]
        ],
        "temperature": 0.8,
        "response_format": ["type": "json_object"]
    ]

    request.httpBody = try JSONSerialization.data(withJSONObject: body)

    let (data, _) = try await URLSession.shared.data(for: request)
    let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)

    return response.choices.first?.message.content ?? ""
}
```

## Available Assets

### Characters

-   MARIO - "Mario" (mario.png)
-   LUIGI - "Luigi" (luigi.png)
-   PEACH - "Princess Peach" (peach.png)
-   BOWSER - "Bowser" (bowser.png)

### Objects

-   ONE_UP - "1-Up Mushroom" (1up.png)
-   COIN - "Gold Coin" (coin.png)
-   STAR - "Power Star" (star.png)
-   FIRE_FLOWER - "Fire Flower" (fireflower.png)
-   SPAGHETTI - "Spaghetti" (spaghetti.png)
-   GOOMBA - "Goomba" (goomba.png)

## Expected AI Response Format

```json
{
	"title": "Mario's Adventure",
	"pages": [
		{
			"pageNumber": 1,
			"text": "Once upon a time, Mario set out on a grand adventure...",
			"suggestedImages": ["MARIO", "COIN"]
		},
		{
			"pageNumber": 2,
			"text": "Along the way, he met his friend Luigi...",
			"suggestedImages": ["MARIO", "LUIGI"]
		}
	]
}
```

## Usage Examples

### Generate a random story

```swift
let book = await BookService.shared.createNewBook()
```

### Generate with specific parameters

```swift
let book = await BookService.shared.createNewBook(
    pageCount: 5,
    theme: "friendship and teamwork",
    coverColor: .blue
)
```

### Generate with specific assets

```swift
let characters = [StoryAssets.MARIO, StoryAssets.PEACH]
let objects = [StoryAssets.STAR, StoryAssets.COIN]

let book = try await AIStoryService.shared.generateStoryWithAssets(
    characters: characters,
    objects: objects,
    pageCount: 5,
    theme: "saving the kingdom",
    coverColor: .red
)
```

## Testing

Currently, the AI integration will fail gracefully and fall back to sample data. To test:

1. Call `BookService.shared.createNewBook()` from your UI
2. The service will attempt AI generation
3. When it fails (placeholder), it returns a random sample book
4. Once you implement the actual AI API, it will use that instead

## Next Steps

1. Choose your AI integration method (Apple Intelligence or alternative)
2. Implement `callAppleIntelligence()` in `AIStoryService.swift`
3. Test with various prompts and parameters
4. Add error handling and user feedback for generation progress
5. Consider adding story customization UI (character selection, themes, etc.)
