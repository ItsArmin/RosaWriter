# Story Templates V1 Documentation

## Overview

RosaWriter uses a template-based story generation system as a fallback when Apple Intelligence is not available. Templates provide pre-written story structures with dynamic placeholders that get filled in with user-selected characters, objects, and personalized dialogue.

## Version 2.0.0

Current template version includes **20 templates**:
- 10 five-page templates
- 10 ten-page templates

## Template Structure

Each template is a JSON object with the following structure:

```json
{
  "id": "mood_theme_pagecount_number",
  "mood": "Adventure",
  "theme": "Birthday", 
  "pageCount": 5,
  "title": "{{MAIN_CHARACTER}}'s Birthday Adventure",
  "titleVariants": ["Alternative Title 1", "Alternative Title 2"],
  "pages": [
    {
      "pageNumber": 1,
      "text": "Story text with {{PLACEHOLDERS}}...",
      "textVariants": ["Alternative version of the same page..."],
      "suggestedImages": ["{{MAIN_CHARACTER}}", "{{OBJECT_1}}"]
    }
  ]
}
```

## Mood/Theme Coverage

### 5-Page Templates (10 total)

| ID | Mood | Theme |
|----|------|-------|
| adventure_birthday_5p_001 | Adventure | Birthday |
| friendship_adventure_5p_001 | Friendship | Adventure |
| adventure_adventure_5p_001 | Adventure | Adventure |
| friendship_friendship_5p_001 | Friendship | Friendship |
| silly_celebration_5p_001 | Silly | Celebration |
| learning_learning_5p_001 | Learning | Learning |
| mystery_mystery_5p_001 | Mystery | Mystery |
| kindness_friendship_5p_001 | Kindness | Friendship |
| courage_adventure_5p_001 | Courage | Adventure |
| fantasy_adventure_5p_001 | Fantasy | Adventure |

### 10-Page Templates (10 total)

| ID | Mood | Theme |
|----|------|-------|
| adventure_birthday_10p_001 | Adventure | Birthday |
| friendship_adventure_10p_001 | Friendship | Adventure |
| adventure_adventure_10p_001 | Adventure | Adventure |
| friendship_friendship_10p_001 | Friendship | Friendship |
| silly_celebration_10p_001 | Silly | Celebration |
| learning_learning_10p_001 | Learning | Learning |
| mystery_mystery_10p_001 | Mystery | Mystery |
| kindness_friendship_10p_001 | Kindness | Friendship |
| courage_adventure_10p_001 | Courage | Adventure |
| fantasy_adventure_10p_001 | Fantasy | Adventure |

## Available Placeholders

### Character Placeholders

| Placeholder | Description |
|-------------|-------------|
| `{{MAIN_CHARACTER}}` | Main character's display name (e.g., "Mr. Dog") |
| `{{PRONOUN_SUBJECTIVE}}` | he/she/they |
| `{{PRONOUN_OBJECTIVE}}` | him/her/them |
| `{{PRONOUN_POSSESSIVE}}` | his/her/their |
| `{{SIDE_CHARACTER}}` | Side character's display name |
| `{{SIDE_PRONOUN_SUBJECTIVE}}` | Side character's he/she/they |
| `{{SIDE_PRONOUN_OBJECTIVE}}` | Side character's him/her/them |
| `{{SIDE_PRONOUN_POSSESSIVE}}` | Side character's his/her/their |

### Voice Placeholders (Character Personality)

| Placeholder | Description |
|-------------|-------------|
| `{{VOICE_GREETING}}` | Main character's greeting phrase |
| `{{VOICE_FAREWELL}}` | Main character's farewell phrase |
| `{{VOICE_EXCITED}}` | Main character's excited exclamation |
| `{{VOICE_THINKING}}` | Main character's thinking phrase |
| `{{VOICE_AGREEMENT}}` | Main character's agreement phrase |
| `{{VOICE_SURPRISE}}` | Main character's surprise exclamation |
| `{{SIDE_VOICE_GREETING}}` | Side character's greeting |
| `{{SIDE_VOICE_FAREWELL}}` | Side character's farewell |
| `{{SIDE_VOICE_EXCITED}}` | Side character's excited phrase |
| `{{SIDE_VOICE_THINKING}}` | Side character's thinking phrase |
| `{{SIDE_VOICE_AGREEMENT}}` | Side character's agreement phrase |
| `{{SIDE_VOICE_SURPRISE}}` | Side character's surprise phrase |

### Object Placeholders

| Placeholder | Description |
|-------------|-------------|
| `{{OBJECT_1}}` | First object name (e.g., "apple") |
| `{{OBJECT_2}}` | Second object name |
| `{{A_OBJECT_1}}` | First object with article (e.g., "an apple") |
| `{{A_OBJECT_2}}` | Second object with article |

## Template Selection Logic

The `FallbackStoryService` selects templates using this priority:

1. **Exact match**: mood + theme + pageCount
2. **Mood match only**: Same mood, any theme, closest pageCount
3. **Theme match only**: Any mood, same theme, closest pageCount  
4. **Random fallback**: Any available template

## Character Voice System

Each character has a unique voice with phrases for different emotions:

### Example: Mr. Dog
- Greeting: "Hello there!", "Hey friend!", "Woof woof!"
- Farewell: "See you later!", "Bye for now!", "Take care, friend!"
- Excited: "Oh boy, oh boy!", "This is amazing!", "Woof! How exciting!"
- Thinking: "Hmm, let me think...", "I wonder...", "What if..."
- Agreement: "Sounds good to me!", "I'm in!", "Let's do it!"
- Surprise: "Wow!", "Oh my!", "Well, woof my whiskers!"

### Example: Sir Whiskers
- Greeting: "Good day!", "Greetings!", "Meow, hello!"
- Farewell: "Until we meet again!", "Farewell!", "Take care!"
- Excited: "How delightful!", "Splendid!", "Marvelous!"
- Thinking: "Curious...", "Let me ponder this...", "Interesting..."
- Agreement: "Indeed!", "Quite right!", "I concur!"
- Surprise: "My word!", "Gracious!", "How extraordinary!"

## Writing Guidelines

When creating new templates:

1. **Use quotation marks** for all character dialogue
2. **Use `{{A_OBJECT_X}}` placeholders** when objects need articles in sentences
3. **Include voice placeholders** naturally in dialogue
4. **Provide text variants** for variety in repeated readings
5. **Keep tone friendly** and age-appropriate
6. **Ensure proper grammar** with placeholder substitution
7. **Balance dialogue and narration** for engaging stories

## File Locations

- Templates: `mobile/RosaWriter/RosaWriter/Resources/story_templates.json`
- Template Model: `mobile/RosaWriter/RosaWriter/Models/StoryTemplate.swift`
- Template Renderer: `mobile/RosaWriter/RosaWriter/Services/TemplateRenderer.swift`
- Fallback Service: `mobile/RosaWriter/RosaWriter/Services/FallbackStoryService.swift`
- Character Voices: `mobile/RosaWriter/RosaWriter/Utils/StoryAssets.swift`

## Future Improvements

- Add more mood/theme combinations
- Create 15-page templates for longer stories
- Add seasonal/holiday-themed templates
- Expand character voice vocabulary
- Add more object variety
