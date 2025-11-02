//
//  ThemeManager.swift
//  RosaWriter
//
//  Created by Armin on 10/19/25.
//

import SwiftUI
import Combine

class ThemeManager: ObservableObject {
  // Persisted keys
  private let legacyKey = "isDarkMode"
  private let themeKey = "appTheme"

  // Use @Published for ObservableObject change notifications
  @Published var colorScheme: ColorScheme? {
    didSet {
      // Persist changes to UserDefaults whenever the value updates
      if let scheme = colorScheme {
        UserDefaults.standard.set(scheme == .dark, forKey: legacyKey)
        UserDefaults.standard.set(scheme == .dark ? "Dark" : "Light", forKey: themeKey)
      } else {
        UserDefaults.standard.removeObject(forKey: legacyKey)
        UserDefaults.standard.set("System", forKey: themeKey)
      }
    }
  }

  var isDarkMode: Bool {
    colorScheme == .dark
  }

  init() {
    // Initialize from persisted storage
    let savedTheme = UserDefaults.standard.string(forKey: themeKey)

    if savedTheme == "System" {
      self.colorScheme = nil
    } else if savedTheme == "Dark" {
      self.colorScheme = .dark
    } else if savedTheme == "Light" {
      self.colorScheme = .light
    } else {
      // Legacy support: check old key
      let legacyDarkMode = UserDefaults.standard.bool(forKey: legacyKey)
      self.colorScheme = legacyDarkMode ? .dark : .light
    }
  }

  func toggleTheme() {
    // Toggle between light and dark (legacy behavior)
    colorScheme = (colorScheme == .dark) ? .light : .dark
  }
  
  func setTheme(_ scheme: ColorScheme?) {
    colorScheme = scheme
  }
}
