# Rosa Writer

An iPhone app that writes illustrated bedtime stories for kids. You pick a main character, a mood and a story idea; the app writes a short picture book and puts it on your shelf. Children can add their own characters from a photo, and those characters appear in the stories they star in.

Stories are generated **on device** — nothing is sent anywhere.

## Requirements

- Xcode 26 or later
- iOS 26.0 deployment target
- A physical device for the Apple Intelligence path (see [Development notes](#development-notes))

## Build and test

```sh
cd mobile/RosaWriter

xcodebuild build -scheme RosaWriter \
  -destination 'generic/platform=iOS Simulator'

xcodebuild test -scheme RosaWriter \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:RosaWriterTests
```

Or just open `mobile/RosaWriter/RosaWriter.xcodeproj` and hit run.

## How a story gets made

`BookService.makeBook(for:)` is the single entry point. Everything else feeds it a `StoryRequest` and gets a `Book` back.

```
StoryRequest ──► BookService.makeBook(for:)
                      │
                      ├─ Apple Intelligence available?
                      │    yes ─► AIStoryService  ──┐  (falls through on failure)
                      │    no  ─► FallbackStoryService ─┤
                      │                                 │
                      │                            DraftPage[]
                      │                                 │
                      │                            BookBuilder ──► cover + pages + "The End"
                      │
                      └─ custom character? snapshot their photo into the book
```

Two things worth knowing:

- **Both paths produce identical book structure.** `BookBuilder` owns the cover page, illustration resolution and the closing page, so a template story and an Apple Intelligence story are shaped the same. They used to diverge.
- **The fallback is not an error path.** Most devices don't have Apple Intelligence, so template generation is the normal experience for many users, not a degraded one. Templates live in `Resources/story_templates.json`.

## How things are stored

Three details here are not obvious from the type names:

**Books are a JSON blob inside SwiftData, not a relational model.** A `StoryData` record holds searchable metadata (title, cover image, word count) plus the whole book serialized into `storyJson`. `StorageService` does the conversion. This keeps the shelf cheap to render, but it means a change to `Book` or `BookPage` can break an existing library — which is what `RosaWriterTests` guards.

**Image references are tagged strings.** A page's image is one of three things, distinguished by prefix:

| Stored value | Meaning |
| --- | --- |
| `mrDog` | a bundled asset |
| `character-file:<name>` | a custom character's source photo |
| `book-file:<uuid>/<name>` | one book's own copy of that photo |

Bare names are the legacy format and still parse, which is why `StoryImageReference` has tests.

**Custom character photos are snapshotted per book.** When a story is created with a user-made character, the cropped photo is copied into a book-owned file. Editing or deleting the character later can't alter a story that's already been written.

Sample books are versioned. Bumping `currentSampleBooksVersion` in `StorageService` re-seeds them on next launch; `SplashView` runs migrations and seeding before the shelf appears.

## Layout

```
mobile/RosaWriter/RosaWriter/
├── Models/       Book, BookPage, CustomCharacter, StoryRequest
├── Views/        Screens, with reusable pieces in Views/Components
├── Services/     Generation, storage, image handling
├── Utils/        Story assets, prompts, sample data
├── Constants/    Strings, app limits, debug feature flags
└── Resources/    story_templates.json
```

## Development notes

**Apple Intelligence does not run in the Simulator.** `AIStoryService.isAppleIntelligenceAvailable()` returns `false` there, so simulator builds always take the template path. Test the Apple Intelligence path on a physical device.

To force templates on a device, set `forceUseFallback = true` at the top of `AIStoryService.swift`.

**Shelf Lab** is a debug-only panel for tuning the dark-mode bookshelf. Set `DevelopmentFeatures.shelfLabEnabled = true` (it ships `false`) and a sliders icon appears in the shelf toolbar. The values it produces ship as constants in `ShelfTuning`; release builds never read its `UserDefaults` keys.

**Formatting** is enforced by `.swift-format` at the repo root:

```sh
xcrun swift-format format --in-place --recursive mobile/RosaWriter/RosaWriter
```

`mobile/RosaWriter/agents.md` holds the Swift and SwiftUI conventions for this project, and is worth reading before a first contribution.
