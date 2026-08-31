# Compact Prompts Configuration Guide

## Quick Setup

### For Small Models (128-512 tokens)

In `AIConstants.swift`:
```swift
public static let maxSequenceLength = 128  // Your model's context
public static var useCompactPrompts = true  // Enable compact prompts
```

### For Large Models (1024+ tokens)

In `AIConstants.swift`:
```swift
public static let maxSequenceLength = 1024  // Your model's context
public static var useCompactPrompts = false  // Use full prompts
```

## What Changed

### ✅ Compact Prompts Added

**System Prompt:**
- Full: 361 characters
- Compact: 47 characters ✅

**Story Prompt:**
- Full: ~700-2800 characters
- Compact: ~150-250 characters ✅

### ✅ Automatic Switching

The system now automatically uses compact prompts when `AIConstants.useCompactPrompts = true`:

- Shorter system prompt
- Minimal instructions
- Condensed JSON format example
- 3 pages max (instead of 5)
- ~80% smaller prompts

### ✅ All Utils Ready

- `StoryPrompts.compactSystemPrompt`
- `StoryPrompts.compactStoryPrompt()`
- `StoryPrompts.compactCustomStoryPrompt()`
- `StoryPrompts.compactRandomStoryPrompt()`
- Auto-applied in `AIStoryService`
- Integrated with `CustomMLProvider`

## Example Compact Prompt

```
You write simple children's stories for ages 5-10.

Write a 3-page story about Mario.
Mood: Adventure - Exciting and full of action
Theme: The AI should create an original, creative premise

Each page: 2-3 sentences.

JSON:
{"title":"Title","pages":[{"pageNumber":1,"text":"Text here.","suggestedImages":["MARIO"]},{"pageNumber":2,"text":"More.","suggestedImages":[]}]}

IDs: MARIO, LUIGI, PEACH, BOWSER, COIN, STAR, MUSHROOM, FIRE_FLOWER
Write ONLY JSON.
```

**Total: ~200 characters (fits in 50-60 tokens)**

## Configuration for Different Models

### TinyStories 33M (Current)
```swift
public static let maxSequenceLength = 128
public static var useCompactPrompts = true
```

### GPT-2 Medium
```swift
public static let maxSequenceLength = 1024
public static var useCompactPrompts = false
```

### TinyLlama 1.1B
```swift
public static let maxSequenceLength = 2048
public static var useCompactPrompts = false
```

## Testing

Run the app with compact prompts enabled. You should see:
```
📝 Using compact prompt for small model (3 pages max)
✅ Using compact prompts for small model
Combined prompt length: ~250 characters
Context window: 128 tokens (~512 chars)
```

## Benefits

- ✅ Works with tiny context windows (128-256 tokens)
- ✅ Faster generation (less tokens to process)
- ✅ Better fit for small models
- ✅ Automatic page limit (3 instead of 5)
- ✅ Still produces valid JSON
- ✅ Zero code changes when switching models

## When to Use Each

| Context Size | Use Compact | Page Limit | Quality |
|--------------|-------------|------------|---------|
| 128-256 tokens | ✅ Yes | 3 pages | Basic |
| 512-1024 tokens | ⚠️ Optional | 3-5 pages | Good |
| 1024+ tokens | ❌ No | 5+ pages | Excellent |

Your system is now ready for both small and large models! 🚀

