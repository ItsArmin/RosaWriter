//
//  RosaWriterTests.swift
//  RosaWriterTests
//
//  Created by Armin on 10/19/25.
//

import Foundation
import Testing

@testable import RosaWriter

// MARK: - Story Image References

/// These strings are written into every book's stored JSON, so a change in how
/// they parse would silently break existing libraries.
@Suite("Story image references")
struct StoryImageReferenceTests {

  @Test("Asset names round-trip unchanged")
  func assetRoundTrip() {
    let reference = StoryImageReference(storedValue: "mrDog")

    #expect(reference == .asset(name: "mrDog"))
    #expect(reference.storedValue == "mrDog")
    #expect(reference.isCustomImage == false)
  }

  @Test("Character files round-trip")
  func characterFileRoundTrip() {
    let reference = StoryImageReference.characterFile(name: "photo.jpg")

    #expect(reference.storedValue == "character-file:photo.jpg")
    #expect(StoryImageReference(storedValue: reference.storedValue) == reference)
    #expect(reference.isCustomImage)
  }

  @Test("Book files round-trip with their book ID")
  func bookFileRoundTrip() {
    let bookID = UUID()
    let reference = StoryImageReference.bookFile(
      bookID: bookID,
      name: "character-abc.jpg"
    )

    #expect(
      reference.storedValue
        == "book-file:\(bookID.uuidString)/character-abc.jpg"
    )
    #expect(StoryImageReference(storedValue: reference.storedValue) == reference)
    #expect(reference.isCustomImage)
  }

  @Test(
    "Malformed book files fall back to an asset name rather than crashing",
    arguments: [
      "book-file:not-a-uuid/photo.jpg",
      "book-file:photo.jpg",
      "book-file:",
    ]
  )
  func malformedBookFile(storedValue: String) {
    #expect(
      StoryImageReference(storedValue: storedValue) == .asset(name: storedValue)
    )
  }
}

// MARK: - Character Dialogue Styles

@Suite("Character dialogue styles")
struct CharacterDialogueStyleTests {

  @Test("Current values decode to themselves")
  func currentValues() {
    for style in CharacterDialogueStyle.allCases {
      #expect(CharacterDialogueStyle.fromStoredValue(style.rawValue) == style)
    }
  }

  @Test(
    "Characters saved before the rename keep a sensible voice",
    arguments: [
      ("upbeat", CharacterDialogueStyle.casual),
      ("playful", .silly),
      ("thoughtful", .formal),
    ]
  )
  func legacyValues(storedValue: String, expected: CharacterDialogueStyle) {
    #expect(CharacterDialogueStyle.fromStoredValue(storedValue) == expected)
  }

  @Test("Unrecognized values fall back to casual")
  func unknownValue() {
    #expect(CharacterDialogueStyle.fromStoredValue("nonsense") == .casual)
  }
}

// MARK: - Book Building

@MainActor
@Suite("Book building")
struct BookBuilderTests {

  private var mainCharacter: StoryCharacter { StoryAssets.MR_DOG }

  private func makeBook(pages: [DraftPage]) -> Book {
    BookBuilder.makeBook(
      title: "A Test Story",
      pages: pages,
      mainCharacter: mainCharacter,
      coverColor: .green
    )
  }

  @Test("A book gets a cover, its pages, and an ending")
  func bookStructure() {
    let book = makeBook(pages: [
      DraftPage(pageNumber: 1, text: "First.", assetIDs: []),
      DraftPage(pageNumber: 2, text: "Second.", assetIDs: []),
    ])

    #expect(book.title == "A Test Story")
    #expect(book.pages.count == 4)

    let cover = book.pages[0]
    #expect(cover.isCover)
    #expect(cover.pageNumber == 0)
    #expect(cover.text == "A Test Story")
    #expect(cover.coverColor == .green)
    #expect(cover.imageLayout == .single(imageName: mainCharacter.imageName))

    #expect(book.pages[1].text == "First.")
    #expect(book.pages[2].text == "Second.")

    let ending = book.pages[3]
    #expect(ending.text == "The End")
    #expect(ending.pageNumber == 3)
    #expect(ending.isCover == false)
  }

  @Test("The main character's ID resolves to their image")
  func mainCharacterImage() {
    let book = makeBook(pages: [
      DraftPage(pageNumber: 1, text: "Hello.", assetIDs: [mainCharacter.id])
    ])

    #expect(
      book.pages[1].imageLayout == .single(imageName: mainCharacter.imageName)
    )
  }

  @Test("Two illustrations become a staggered layout")
  func staggeredLayout() {
    let book = makeBook(pages: [
      DraftPage(
        pageNumber: 1,
        text: "Hello.",
        assetIDs: [mainCharacter.id, StoryAssets.APPLE.id]
      )
    ])

    #expect(
      book.pages[1].imageLayout
        == .staggered(
          topImage: mainCharacter.imageName,
          bottomImage: StoryAssets.APPLE.imageName
        )
    )
  }

  @Test("Unknown asset IDs are dropped rather than rendered blank")
  func unknownAssetIDs() {
    let book = makeBook(pages: [
      DraftPage(
        pageNumber: 1,
        text: "Hello.",
        assetIDs: ["NOT_A_REAL_ASSET", StoryAssets.APPLE.id]
      )
    ])

    #expect(
      book.pages[1].imageLayout
        == .single(imageName: StoryAssets.APPLE.imageName)
    )
  }
}

