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
  static let maxPagesPerBook = 10
  
  // AI Story Generation (picks randomly from 5-10 pages)
  static let aiBookPageOptions = [5, 6, 7, 8, 9, 10]

  /// Returns a random page count for AI-generated stories
  static var randomAIBookPageCount: Int {
    aiBookPageOptions.randomElement() ?? maxPagesPerBook
  }
}
