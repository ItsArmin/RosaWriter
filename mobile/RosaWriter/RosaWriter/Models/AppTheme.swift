//
//  AppTheme.swift
//  RosaWriter
//
//  Created by Armin on 10/28/25.
//

import SwiftUI

/// The app's color theme preference, persisted via @AppStorage.
enum AppTheme: String, CaseIterable, Identifiable {
  case system = "System"
  case light = "Light"
  case dark = "Dark"

  var id: String { rawValue }

  var colorScheme: ColorScheme? {
    switch self {
    case .system: return nil
    case .light: return .light
    case .dark: return .dark
    }
  }
}
