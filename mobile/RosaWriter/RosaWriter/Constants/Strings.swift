//
//  Strings.swift
//  RosaWriter
//
//  Created by Armin on 12/8/25.
//

import Foundation

/// Centralized user-facing strings for consistency and future localization.
enum Strings {

  // MARK: - App

  static let appName = "Rosa Writer"

  // MARK: - Navigation

  static let myLibrary = "My Library"
  static let createYourStory = "Create Your Story"

  // MARK: - Actions

  static let createStory = "Create Story"
  static let creatingStory = "Creating Story..."
  static let createStoryExclaim = "Create Story!"
  static let cancel = "Cancel"
  static let select = "Select"
  static let ok = "OK"
  static let delete = "Delete"
  static let resetSampleBooks = "Reset Sample Books"

  // MARK: - Empty State

  static let noBooksYet = "No Books Yet"
  static let createFirstStory = "Create your first story to get started!"

  // MARK: - Errors

  static let error = "Error"
  static let libraryFull = "Library Full"

  static func libraryFullMessage(maxBooks: Int) -> String {
    "You've reached the maximum of \(maxBooks) books. Please delete a book to create a new one."
  }

  // MARK: - Storage Error

  static let unableToOpenLibrary = "Unable to Open Library"
  static let storageErrorMessage =
    "Rosa Writer couldn't access your story library. This is usually caused by low storage space on your device."
  static let technicalDetails = "Technical Details"

  // Storage error recovery steps
  static let freeUpStorage = "Free up storage space on your device"
  static let restartApp = "Restart the app"
  static let reinstallApp = "If the problem persists, reinstall the app"

  // MARK: - Settings

  static let resetSampleBooksDescription =
    "Restore the default sample books to their original state. This will delete any modifications to sample books."
  static let sampleBooksResetSuccess = "Sample books have been reset successfully."

  // MARK: - Apple Intelligence

  static let appleIntelligence = "Apple Intelligence"
  static let aiStatusAvailable = "Available"
  static let aiStatusNotAvailable = "Not Available"
  static let aiDescription =
    "Rosa Writer uses Apple Intelligence to create unique, personalized stories. Without it, stories are generated from templates."
  static let aiRequirements =
    "Requires iPhone 15 Pro or newer with Apple Intelligence enabled in Settings."
}
