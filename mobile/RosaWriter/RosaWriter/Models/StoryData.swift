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
  
  // MARK: - Future-proofing fields (optional for backward compatibility)

  /// Schema version for migration tracking
  var schemaVersion: Int?

  /// Whether this is a sample book (denormalized for easier querying)
  var isSample: Bool?

  /// Last modified date (separate from createdAt)
  var lastModified: Date?

  init(
    id: UUID = UUID(),
    createdAt: Date = Date(),
    title: String,
    coverImage: String? = nil,
    wordCount: Int? = nil,
    storyJson: String,
    schemaVersion: Int? = 2,  // Start at 2 since we're adding this now
    isSample: Bool? = nil,
    lastModified: Date? = nil
  ) {
    self.id = id
    self.createdAt = createdAt
    self.title = title
    self.coverImage = coverImage
    self.wordCount = wordCount
    self.storyJson = storyJson
    self.schemaVersion = schemaVersion
    self.isSample = isSample
    self.lastModified = lastModified ?? createdAt  // Preserve original timestamp for migrations
  }
}
