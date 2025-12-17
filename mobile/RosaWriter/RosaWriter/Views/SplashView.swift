//
//  SplashView.swift
//  RosaWriter
//
//  Created by Armin on 10/30/25.
//

import SwiftData
import SwiftUI

struct SplashView: View {
  @Environment(\.modelContext) private var modelContext
  @State private var isActive = false
  @State private var opacity = 0.0

  var body: some View {
    if isActive {
      BookshelfView()
        .environment(\.modelContext, modelContext)
    } else {
      ZStack {
        LinearGradient(
          gradient: Gradient(colors: [
            Color(.systemBackground),
            Color(.systemGray6),
          ]),
          startPoint: .top,
          endPoint: .bottom
        )
        .ignoresSafeArea()

        Image("rosaWriterSplash")
          .resizable()
          .scaledToFit()
          .frame(width: 250)
          .opacity(opacity)
      }
      .onAppear {
        withAnimation(.easeIn(duration: 0.6)) {
          opacity = 1.0
        }

        // Initialize app: migrations, sample books, etc.
        Task {
          await initializeApp()
          
          // Wait for animation to finish, then transition
          try? await Task.sleep(for: .seconds(1.5))

          withAnimation(.easeInOut(duration: 0.4)) {
            isActive = true
          }
        }
      }
    }
  }
  
  // MARK: - App Initialization

  @MainActor
  private func initializeApp() async {
    do {
      // 1. Run schema migrations if needed
      try StorageService.shared.migrateToLatestSchema(context: modelContext)

      // 2. Update sample books if there's a new version
      try StorageService.shared.updateSampleBooksIfNeeded(context: modelContext)

      // 3. If this is the first launch, populate with sample data
      let stories = try StorageService.shared.loadAllStoryData(context: modelContext)
      if stories.isEmpty {
        print("📚 First launch detected - populating with sample data")
        try StorageService.shared.populateWithSampleData(context: modelContext)
      }

      print("✅ App initialization complete")
    } catch {
      print("❌ Initialization error: \(error.localizedDescription)")
      // App will still continue, but with potential issues
    }
  }
}
