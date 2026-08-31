//
//  BookBuilder.swift
//  RosaWriter
//
//  Created by Armin on 8/30/26.
//

import Foundation

/// One generated page, before it becomes a `BookPage`.
struct DraftPage {
  let pageNumber: Int
  let text: String
  let assetIDs: [String]
}

/// Assembles generated pages into a finished book. Both the Apple Intelligence
/// and template paths come through here so their books have the same shape.
enum BookBuilder {
  static func makeBook(
    title: String,
    pages: [DraftPage],
    mainCharacter: StoryCharacter,
    coverColor: CoverColor
  ) -> Book {
    var book = Book(title: title)

    book.addPage(
      BookPage(
        text: title,
        pageNumber: 0,
        imageLayout: .single(imageName: mainCharacter.imageName),
        isCover: true,
        coverColor: coverColor
      )
    )

    for page in pages {
      book.addPage(
        BookPage(
          text: page.text,
          pageNumber: page.pageNumber,
          imageLayout: imageLayout(
            for: page.assetIDs,
            mainCharacter: mainCharacter
          )
        )
      )
    }

    book.addPage(
      BookPage(
        text: "The End",
        pageNumber: book.pages.count,
        imageLayout: .none
      )
    )

    return book
  }

  /// Resolves asset IDs to image names, dropping any this build doesn't have.
  private static func imageLayout(
    for assetIDs: [String],
    mainCharacter: StoryCharacter
  ) -> PageImageLayout {
    let imageNames = assetIDs.compactMap { assetID -> String? in
      if assetID == mainCharacter.id {
        return mainCharacter.imageName
      }
      if let character = StoryAssets.character(for: assetID) {
        return character.imageName
      }
      return StoryAssets.object(for: assetID)?.imageName
    }

    switch imageNames.count {
    case 0:
      return .none
    case 1:
      return .single(imageName: imageNames[0])
    default:
      return .staggered(topImage: imageNames[0], bottomImage: imageNames[1])
    }
  }
}
