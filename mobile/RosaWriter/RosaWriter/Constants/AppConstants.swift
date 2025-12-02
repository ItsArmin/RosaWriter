//
//  AppConstants.swift
//  RosaWriter
//
//  Created by Armin on 10/19/25.
//

import Foundation

struct AppConstants {
  static let appName = "RosaWriter"
  static let appVersion = "1.0.0"
  
  // Library Limits
  static let maxBooks = 50
  static let maxPagesPerBook = 20
  
  // AI Story Generation
  static let aiBookPageOptions = [10, 12, 15, 17, 20]

  /// Returns a random page count for AI-generated stories
  static var randomAIBookPageCount: Int {
    aiBookPageOptions.randomElement() ?? 15
  }
}
