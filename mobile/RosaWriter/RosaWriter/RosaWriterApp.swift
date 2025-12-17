//
//  RosaWriterApp.swift
//  RosaWriter
//
//  Created by Armin on 10/19/25.
//

import SwiftData
import SwiftUI

@main
struct RosaWriterApp: App {
  @AppStorage("theme") private var theme: AppTheme = .system

  /// The app's persistent storage container (nil if storage initialization failed)
  let sharedModelContainer: ModelContainer?

  /// Error from storage initialization, if any
  let storageError: Error?

  init() {
    let schema = Schema([StoryData.self])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    do {
      sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
      storageError = nil
    } catch {
      // Storage initialization failed - don't fall back to in-memory
      // as this would cause silent data loss
      print("❌ [App] Failed to create ModelContainer: \(error)")
      sharedModelContainer = nil
      storageError = error
    }
  }

  var body: some Scene {
    WindowGroup {
      if let container = sharedModelContainer {
      SplashView()
        .preferredColorScheme(theme.colorScheme)
          .modelContainer(container)
      } else {
        StorageErrorView(error: storageError)
          .preferredColorScheme(theme.colorScheme)
      }
    }
  }
}
