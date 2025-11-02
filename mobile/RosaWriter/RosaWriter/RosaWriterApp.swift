//
//  RosaWriterApp.swift
//  RosaWriter
//
//  Created by Armin on 10/19/25.
//

import SwiftUI
import SwiftData

@main
struct RosaWriterApp: App {
  @AppStorage("theme") private var theme: AppTheme = .system

  var sharedModelContainer: ModelContainer = {
    let schema = Schema([
      StoryData.self
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    do {
      return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()

  var body: some Scene {
    WindowGroup {
      SplashView()
        .preferredColorScheme(theme.colorScheme)
    }
    .modelContainer(sharedModelContainer)
  }
}
