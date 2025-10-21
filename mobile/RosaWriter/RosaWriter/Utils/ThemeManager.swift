//
//  ThemeManager.swift
//  RosaWriter
//
//  Created by Armin on 10/19/25.
//

import SwiftUI
import Combine

class ThemeManager: ObservableObject {
  // Persisted key for dark mode preference
  private let key = "isDarkMode"

  // Use @Published for ObservableObject change notifications
  @Published var isDarkMode: Bool {
    didSet {
      // Persist changes to UserDefaults whenever the value updates
      UserDefaults.standard.set(isDarkMode, forKey: key)
    }
  }

  init() {
    // Initialize from persisted storage (defaults to false)
    self.isDarkMode = UserDefaults.standard.bool(forKey: key)
  }

  var colorScheme: ColorScheme {
    isDarkMode ? .dark : .light
  }

  func toggleTheme() {
    isDarkMode.toggle()
  }
}
