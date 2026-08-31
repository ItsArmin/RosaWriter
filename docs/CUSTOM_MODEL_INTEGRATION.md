# Custom Model Integration Guide

This guide explains how to complete the integration of your TinyStories model into RosaWriter.

## Architecture Overview

The custom model integration uses a **provider pattern** that keeps everything modular:

```
AIStoryService → AIConfiguration → AIProvider Protocol
                                    ├── AppleIntelligenceProvider (✅ Complete)
                                    └── CustomMLProvider → TinyStoriesRunner
```

## Files Created

### ✅ Complete (No Action Needed)
- `Services/AIProvider.swift` - Provider protocol and implementations
- `Utils/AIConfiguration.swift` - Switch between providers
- `Services/AIStoryService.swift` - Refactored to use providers
- `Models/SamplingUtils.swift` - Advanced sampling utilities

### ⚠️ Requires Implementation
- `Models/Tokenizer.swift` - Needs GPT-2 BPE tokenizer implementation
- `Models/TinyStoriesRunner.swift` - Needs model files added and minor tweaks

## Step-by-Step Implementation

### Step 1: Add Model Files to Xcode

1. **Create the directory structure:**
   - In Xcode, right-click on the project
   - New Group → Name it `Models`
   - Inside `Models`, create another group → Name it `TinyStories`

2. **Add your model files:**
   - Drag `Model.mlpackage` into `Models/TinyStories/`
   - Drag `tokenizer.json` (or `vocab.json` + `merges.txt`) into `Models/TinyStories/`
   - In the dialog, check:
     - ✅ Copy items if needed
     - ✅ Add to targets: RosaWriter
     - ✅ Create folder references

3. **Verify in Xcode:**
   - Click `Model.mlpackage` → You should see the model preview
   - Confirm I/O matches what's expected:
     - Input: `input_ids` (Int32, 1×128)
     - Input: `attention_mask` (Int32, 1×128)
     - Output: `logits` (Float32, 1×128×50257)

### Step 2: Implement the Tokenizer

Open `Models/Tokenizer.swift` and implement the `GPT2Tokenizer` class.

#### Option A: Use HuggingFace Tokenizers (Recommended)

If your model repo has `tokenizer.json`:

```swift
// In loadVocabulary():
guard let url = Bundle.main.url(
  forResource: "tokenizer",
  withExtension: "json",
  subdirectory: "Models/TinyStories"
) else {
  throw TokenizerError.resourceNotFound("tokenizer.json")
}

let data = try Data(contentsOf: url)
let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

// Extract vocab from tokenizer.json structure
if let model = json["model"] as? [String: Any],
   let vocabDict = model["vocab"] as? [String: Int] {
  self.vocab = vocabDict
  for (token, id) in vocab {
    reverseVocab[id] = token
  }
}

// Extract merges
if let model = json["model"] as? [String: Any],
   let mergesList = model["merges"] as? [String] {
  for merge in mergesList {
    let parts = merge.split(separator: " ")
    if parts.count == 2 {
      merges.append((String(parts[0]), String(parts[1])))
    }
  }
}
```

#### Option B: Use Separate vocab.json + merges.txt

If you have separate files:

```swift
// Load vocab.json
guard let vocabURL = Bundle.main.url(
  forResource: "vocab",
  withExtension: "json",
  subdirectory: "Models/TinyStories"
) else {
  throw TokenizerError.resourceNotFound("vocab.json")
}
let vocabData = try Data(contentsOf: vocabURL)
self.vocab = try JSONDecoder().decode([String: Int].self, from: vocabData)

// Build reverse mapping
for (token, id) in vocab {
  reverseVocab[id] = token
}

// Load merges.txt
guard let mergesURL = Bundle.main.url(
  forResource: "merges",
  withExtension: "txt",
  subdirectory: "Models/TinyStories"
) else {
  throw TokenizerError.resourceNotFound("merges.txt")
}
let content = try String(contentsOf: mergesURL)
let lines = content.components(separatedBy: .newlines)

for line in lines.dropFirst() {  // Skip header
  let parts = line.split(separator: " ")
  if parts.count == 2 {
    merges.append((String(parts[0]), String(parts[1])))
  }
}
```

#### BPE Encode Implementation

The `encode()` method needs to implement BPE algorithm:

```swift
func encode(_ text: String) -> [Int] {
  // 1. Pre-tokenization (split on whitespace, handle special chars)
  let words = preTokenize(text)
  
  var tokenIds: [Int] = []
  
  for word in words {
    // 2. Convert to byte-level representation
    let chars = Array(word)
    var tokens = chars.map { String($0) }
    
    // 3. Apply BPE merges
    while tokens.count > 1 {
      var minPair: (String, String)? = nil
      var minRank = Int.max
      
      // Find the highest-priority merge
      for i in 0..<(tokens.count - 1) {
        let pair = (tokens[i], tokens[i + 1])
        if let rank = merges.firstIndex(where: { $0 == pair }), rank < minRank {
          minRank = rank
          minPair = pair
        }
      }
      
      guard let pair = minPair else { break }
      
      // Apply the merge
      var newTokens: [String] = []
      var i = 0
      while i < tokens.count {
        if i < tokens.count - 1 && tokens[i] == pair.0 && tokens[i + 1] == pair.1 {
          newTokens.append(pair.0 + pair.1)
          i += 2
        } else {
          newTokens.append(tokens[i])
          i += 1
        }
      }
      tokens = newTokens
    }
    
    // 4. Convert tokens to IDs
    for token in tokens {
      if let id = vocab[token] {
        tokenIds.append(id)
      } else {
        // Handle unknown token
        tokenIds.append(vocab["<|endoftext|>"] ?? 0)
      }
    }
  }
  
  return tokenIds
}

private func preTokenize(_ text: String) -> [String] {
  // Simple whitespace tokenization
  // You may need more sophisticated pre-tokenization
  return text.components(separatedBy: .whitespaces)
}
```

