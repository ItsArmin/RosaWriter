# Custom Model Integration - Quick TODO List

## Your Implementation Checklist

### 🔴 Critical TODOs (Must Implement)

#### 1. Add Model Files to Xcode
Location: Xcode project → `Models/TinyStories/`

- [ ] Create folder structure: `Models/TinyStories/` in Xcode
- [ ] Add `Model.mlpackage` (check target membership)
- [ ] Add `tokenizer.json` OR (`vocab.json` + `merges.txt`)
- [ ] Verify model shows correct I/O in Xcode preview

#### 2. Implement Tokenizer Loading
File: `mobile/RosaWriter/RosaWriter/Models/Tokenizer.swift`

**In `GPT2Tokenizer.loadVocabulary()`:**
```swift
// TODO: Load vocab.json or tokenizer.json from bundle
// Set self.vocab = [token: id]
// Build self.reverseVocab = [id: token]
```

**In `GPT2Tokenizer.loadMerges()`:**
```swift
// TODO: Load merges.txt or extract from tokenizer.json
// Populate self.merges = [(token1, token2)]
```

#### 3. Implement BPE Encode/Decode
File: `mobile/RosaWriter/RosaWriter/Models/Tokenizer.swift`

**In `GPT2Tokenizer.encode(_ text: String)`:**
```swift
// TODO: Implement BPE encoding
// 1. Pre-tokenize (split text)
// 2. Apply BPE merges
// 3. Convert tokens to IDs
// Return [Int] array of token IDs
```

**In `GPT2Tokenizer.decode(_ tokenIds: [Int])`:**
```swift
// TODO: Implement BPE decoding
// 1. Convert IDs to tokens
// 2. Join tokens
// 3. Handle special chars
// Return decoded String
```

### 🟡 Optional Improvements (For Better Quality)

#### 4. Improve Sampling (Optional but Recommended)
File: `mobile/RosaWriter/RosaWriter/Models/TinyStoriesRunner.swift`

**In `nucleusSample()`:**
```swift
// TODO: Replace placeholder with real implementation
// Use: SamplingUtils.nucleusSample(probs: probs, topP: topP)
```

Currently implemented: Greedy sampling (works but lower quality)
Recommended: Nucleus sampling for better variety

#### 5. Tune Generation Parameters
File: `mobile/RosaWriter/RosaWriter/Services/AIProvider.swift`

In `CustomMLProvider.generateText()`, adjust:
```swift
let config = DecodeCfg(
  temperature: 0.7,         // Adjust: 0.5-1.0
  topP: 0.9,                // Adjust: 0.8-0.95
  repetitionPenalty: 1.15,  // Adjust: 1.0-1.5
  maxNewTokens: 300         // Adjust: 200-500
)
```

### 🟢 Final Steps

#### 6. Switch to Custom Provider
File: `mobile/RosaWriter/RosaWriter/Utils/AIConfiguration.swift`

Change line 27:
```swift
static let currentProvider: AIProviderType = .customML
```

#### 7. Test & Debug
- [ ] Run app, watch console for errors
- [ ] Try generating a 1-page story first
- [ ] Verify JSON output is valid
- [ ] Check story displays correctly
- [ ] Tune parameters if needed

## File Summary

### ✅ Complete (No Action Needed)
- `Services/AIProvider.swift` - Provider implementations
- `Utils/AIConfiguration.swift` - Provider switcher
- `Models/SamplingUtils.swift` - Advanced sampling utilities
- `Models/TinyStoriesRunner.swift` - Core ML runner (skeleton ready)

### ⚠️ Need Your Implementation
- `Models/Tokenizer.swift` - **3 methods to implement**
  - `loadVocabulary()` (~20 lines)
  - `loadMerges()` (~15 lines)
  - `encode()` (~50 lines)
  - `decode()` (~10 lines)

## Quick Test Plan

1. **Tokenizer Test** (Do this first!)
```swift
let tok = try GPT2Tokenizer()
print("Vocab size: \(tok.vocab.count)")  // Should be ~50257
let tokens = tok.encode("Hello world")
print("Tokens: \(tokens)")
let text = tok.decode(tokens)
print("Decoded: \(text)")  // Should be "Hello world"
```

2. **Model Test**
- Switch to `.customML` in AIConfiguration
- Run app and generate a story
- Watch console for errors
- Check story displays

3. **Quality Test**
- Generate multiple stories
- Check for repetition
- Verify JSON structure
- Tune parameters as needed

## Help & Resources

- **Detailed Guide:** `CUSTOM_MODEL_INTEGRATION.md`
- **Architecture Overview:** Already implemented provider pattern
- **Sample Code:** See TODO comments in each file

## Estimated Time

- ⏱️ Add model files: 5 minutes
- ⏱️ Implement tokenizer: 1-2 hours (depending on complexity)
- ⏱️ Test & tune: 30 minutes
- **Total: ~2-3 hours**

## If You Get Stuck

1. Start with tokenizer - it's the hardest part
2. Use `SimpleCharTokenizer` temporarily to test model loading
3. Check console logs for detailed error messages
4. Verify file paths and target membership in Xcode
5. Test tokenizer standalone before running full model

Good luck! You've got this! 🚀

