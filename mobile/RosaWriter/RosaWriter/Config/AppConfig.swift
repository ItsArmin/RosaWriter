//
//  AppConfig.swift
//  RosaWriter
//
//  Created by Armin on 10/19/25.
//

import Foundation

struct AppConfig {
  static let isDevelopment: Bool = {
    #if DEBUG
      return true
    #else
      return false
    #endif
  }()

  static let apiBaseURL = "https://api.example.com"
}