#### BPE Decode Implementation

```swift
func decode(_ tokenIds: [Int]) -> String {
  var tokens: [String] = []
  
  for id in tokenIds {
    if id == eosTokenId {
      break  // Stop at EOS
    }
    if let token = reverseVocab[id] {
      tokens.append(token)
    }
  }
  
  // Join and decode byte-level representation
  let joined = tokens.joined()
  return joined
}
```

### Step 3: Test the Tokenizer

Before running the full model, test your tokenizer:

```swift
let tokenizer = try GPT2Tokenizer()
let tokens = tokenizer.encode("Once upon a time")
print("Tokens: \(tokens)")
let decoded = tokenizer.decode(tokens)
print("Decoded: \(decoded)")
```

### Step 4: Improve Sampling in TinyStoriesRunner

Open `Models/TinyStoriesRunner.swift` and update the `nucleusSample` method:

```swift
private func nucleusSample(probs: [Float], topP: Float) -> Int {
  return SamplingUtils.nucleusSample(probs: probs, topP: topP)
}
```

### Step 5: Switch to Custom Provider

In `Utils/AIConfiguration.swift`, change:

```swift
static let currentProvider: AIProviderType = .customML
```

### Step 6: Test Generation

Run the app and try generating a story:

1. The app will use your custom model
2. Watch the console for debug output
3. Check that:
   - Model loads successfully
   - Token generation works
   - JSON parsing succeeds
   - Story displays correctly

### Step 7: Tune Parameters

If generation quality isn't good, adjust in `CustomMLProvider`:

```swift
let config = DecodeCfg(
  temperature: 0.8,        // Higher = more creative
  topP: 0.95,              // Higher = more variety
  repetitionPenalty: 1.2,  // Higher = less repetition
  maxNewTokens: 400        // Longer stories
)
```

## Troubleshooting

### Model Not Found
- Check that `Model.mlpackage` is in `Models/TinyStories/` in Xcode
- Verify target membership is checked
- Clean build folder (Cmd+Shift+K) and rebuild

### Tokenizer Errors
- Verify `tokenizer.json` (or `vocab.json`/`merges.txt`) is in bundle
- Check file names match exactly (case-sensitive)
- Print loaded vocab size to confirm: `print("Vocab size: \(vocab.count)")`

### Invalid Output / Gibberish
- Lower temperature (try 0.5)
- Increase repetition penalty (try 1.3)
- Check that your prompt format matches what the model was trained on
- Verify vocab size matches (should be 50,257)

### Slow Generation
- Reduce `maxNewTokens` (try 200)
- Check device capabilities (Neural Engine availability)
- Consider reducing context window if needed

### Repeating Text
- Increase `repetitionPenalty` to 1.5
- Use no-repeat n-gram in `applyRepetitionPenalty()`:
  ```swift
  let adjusted = SamplingUtils.applyNoRepeatNGram(
    logits: logits,
    generatedTokens: generatedSoFar,
    nGramSize: 3
  )
  ```

## Quick Reference: What You Need to Implement

1. ✅ **Add model files to Xcode** (drag and drop)
2. ⚠️ **Implement `GPT2Tokenizer.loadVocabulary()`** (~20 lines)
3. ⚠️ **Implement `GPT2Tokenizer.loadMerges()`** (~15 lines)
4. ⚠️ **Implement `GPT2Tokenizer.encode()`** (~50 lines of BPE logic)
5. ⚠️ **Implement `GPT2Tokenizer.decode()`** (~10 lines)
6. ✅ **Switch provider in AIConfiguration** (change 1 line)
7. ✅ **Test and tune** (adjust parameters)

## Testing Checklist

- [ ] Model.mlpackage loads without errors
- [ ] Tokenizer loads vocab (print vocab size)
- [ ] Tokenizer can encode simple text
- [ ] Tokenizer can decode token IDs
- [ ] Model generates text (even if quality is poor)
- [ ] Generated text parses as JSON
- [ ] Story displays in the app
- [ ] Quality is acceptable (tune if needed)
- [ ] No crashes or memory issues
- [ ] Performance is reasonable on target devices

## Next Steps

Once everything works:
- Consider adding user-facing toggle in Settings
- Add model attribution/license info
- Test on multiple devices (iPhone 11, 13, 15)
- Compare quality with Apple Intelligence
- Profile performance and optimize if needed

Good luck! 🚀