// MARK: - Book Storage

/// Books are persisted as JSON, so this round-trip is what protects an existing
/// library from a change to the model types.
@MainActor
@Suite("Book storage")
struct BookStorageTests {

  @Test("A book survives being written to JSON and read back")
  func jsonRoundTrip() throws {
    let original = Book(
      title: "Mr. Dog Goes Out",
      pages: [
        BookPage(
          text: "Mr. Dog Goes Out",
          pageNumber: 0,
          imageLayout: .single(imageName: "mrDog"),
          isCover: true,
          coverColor: .orange
        ),
        BookPage(
          text: "He found an apple.",
          pageNumber: 1,
          imageLayout: .staggered(topImage: "mrDog", bottomImage: "apple")
        ),
        BookPage(text: "The End", pageNumber: 2),
      ]
    )

    let json = try StorageService.shared.bookToJson(original)
    let restored = try StorageService.shared.jsonToBook(json)

    #expect(restored.id == original.id)
    #expect(restored.title == original.title)
    #expect(restored.isSample == original.isSample)
    #expect(restored.pages.count == original.pages.count)

    for (restoredPage, originalPage) in zip(restored.pages, original.pages) {
      #expect(restoredPage.id == originalPage.id)
      #expect(restoredPage.text == originalPage.text)
      #expect(restoredPage.pageNumber == originalPage.pageNumber)
      #expect(restoredPage.imageLayout == originalPage.imageLayout)
      #expect(restoredPage.isCover == originalPage.isCover)
      #expect(restoredPage.coverColor == originalPage.coverColor)
    }
  }

  @Test("Decoding something that isn't a book reports a decoding failure")
  func decodingFailure() {
    #expect(throws: (any Error).self) {
      try StorageService.shared.jsonToBook("{\"nope\": true}")
    }
  }
}

// MARK: - Character Photo Storage

@Suite("Character image file names")
struct StoryImageStorageTests {

  @Test(
    "File names that could escape the images folder are rejected",
    arguments: [
      "../escape.jpg",
      "../../Library/Preferences/thing.plist",
      "folder/photo.jpg",
      "",
    ]
  )
  func unsafeFileNames(fileName: String) {
    #expect(throws: CharacterImageError.self) {
      _ = try StoryImageStorage.characterImageURL(fileName: fileName)
    }
  }
}

// MARK: - Custom Characters

@MainActor
@Suite("Custom character crops")
struct CustomCharacterTests {

  private func makeCharacter(
    centerX: Double,
    centerY: Double,
    scale: Double
  ) -> CustomCharacter {
    CustomCharacter(
      name: "Rosa",
      kind: .person,
      pronouns: .theyThem,
      biography: "Likes stories.",
      primaryPersonality: .curious,
      imageFileName: "rosa.jpg",
      cropCenterX: centerX,
      cropCenterY: centerY,
      cropScale: scale
    )
  }

  @Test("Out-of-range crops are clamped when a character is created")
  func clampsOnInit() {
    let character = makeCharacter(centerX: -3, centerY: 4, scale: 0.2)

    #expect(character.cropCenterX == 0)
    #expect(character.cropCenterY == 1)
    #expect(character.cropScale == 1)
  }

  @Test("Out-of-range crops are clamped when a character is edited")
  func clampsOnUpdate() {
    let character = makeCharacter(centerX: 0.5, centerY: 0.5, scale: 1)

    character.updateCrop(centerX: 9, centerY: -9, scale: -1, aspect: .square)

    #expect(character.cropCenterX == 1)
    #expect(character.cropCenterY == 0)
    #expect(character.cropScale == 1)
    #expect(character.photoAspect == .square)
  }

  @Test("A name is trimmed and a blank catchphrase is dropped")
  func trimsInput() {
    let character = CustomCharacter(
      name: "  Rosa  ",
      kind: .person,
      pronouns: .sheHer,
      biography: "  Likes stories.  ",
      primaryPersonality: .kind,
      catchphrase: "   ",
      imageFileName: "rosa.jpg"
    )

    #expect(character.name == "Rosa")
    #expect(character.biography == "Likes stories.")
    #expect(character.catchphrase == nil)
  }
}
