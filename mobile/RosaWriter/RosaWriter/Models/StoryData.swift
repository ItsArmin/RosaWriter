//
//  StoryData.swift
//  RosaWriter
//
//  Created by Armin on 10/26/25.
//

import Foundation
import SwiftData

@Model
final class StoryData {
  @Attribute(.unique) var id: UUID
  var createdAt: Date
  var title: String
  var coverImage: String?
  var wordCount: Int?
  var storyJson: String

  init(
    id: UUID = UUID(),
    createdAt: Date = Date(),
    title: String,
    coverImage: String? = nil,
    wordCount: Int? = nil,
    storyJson: String
  ) {
    self.id = id
    self.createdAt = createdAt
    self.title = title
    self.coverImage = coverImage
    self.wordCount = wordCount
    self.storyJson = storyJson
  }
}
