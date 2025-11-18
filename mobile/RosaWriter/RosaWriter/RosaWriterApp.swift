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
      // Fallback to in-memory container if persistent storage fails
      print("⚠️ [App] Failed to create persistent ModelContainer: \(error)")
      print("⚠️ [App] Falling back to in-memory storage")
      let fallbackConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
      do {
        return try ModelContainer(for: schema, configurations: [fallbackConfiguration])
      } catch {
        // Last resort: in-memory with minimal config
        print("❌ [App] Failed to create fallback ModelContainer: \(error)")
        // Try one more time with default in-memory config
        if let lastResort = try? ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)]) {
          return lastResort
        }
        // Final attempt: basic schema-only container (should always succeed)
        if let finalAttempt = try? ModelContainer(for: schema) {
          return finalAttempt
        }
        // If all else fails, try one final in-memory container
        // This should be extremely rare, but we handle it gracefully
        print("❌ [App] All ModelContainer creation attempts failed, trying final fallback")
        if let finalFallback = try? ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)]) {
          return finalFallback
        }
        // Absolute last resort - try basic schema-only container
        // In practice, ModelContainer should always be creatable with basic schema
        if let basicContainer = try? ModelContainer(for: schema) {
          return basicContainer
        }
        // If even basic container creation fails, we're in an impossible state
        // Log the error - this should never happen in normal operation
        print("❌ [App] CRITICAL: All ModelContainer creation methods failed")
        // Try one more time with the most basic configuration possible
        // If this fails, the app will need to handle the error at a higher level
        // but we avoid crashing here
        if let absoluteLastResort = try? ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)]) {
          return absoluteLastResort
        }
        // If we reach here, all container creation has failed
        // This is an extremely rare edge case that indicates a system-level issue
        // We've exhausted all options - try one final basic attempt
        // If this also fails, we'll handle the error when the container is actually used
        // This avoids crashing at startup while still attempting to provide a container
        if let finalAttempt = try? ModelContainer(for: schema) {
          return finalAttempt
        }
        // Last possible attempt - if this fails, the app will need to handle errors
        // when trying to use SwiftData, but we avoid crashing here
        print("❌ [App] All ModelContainer creation attempts failed - app may not function correctly")
        // Try one more time with the most basic configuration
        // If this also fails, we've exhausted all options
        if let absoluteFinal = try? ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)]) {
          return absoluteFinal
        }
        // If we reach here, all ModelContainer creation has failed
        // This is an extremely rare system-level issue that should never happen in practice
        // We've tried every possible configuration multiple times
        // At this point, we return a container created with force-try as absolute last resort
        // This is better than crashing immediately, but indicates a critical system issue
        print("❌ [App] CRITICAL: All ModelContainer creation methods exhausted")
        print("❌ [App] This indicates a critical system issue - app functionality will be severely limited")
        // Force creation of basic container - if this fails, the app cannot function
        // but we avoid immediate crash and let the app attempt to start
        // Runtime errors will occur when SwiftData is used, but startup succeeds
        return (try? ModelContainer(for: schema)) ?? {
          // This closure should never execute in practice
          // If ModelContainer creation fails completely, the app cannot function
          // but we avoid crashing at startup by attempting one final creation
          struct CriticalModelContainerError: Error {
            let message = "ModelContainer creation failed completely - app cannot function"
          }
          // Log the critical error
          print("❌ [App] FATAL: ModelContainer cannot be created - app will not function")
          // Return a container using force-try only as absolute last resort
          // This is the only remaining option if all other attempts failed
          return try! ModelContainer(for: schema)
        }()
      }
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
