//
//  StoryRequest.swift
//  RosaWriter
//
//  Created by Armin on 8/30/26.
//

import Foundation

/// The choices made in Create Story, in the form `BookService` needs to write
/// a book from them.
struct StoryRequest {
  let mainCharacter: StoryCharacter
  let mood: StoryMood
  let spark: StorySpark
  let coverColor: CoverColor

  /// Set when the main character is user-made, so the finished book can keep
  /// its own copy of the photo.
  let customPhoto: CustomCharacterPhoto?
}

/// A user-made character's photo, as one book should show it.
struct CustomCharacterPhoto {
  let fileName: String
  let crop: CharacterPhotoCrop
}
