# Xcode Setup Checklist for Custom Model

## Problem
Getting `modelNotFound` error even though files exist on disk. This means Xcode isn't including them in the app bundle.

## Solution: Ensure Target Membership

### Step 1: Check Model.mlpackage

1. **In Xcode**, find `Model.mlpackage` in the project navigator (left sidebar)
   - It should be at: `AI/Models/TinyStories33M/Model.mlpackage`

2. **Click on Model.mlpackage** to select it

3. **Open File Inspector** (right sidebar)
   - If not visible: View → Inspectors → Show File Inspector (Cmd+Opt+1)

4. **Check "Target Membership" section**
   - ✅ Ensure "RosaWriter" is **checked**
   - If unchecked, check it now

### Step 2: Check vocab.json

1. Find `vocab.json` at: `AI/Models/TinyStories33M/vocab.json`
2. Select it
3. File Inspector → Target Membership
4. ✅ Ensure "RosaWriter" is **checked**

### Step 3: Check merges.txt

1. Find `merges.txt` at: `AI/Models/TinyStories33M/merges.txt`
2. Select it
3. File Inspector → Target Membership
4. ✅ Ensure "RosaWriter" is **checked**

### Step 4: Clean and Rebuild

1. **Clean Build Folder**
   - Product → Clean Build Folder (Cmd+Shift+K)
   - Or: Press and hold Option, then Product → Clean Build Folder

2. **Rebuild**
   - Product → Build (Cmd+B)

3. **Run the App**
   - Product → Run (Cmd+R)

## What Changed

### New Files
- ✅ **AIConstants.swift** - Centralized configuration for all AI constants
  - Model paths
  - Tokenizer configuration
  - Generation defaults
  - Smart resource discovery functions
  - Debug helpers to find missing files

### Updated Files
- ✅ **TinyStoriesRunner.swift** - Now uses `AIConstants` for smart model loading
- ✅ **Tokenizer.swift** - Now uses `AIConstants` for smart file discovery
- ✅ **AIProvider.swift** - Better error messages with troubleshooting steps

## Debug Information

When you run the app now, you'll see detailed logs:

### If Model is Found
```
🔍 Searching for model in bundle...
✅ Found model at: /path/to/Model.mlpackage
📦 Loading model from: /path/to/Model.mlpackage
✅ Model loaded successfully
```

### If Model is NOT Found
```
🔍 Searching for model in bundle...
❌ MODEL NOT FOUND IN BUNDLE
📋 Debug information:
🔍 Searching for all .mlpackage files in bundle...
   ⚠️ No .mlpackage or .mlmodelc files found in bundle
   💡 Make sure to:
      1. Add Model.mlpackage to Xcode project
      2. Check 'Copy items if needed'
      3. Ensure target membership includes RosaWriter
      4. Clean build folder (Cmd+Shift+K) and rebuild
```

This tells you exactly what's missing and what to do!

## Alternative: Re-add Files

If target membership doesn't fix it, try re-adding the files:

1. **Remove references** (don't delete files)
   - Right-click on `AI` folder → Delete
   - Choose "Remove Reference" (NOT "Move to Trash")

2. **Re-add files**
   - Drag the `AI` folder from Finder into Xcode
   - In the dialog:
     - ✅ Check "Copy items if needed"
     - ✅ Select "Create folder references"
     - ✅ Add to targets: RosaWriter
   - Click "Finish"

3. **Clean and rebuild** (Step 4 above)

## Verify It Works

After fixing, you should see:
```
🤖 Initializing TinyStoriesRunner...
🔍 Searching for model in bundle...
✅ Found model at: /path/to/Model.mlpackage
📦 Loading model from: /path/to/Model.mlpackage
✅ Model loaded successfully
🔍 Searching for vocabulary file...
✅ Found vocab.json at: /path/to/vocab.json
✅ Loaded 50257 tokens from vocabulary
🔍 Searching for merges file...
✅ Found merges.txt at: /path/to/merges.txt
✅ Loaded XXXXX BPE merges
✅ TinyStoriesRunner initialized successfully
✅ CustomMLProvider initialized successfully
```

## Still Not Working?

The new `AIConstants` has search functions that will:
1. Search multiple possible locations automatically
2. List all .mlpackage files actually in the bundle
3. List all tokenizer files in the bundle
4. Give you exact paths of what's included

Check the console output carefully - it will tell you exactly what's wrong!

